//
//  AutoLayout.swift
//  Cacao
//
//  Created by Jane Fraser on 27/11/18.
//

import Foundation

import Cassowary

import class Simplex.Variable

/// This file contains various utility classes used for auto layout.

/// This structure contains a reference to a property on a particular target. Mainly used as a key for variable sets.
internal struct Property: Hashable {
	
	public let target: AnyObject;
	
	public let attribute: NSLayoutConstraint.Attribute;
	
	public var hashValue: Int {
		get {
			var hasher = Hasher();
			hasher.combine(ObjectIdentifier(target));
			hasher.combine(attribute.rawValue);
			return hasher.finalize();
		}
	}
	
	public init(target: AnyObject, attribute: NSLayoutConstraint.Attribute) {
		self.target = target;
		self.attribute = attribute;
	}
	
	public static func ==(_ a: Property, _ b: Property) -> Bool {
		return a.target === b.target && a.attribute == b.attribute;
	}
	
	public static func !=(_ a: Property, _ b: Property) -> Bool {
		return a.target !== b.target || a.attribute != b.attribute;
	}
	
}

// Manages the relationship between properties, via Property structures, and Cassowary variables.
internal class VariableSet {
	
	public var map: [Property: Variable];
	
	public init() {
		self.map = [Property: Variable]();
	}
	
	public func variable(for property: Property) -> Variable {
		if let variable = map[property] {
			// Try to find the variable and return it.
			return variable;
		} else {
			// Otherwise, create a new property, store it, and return it.
			let variable = Variable();
			map[property] = variable;
			return variable;
		}
	}
	
	public func variable(for attribute: NSLayoutConstraint.Attribute, on target: UIView) -> Variable {
		return variable(for: Property(target: target, attribute: attribute));
	}
	
}

// Converts a UILayoutPriority to a cassowary priority.
internal func getPriority(for priority: UILayoutPriority) -> Priority {
	if priority >= UILayoutPriority.required {
		return Priority.required;
	} else {
		return Priority.optional(Int(priority));
	}
}

// Default AutoLayout methods for UIView classes
extension UIView {

	// Creates the intrinsic constraints for this UIView which consists of the fundamental rules of geometry, such as width = right - left, and content compression and hugging based on intrinsic size, if applicable. Should be used by superviews during their layout calculation.
	internal func intrinsicConstraints(in set: VariableSet) -> [Cassowary.Constraint] {
		// Start by creating the fundamental geometry, i.e., width = right - left.
		var constraints: [Cassowary.Constraint] = [
			// Intrinsic properties of geometry.
			set.variable(for: .width, on: self) == set.variable(for: .right, on: self) - set.variable(for: .left, on: self) ~ 1000,
			set.variable(for: .height, on: self) == set.variable(for: .bottom, on: self) - set.variable(for: .top, on: self) ~ 1000,
			set.variable(for: .centerX, on: self) == set.variable(for: .left, on: self) + (set.variable(for: .width, on: self) * 0.5) ~ 1000,
			set.variable(for: .centerY, on: self) == set.variable(for: .top, on: self) + (set.variable(for: .height, on: self) * 0.5) ~ 1000,
			set.variable(for: .leftMargin, on: self) == set.variable(for: .left, on: self) + Double(self.layoutMargins.left) ~ 1000,
			set.variable(for: .rightMargin, on: self) == set.variable(for: .right, on: self) - Double(self.layoutMargins.right) ~ 1000,
			set.variable(for: .topMargin, on: self) == set.variable(for: .top, on: self) + Double(self.layoutMargins.top) ~ 1000,
			set.variable(for: .bottomMargin, on: self) == set.variable(for: .bottom, on: self) - Double(self.layoutMargins.bottom) ~ 1000,
		];
		// Preserve valid pre-set frame attributes if they are not otherwise defined in the constraint system.
		if !self.frame.isNull && !self.frame.isInfinite {
			constraints.append(contentsOf: [
					set.variable(for: .left, on: self) == Double(self.frame.origin.x) ~ 1,
					set.variable(for: .top, on: self) == Double(self.frame.origin.y) ~ 1,
					set.variable(for: .width, on : self) == Double(self.frame.size.width) ~ 1,
					set.variable(for: .height, on: self) == Double(self.frame.size.height) ~ 1
				]);
		}
		// Add constraints for the intrinsic content size if present on the view.
		if self.intrinsicContentSize.width != UIViewNoIntrinsicMetric {
			// Add a constraint for content compression on the horizontal axis with the appropriate priority
			let compressionPriority = getPriority(for: self.contentCompressionResistancePriority(for: .horizontal));
			constraints.append((set.variable(for: .width, on: self) >= Double(self.intrinsicContentSize.width)) ~ compressionPriority );
			// Add a constraint for content hugging on the horizontal axis with the apprrpriate priority
			let huggingPriority = getPriority(for: self.contentHuggingPriority(for: .horizontal));
			constraints.append((set.variable(for: .width, on: self) <= Double(self.intrinsicContentSize.width)) ~ huggingPriority);
		}
		if self.intrinsicContentSize.height != UIViewNoIntrinsicMetric {
			// Add a constraint for content compression on the vertical axis with the appropriate priority.
			let compressionPriority = getPriority(for: self.contentCompressionResistancePriority(for: .vertical));
			constraints.append((set.variable(for: .height, on: self) >= Double(self.intrinsicContentSize.height)) ~ compressionPriority);
			let huggingPriority = getPriority(for: self.contentHuggingPriority(for: .vertical));
			constraints.append((set.variable(for: .height, on: self) <= Double(self.intrinsicContentSize.height)) ~ huggingPriority);
		}
		return constraints;
	}

