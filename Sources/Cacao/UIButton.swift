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
	
	public private(set) var imageView: UIImageView?;
	
	// The type of the button.
	public var buttonType: ButtonType {
		didSet {
			updateFrameForButtonType()
		}
	}
	
	private var titles: [UIControlState: String];
	
	private var images: [UIControlState: UIImage];
	
	private var titleColors: [UIControlState: UIColor];
	
	private var defaultColor: UIColor = .black;
	
	private var hideImage: Bool = false {
		didSet {
			hideImageConstraints?.forEach { (constraint) in
				constraint.isActive = hideImage;
			}
		}
	}
	
	private var hideImageConstraints: [NSLayoutConstraint]?;
	
	private var hideTitle: Bool = false {
		didSet {
			hideTitleConstraints?.forEach { (constraint) in
				constraint.isActive = hideTitle;
			}
		}
	}
	
	private var hideTitleConstraints: [NSLayoutConstraint]?;
	
	public init(type: ButtonType = .plain) {
		// Initialise storage variables;
		titles = [UIControlState: String]();
		images = [UIControlState: UIImage]();
		titleColors = [UIControlState: UIColor]();
		buttonType = type;
		super.init(frame: .null);
		self.layoutMargins = UIEdgeInsets(vertical: 4, horizontal: 9);
		updateFrameForButtonType();
		self.borderWidth = 2;
		self.borderRadius = 4;
		let titleLabel = UILabel();
		addSubview(titleLabel);
		self.titleLabel = titleLabel;
		let imageView = UIImageView();
		addSubview(imageView);
		self.imageView = imageView;
		// Set the layout with the image to the left of the title.
		imageView.leftAnchor.constraint(equalTo: self.leftMarginAnchor).isActive = true;
		imageView.topAnchor.constraint(equalTo: self.topMarginAnchor).isActive = true;
		titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true;
		titleLabel.topAnchor.constraint(equalTo: self.topMarginAnchor).isActive = true;
		// Make the imageView 32 points by 32 points, with a defaultHigh priority so it can be overridden by the hiding constraints.
		imageView.widthAnchor.constraint(equalTo: 16, withPriority: .defaultHigh).isActive = true;
		imageView.heightAnchor.constraint(equalTo: 16, withPriority: .defaultHigh).isActive = true;
		// Create constraints to hide the image and title when necessary.
		self.hideImageConstraints = [
			imageView.widthAnchor.constraint(equalTo: 0),
			imageView.heightAnchor.constraint(equalTo: 0)
		];
		self.hideTitleConstraints = [
			titleLabel.widthAnchor.constraint(equalTo: 0),
			titleLabel.heightAnchor.constraint(equalTo: 0)
		];
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
	
	public var currentImage: UIImage? {
		get {
			return image(for: state);
		}
	}
	
	public func image(for state: UIControlState) -> UIImage? {
		var image = images[state];
		if image == nil {
			image = images[.normal];
		}
		return image;
	}
	
	public func setImage(_ image: UIImage?, for state: UIControlState) {
		images[state] = image;
		refresh();
	}
	
	// Updates the content of the button.
	public func refresh() {
		debugPrint("Calling refresh for button \(self)");
		debugPrint("Current title was \(currentTitle), current image was \(currentImage)");
		titleLabel?.text = currentTitle;
		titleLabel?.textColor = currentTitleColor;
		// If the titleLabel is currently displaying a blank string or nil, constraint its frame to 0,0 to prevent additional padding.
		hideTitle = (currentTitle == nil || currentTitle == "");
		imageView?.image = currentImage;
		hideImage = currentImage == nil;
		// Now that we have calculated our new intrinsic size, trigger a layout pass for our container view.
		// superview?.setNeedsLayout();
		self.setNeedsLayout();
		setNeedsDisplay();
		self.titleLabel?.setNeedsDisplay();
		self.imageView?.setNeedsDisplay();
	}
	
	private func updateFrameForButtonType() {
		switch buttonType {
		case .plain, .done:
			backgroundColor = .normalBackground;
			borderColor = .normalBorder;
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
 
