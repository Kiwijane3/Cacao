//
//  TextRendering.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import Foundation
import Silica

// MARK: - Methods

let punctuation: [Character] = [" ", ".", "!", "?", "-", ","];

public extension String {
    
    func draw(in rect: CGRect, context: Silica.CGContext, attributes: TextAttributes = TextAttributes()) {
        
        // set context values
        context.setTextAttributes(attributes)
        
        // render
        let textRect = self.contentFrame(for: rect, textMatrix: context.textMatrix, attributes: attributes)
        
        context.textPosition = textRect.origin
        
        context.show(text: self)
    }
    
    func contentFrame(for bounds: CGRect, textMatrix: CGAffineTransform = .identity, attributes: TextAttributes = TextAttributes()) -> CGRect {
        
        // assume horizontal layout (not rendering non-latin languages)
        
        // calculate frame
        
        let textWidth = attributes.font.cgFont.singleLineWidth(text: self, fontSize: attributes.font.pointSize, textMatrix: textMatrix)
		
        let lines: CGFloat = 1.0
        
        let textHeight = attributes.font.pointSize * lines
        
        var textRect = CGRect(x: bounds.origin.x,
                              y: bounds.origin.y,
                              width: textWidth,
                              height: textHeight) // height == font.size
        
        switch attributes.paragraphStyle.alignment {
            
        case .left: break // always left by default
            
        case .center: textRect.origin.x = (bounds.width - textRect.width) / 2
            
        case .right: textRect.origin.x = bounds.width - textRect.width
        }
        
        return textRect
    }
	
}

public class TextBlock {
	
	public var attributes: TextAttributes {
		didSet {
			recalculateLayout();
		}
	}
	
	public var font: UIFont {
		get {
			return attributes.font;
		}
	}
	
	// Extra width for lines, in addition to the ascender and descender.
	public var lineLead: CGFloat {
		didSet {
			calculateHeight();
		}
	}
	
	public var rawText: String {
		didSet {
			recalculateLayout();
		}
	}
	
	public var wrapWidth: CGFloat {
		didSet {
			recalculateLayout();
		}
	}
	
	public private(set) var lines: [String];
	
	public private(set) var size: CGSize;
	
	public private(set) var width: CGFloat {
		get {
			return size.width;
		}
		set {
			size.width = newValue;
		}
	}
	
	public private(set) var height: CGFloat {
		get {
			return size.height;
		}
		set {
			size.height = newValue;
		}
	}
	
	public var selectable: Bool;
	
	// Represents the midpoints of each character in each line. Used for character selection.
	private var selectionMidpoints: [[CGFloat]]?;
	
	// Represents the heights at which there is a change in line.
	private var lineBoundaries: [CGFloat]?;
	
	public init() {
		attributes = TextAttributes();
		lineLead = 4;
		wrapWidth = -1;
		rawText = "";
		lines = [String]();
		size = CGSize();
		selectable = false;
	}
	
	public func recalculateLayout() {
		lines = [];
		width = 0;
		if wrapWidth >= 0 {
			// Split into segments based on line break characters.
			let explicitLines = linesForExplicitBreaks();
			for explicitLine in explicitLines {
				// Calculate wrapped lines for each ofr the explicit segments.
				wrap(explicitLine);
			}
			calculateHeight();
			if selectable {
				calculateLineBoundaries();
				calculateMidpoints();
			}
		} else {
			// wrapWidth values below 0 indicate no wrapping, so simply calculate the explicit lines.
			lines = linesForExplicitBreaks();
			// Go through the explicit lines and set the widest one as the text block's width.
			for line in lines {
				let lineWidth = width(for: line);
				if width < lineWidth {
					width = lineWidth;
				}
			}
			calculateHeight();
			if selectable {
 				calculateLineBoundaries();
				calculateMidpoints();
			}
		}
	}
	
	public func calculateHeight() {
		height = 0;
		for index in 0..<lines.count {
			height += height(ofLine: index);
		}
	}
	