	// Constraints for layouts contained by this UIView. To be used during this view's own layout calculation.
	internal func containerConstraints(in set: VariableSet) -> [Cassowary.Constraint] {
		// Create variables for the bounds of the view.
		let left: Double = 0;
		let width = Double(self.frame.size.width);
		let right = left + width;
		let centerX = left + (width / 2);
		let top: Double = 0;
		let height = Double(self.frame.size.height);
		let bottom = top + height;
		let centerY = top + (height / 2);
		var constraints: [Cassowary.Constraint] = [
			// Constrain the absolute bounds to the relevant variables.
			set.variable(for: .left, on: self) == left ~ 1000,
			set.variable(for: .right, on: self) == left + width ~ 1000,
			set.variable(for: .centerX, on: self) == centerX ~ 1000,
			set.variable(for: .width, on: self) == width ~ 1000,
			set.variable(for: .top, on: self) == top ~ 1000,
			set.variable(for: .bottom, on: self) == top + height ~ 1000,
			set.variable(for: .centerY, on: self) == centerY ~ 1000,
			set.variable(for: .height, on: self) == height ~ 1000,
			
			// Constrain the margins to the relevant absolute modified by the relevant margin.
			set.variable(for: .leftMargin, on: self) == left + Double(self.layoutMargins.left) ~ 1000,
			set.variable(for: .rightMargin, on: self) == right - Double(self.layoutMargins.right) ~ 1000,
			set.variable(for: .topMargin, on: self) == top + Double(self.layoutMargins.top) ~ 1000,
			set.variable(for: .bottomMargin, on: self) == bottom + Double(self.layoutMargins.bottom) ~ 1000
		];
		return constraints;
	}
	
	// Converts the programmed NSLayoutConstraints into cassowary constraints. Should be used during this view's own layout calculation.
	internal func programmedConstraints(in set: VariableSet) -> [Cassowary.Constraint] {
		var constraints = [Cassowary.Constraint]();
		for nsConstraint in self.constraints {
			if let constraint = constraint(for: nsConstraint, in: set) {
				constraints.append(constraint);
			}
		}
		return constraints;
	}
	
	// Gives all constraints to be used during this view's layout calculation.
	internal func constraints(in set: VariableSet) -> [Cassowary.Constraint] {
		var constraints = [Cassowary.Constraint]();
		for subview in subviews {
			constraints.append(contentsOf: subview.intrinsicConstraints(in: set));
		}
		constraints.append(contentsOf: containerConstraints(in: set));
		constraints.append(contentsOf: programmedConstraints(in: set));
		return constraints;
	}
	
