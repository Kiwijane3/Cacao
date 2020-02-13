//
//  Label.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 5/29/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import Foundation
import Silica

open class UILabel: UIView {
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // disable user interaction
        self.isUserInteractionEnabled = false
    }
	
    // MARK: - Properties
    
    open var text: String? {
		didSet {
			textBlock.rawText = text ?? "";
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
			setNeedsLayout();
		}
		
	}
    
	open var font: UIFont = UIFont(name: "Helvetica", size: 17)! {
		didSet {
			textBlock.attributes.font = font;
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
			setNeedsLayout();
		}
		
	}
    
    open var textColor: UIColor = .black {
		didSet {
			textBlock.attributes.color = textColor;
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
		}
	}
    
    open var textAlignment: TextAlignment = .left {
		didSet {
			textBlock.attributes.paragraphStyle.alignment = textAlignment;
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
		}
	}
	
	open var preferredMaxLayoutWidth: CGFloat = 0 {
		didSet {
			textBlock.wrapWidth = preferredMaxLayoutWidth;
			invalidateIntrinsicContentSize();
		}
	}
	
	private var textBlock = TextBlock();
	
	// MARK: - intrinsic content size based off text size.
	
	open override var intrinsicContentSize: CGSize {
		return textBlock.size + layoutMargins.size;
	}
	
    // MARK: - Draw
    
    open override func draw(_ rect: CGRect) {
		
        guard let context = UIGraphicsGetCurrentContext()
            else { return }
		
		let x = layoutMargins.left;
		let y = layoutMargins.top;
		let origin = CGRect(x: x, y: y, width: 0, height: 0);
		textBlock.draw(in: origin, context: context);
    }
	
}

// TODO: UIAppearance
extension UILabel {
    
    public static func appearance() -> UILabel {
        
        return UILabel(frame: CGRect())
    }
}