	public func height(ofLine index: Int) -> CGFloat {
		debugPrint("Font Descender: \(attributes.font.descender)");
		debugPrint("Font Ascender: \(attributes.font.ascender)");
		return attributes.font.ascender + abs(attributes.font.descender) + lineLead;
	}
	
	func calculateLineBoundaries() {
		lineBoundaries = [-Double.infinity];
		for index in 0..<lines.count {
			lineBoundaries!.append(lineBoundaries![index] + height(ofLine: index));
		}
	}
	
	func linesForExplicitBreaks() -> [String] {
		var results = [String]();
		var previousCharacterWasR = false;
		var lineStart = rawText.startIndex;
		for index in rawText.indices {
			if rawText[index] == "\r" {
				// Add a new line to the output. from the start of this line to that point.
				results.append(String(rawText[lineStart..<index]));
				// Advance line start beyond line breaks characters.
				lineStart = rawText.index(index, offsetBy: 1);
				// Set the /r flag.
				previousCharacterWasR = true;
			} else if rawText[index] == "\n"{
				// Don't create a new line if we encounter \n in the context of \r\n.
				if !previousCharacterWasR {
					results.append(String(rawText[lineStart..<index]));
				}
				// Advance lineStart whenever \n is encountered.
				lineStart = rawText.index(index, offsetBy: 1);
				// Unset the \r flag.
				previousCharacterWasR = false;
			} else {
				// Unset the \r flag.
				previousCharacterWasR = false;
			}
		}
		// Add the final line, if there is any content after the final line break.
		if lineStart != rawText.endIndex {
			results.append(String(rawText[lineStart..<rawText.endIndex]));
		}
		return results;
	}
	
	// Wraps this line. Does not take into account encoding line breaks; Separate a string containing line breaks into lines based on those breaks before wrapping.
	func wrap(_ line: String) {
		// Calculate the cluster boundaries for the given wrapStyle.
		let clusterBoundaries = self.clusterBoundaries(for: line);
		// Calculate the advances for this string; This is a simple method for non-complex text, add complex rendering from a library like harfbuzz at some point in the future.
		let advances = font.advances(for: line);
		// A series of indices at which to add line breaks. Each index is the start of a new line.
		var breakpoints = [Int]();
		// The index at which this line starts.
		var lineStart = 0;
		// The index after the final index of the current line.
		var lineEnd = 0;
		var lineWidth: CGFloat = 0.0;
		// Iterate through the cluster boundaries and make breaks as appropriate. Note the each boundary is the start of the next cluster.
		for clusterBoundary in clusterBoundaries {
			// Calculate the width of the next cluster.
			let clusterWidth = advances[lineEnd..<clusterBoundary].reduce(0) { (sum, element) in
				return sum + element.width;
			}
			let sumWidth = lineWidth + clusterWidth;
			// If the line would exceed the specified width after the cluster is added, add a break at the current lineEnd.
			if sumWidth > wrapWidth {
				// Creating a new line, including the new cluster.
				breakpoints.append(lineEnd);
				lineStart = lineEnd;
				lineEnd = clusterBoundary;
				// Update the width of the block if the new line exceeds the previous width.
				if width < lineWidth {
					width = lineWidth;
				}
				// Set the width of the new line to the width of the first cluster.
				lineWidth = clusterWidth;
			} else {
				// Continue appending to the current line.
				lineEnd = clusterBoundary;
				lineWidth = sumWidth;
			}
		}
		// Store the start of the current line during line substring generation.
		lineStart = 0;
		for breakpoint in breakpoints {
			// Add the next line to lines.
			lines.append(String(line[line.index(line.startIndex, offsetBy: lineStart)..<line.index(line.startIndex, offsetBy: breakpoint)]));
			// The start of the next line is the breakpoint.
			lineStart = breakpoint;
		}
		// Add the final line of the text
		lines.append(String(line[line.index(line.startIndex, offsetBy: lineStart)..<line.endIndex]));
	}
	
	func clusterBoundaries(for line: String) -> [Int] {
		var result = [Int]();
		for index in 0..<line.count {
			if line[line.index(line.startIndex, offsetBy: index)].isClusterTerminal(for: attributes.wrapStyle) {
				result.append(index + 1);
			}
		}
		// Ensure the end of the string is included as a cluster boundary.
		if result.last! != line.count {
			result.append(line.count);
		}
		return result;
	}
	
