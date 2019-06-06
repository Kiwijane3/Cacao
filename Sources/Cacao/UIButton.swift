//
//  Button.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 5/28/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import struct Foundation.CGFloat
import struct Foundation.CGPoint
import struct Foundation.CGSize
import struct Foundation.CGRect
import Silica

public final class UIButton: UIControl {
	
	public enum ButtonType {
		// Button types from UIKit.
		case plain
		case done
		// Button types for Gtk compatibility
		case suggested
		case destructive
		// Additional Cacao specific types.
		case frameless
		case custom(background: UIColor, border: UIColor);
	}
	
	public private(set) var titleLabel: UILabel?;
	
	// The type of the button.
	public var buttonType: ButtonType {
		didSet {
			updateFrameForButtonType()
		}
	}
	
	private var titles: [UIControlState: String];
	
	private var titleColors: [UIControlState: UIColor];
	
	private var defaultColor: UIColor = .black;
	
	public init(type: ButtonType = .plain) {
		// Initialise storage variables;
		titles = [UIControlState: String]();
		titleColors = [UIControlState: UIColor]();
		buttonType = type;
		let titleLabel = UILabel();
		super.init(frame: .null);
		self.layoutMargins = UIEdgeInsets(vertical: 4, horizontal: 9);
		updateFrameForButtonType();
		self.borderWidth = 1;
		self.borderRadius = 5;
		addSubview(titleLabel);
		titleLabel.leftAnchor.constraint(equalTo: self.leftMarginAnchor).isActive = true;
		titleLabel.topAnchor.constraint(equalTo: self.topMarginAnchor).isActive = true;
		self.titleLabel = titleLabel;
		refresh();
	}
    
    // MARK: - Methods
	
	public var currentTitle: String? {
		return title(for: state) ?? "";
	}
	
	public func title(for state: UIControlState) -> String? {
		// Fetch the title for the state.
		var title = titles[state];
		// If no title is defined for this state, return the title for the normal state.
		if title == nil {
			title = titles[.normal];
		}
		return title;
	}
	
	public func setTitle(_ title: String?, for state: UIControlState) {
		titles[state] = title;
		refresh();
	}
	
	public var currentTitleColor: UIColor {
		return titleColor(for: state) ?? UIColor.black;
	}
	
	public func titleColor(for state: UIControlState) -> UIColor? {
		var titleColor = titleColors[state];
		if titleColor == nil {
			titleColor = titleColors[.normal];
		}
		return titleColor;
	}
	
	public func setTitleColor(_ titleColor: UIColor, for state: UIControlState) {
		titleColors[state] = titleColor;
		refresh();
	}
	
	// Updates the content of the button.
	public func refresh() {
		titleLabel?.text = title(for: state);
		titleLabel?.textColor = titleColor(for: state) ?? defaultColor;
		// Recalculate the internal constraints to calculate the intrinsic size for the new content.
		autoLayout();
		// Now that we have calculated our new intrinsic size, trigger a layout pass for our container view.
		superview?.setNeedsLayout();
		setNeedsDisplay();
	}
	
	private func updateFrameForButtonType() {
		switch buttonType {
		case .plain, .done:
			backgroundColor = .normalBackground;
			borderColor = .normalBackground;
			defaultColor = .black;
		case .destructive:
			backgroundColor = .destructiveBackground;
			borderColor = .destructiveBorder;
			defaultColor = .white;
		case .suggested:
			backgroundColor = .suggestedBackground;
			borderColor = .suggestedBorder;
			defaultColor = .white;
		case .frameless:
			backgroundColor = .clear;
			borderColor = .clear;
			defaultColor = .black;
		case .custom(let background, let border):
			backgroundColor = background;
			borderColor = border;
			defaultColor = .black;
		}
		// refresh in order to set title color.
		refresh();
	}
	
	 public override var intrinsicContentSize: CGSize {
		get {
			return autoLayoutContentSize;
		}
	}
	
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        guard isHidden == false,
            alpha > 0,
            isUserInteractionEnabled,
            self.point(inside: point, with: event)
            else { return nil }
        
        // swallows touches intended for subviews
        
        return self
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendActions(for: .touchDown)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendActions(for: .touchUpInside)
    }
	
}

extension UIColor {
	
	static let normalBackground = UIColor(red: 209, green: 209, blue: 207);
	
	static let normalBorder = UIColor(red: 182, green: 182, blue: 179);
	
	static let destructiveBackground = UIColor(red: 238, green: 34, blue: 34);
	
	static let destructiveBorder = UIColor(red: 145, green: 15, blue: 15);
	
	static let suggestedBackground = UIColor(red: 74, green: 144, blue: 217);
	
	static let suggestedBorder = UIColor(red: 28, green: 82, blue: 136);
	
}
 