	// Solves a layout defined by the specified constraints.
	internal func solveLayout(with constraints: [Cassowary.Constraint]) -> [Variable: Double] {
		var solver = Cassowary.Solver();
		// Creating a new solver everytime is probably quite inefficient, but the important thing is to get the constraints converted and created.
		do {
			try solver.addConstraints(constraints)
		} catch {
			debugPrint(error);
		}
		return try! solver.solve();
	}
	
	// Applies a solved layout to the view hierarchy. The constraints used to calculate the layout must have used variables from \set.
	internal func applyLayout(_ layout: [Variable: Double], in set: VariableSet) {
		// Reset contentSize.
		self.autoLayoutContentSize = CGSize();
		for subview in subviews {
			if let x = layout[set.variable(for: .left, on: subview)] {
				subview.frame.origin.x = CGFloat(x);
			}
			if let y = layout[set.variable(for: .top, on: subview)] {
				subview.frame.origin.y = CGFloat(y);
			}
			if let width = layout[set.variable(for: .width, on: subview)] {
				subview.frame.size.width = CGFloat(width);
			}
			if let height = layout[set.variable(for: .height, on: subview)] {
				subview.frame.size.height = CGFloat(height);
			}
			print("\(subview) laid out as x: \(subview.frame.origin.x), y: \(subview.frame.origin.y), width: \(subview.frame.size.width), height: \(subview.frame.size.height)");
			// Calculate the lower-right point, and if it can't be contained in contained in autoLayoutContentSize, expand autoLayoutContentSize to accommodate it.
			let maxX = subview.frame.maxX;
			if maxX > self.autoLayoutContentSize.width {
				self.autoLayoutContentSize.width = maxX;
			}
			let maxY = subview.frame.maxY;
			if maxY > self.autoLayoutContentSize.height {
				self.autoLayoutContentSize.height = maxY;
			}
			subview.setNeedsDisplay();
		}
		// Now that we have the size to accommodate all autolayout content, add the appropriate margins.
		self.autoLayoutContentSize.width += self.layoutMargins.right;
		self.autoLayoutContentSize.height += self.layoutMargins.left;
	}
	
	// Lays out this view's subviews according to autoLayout constraints.
	@usableFromInline
	internal func autoLayout() {
		let set = VariableSet();
		applyLayout(solveLayout(with: constraints(in: set)), in: set);
		setNeedsDisplay();
	}
	
	// Updates this view's intrinsic size to accommodate its content as laid out by its constraint.
	public func resizeToFitAutoLayoutContent() {
		
	}
	
}

/// Converts an NSLayoutConstraint to Cassowary Constraint.
internal func constraint(for constraint: NSLayoutConstraint, in set: VariableSet) -> Cassowary.Constraint? {
	if let firstView = constraint.firstItem as? UIView {
		// Get the variable for the firstView's attribute.
		let firstVariable = set.variable(for: constraint.firstAttribute, on: firstView);
		// Convert the constraint priority to a cassowary priority.
		let priority = getPriority(for: constraint.priority);
		// Handle the special case where the secondAttribute is notAnAttribute, where the first property is bound to the constant.
		if constraint.secondAttribute == .notAnAttribute {
			switch constraint.relation {
			case .equal:
				return (firstVariable == Double(constraint.constant)) ~ priority;
			case .greaterThanOrEqual:
				return (firstVariable >= Double(constraint.constant)) ~ priority;
			case .lessThanOrEqual:
				return (firstVariable <= Double(constraint.constant)) ~ priority;
			}
		} else if let secondView = constraint.secondItem as? UIView {
			// Handle the other cases.
			// Get the variable for the second property
			let secondVariable = set.variable(for: constraint.secondAttribute, on: secondView);
			switch constraint.relation {
			case .equal:
				return (firstVariable == (Double(constraint.multiplier) * secondVariable) + Double(constraint.constant)) ~ priority;
			case .lessThanOrEqual:
				return (firstVariable <= (Double(constraint.multiplier) * secondVariable) + Double(constraint.constant)) ~ priority;
			case .greaterThanOrEqual:
				return (firstVariable >= (Double(constraint.multiplier) * secondVariable) + Double(constraint.constant)) ~ priority;
			}
		}
	}
	// Fallthrough and return nil.
	return nil;
}