	func width(for line: String) -> CGFloat {
		return font.advances(for: line).reduce(0.0, { (sum, element)  in return sum + element.width; });
	}
	
	// Calculates and sets the glyph midpoints of the line
	func calculateMidpoints() {
		self.selectionMidpoints = lines.map({ (line) in
			return calculateMidpoints(for: line);
		})
	}
	
	// Returns the horizontal center point ofthe each character in the line. Used for selection.
	func calculateMidpoints(for line: String) -> [CGFloat] {
		let advances = font.advances(for: line);
		var midpoints = [CGFloat]();
		// The position representing the beginning of the character under consideration.
		var position: CGFloat = 0;
		for advance in advances {
			let charEnd = position + advance.width;
			midpoints.append((position + charEnd) / 2);
			position = charEnd;
		}
		return midpoints;
	}
	
	func resolveLineIndex(for point: CGPoint) -> Int {
		// Start by checking for y positions above or below the text.
		if point.y < 0 {
			return 0;
		}
		if point.y > lineBoundaries.last! ?? 0 {
			return lines.count - 1;
		}
		// Perform a binary search
		// Set up the bounds to cover all lines.
		var lowerBound = 0;
		var upperBound = lines.count;
		while lowerBound != upperBound {
			var checkIndex = lowerBound + ( ( upperBound - lowerBound ) / 2 );
			// If the y-point is below the range for the current line, set this as the upperBound to search the upper half of the current range.
			if point.y < lineBoundaries[checkIndex] {
				upperBound = checkIndex;
			} else if point.y > lineBoundaries[checkIndex + 1] {
				// If the y-point is above the range for the current line, set this as the lower bound and search the upper half of the current range.
				lowerBound = checkIndex;
			} else {
				// The y-point is within the range for this line, so return the current index.
				return checkIndex;
			}
		}
		return 0;
	}
	
	func resolveIndexInLine(for point: CGPoint) -> Int {
		// Start by checking if the x or y position is outside the line boundaries.
	}
	
	func draw(in rect: CGRect, context: Silica.CGContext) {
		context.setTextAttributes(attributes);
		var drawOrigin = rect.origin;
		for lineIndex in 0..<lines.count {
			// Set the appropriate origin for this line of text.
			context.textPosition = drawOrigin;
			// Draw the text.
			context.show(text: lines[lineIndex]);
			// Advance the origin to the next line.
			drawOrigin.y += height(ofLine: lineIndex);
		}
	}
	
}

extension Character {
	
	// Returns whether the given character is the final character of a cluster for the given WrapStyle.
	// TODO: - Update with ICU functionality.
	func isClusterTerminal(for wrapStyle: WrapStyle) -> Bool {
		// Switch based on the given WrapStyle.
		switch wrapStyle {
		case .word:
			// Word wrapping includes all characters from the startIndex up to the next punctation mark, inclusive, so any punctuation mark is a cluster boundary.
			return punctuation.contains(self);
		case .character:
			// Character wrapping wraps at each character, so each displayed character is a cluster and and all characters are cluster terminals
			return true;
		}
	}
	
}

public enum WrapStyle {
	case word
	case character
}

// MARK: - Supporting Types

public struct TextAttributes {
    
    public init() { }
    
    public var font = UIFont(name: "Helvetica", size: 17)!
    
    public var color = UIColor.black
    
    public var paragraphStyle = ParagraphStyle()
	
	public var wrapStyle: WrapStyle = .word;
	
}

public struct ParagraphStyle {
    
    public init() { }
    
    public var alignment = TextAlignment()
}

public enum TextAlignment {
    
    public init() { self = .left }
    
    case left
    case center
    case right
}

// MARK: - Extensions

public extension Silica.CGContext {
    
    func setTextAttributes(_ attributes: TextAttributes) {
        
        self.fontSize = attributes.font.pointSize
        self.setFont(attributes.font.cgFont)
        self.fillColor = attributes.color.cgColor
    }
}
