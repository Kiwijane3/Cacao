//
//  UIWindowBar.swift
//  Cacao
//
//  Created by Jane Fraser on 22/04/19.
//

import Foundation

public class UIWindowBar: UIView {
	
	public override var intrinsicContentSize: CGSize {
		get {
			return CGSize(width: superview?.frame.size.width ?? 0, height: 48);
		}
	}
	
	public weak var windowController: UIWindowController? {
		didSet {
			controls.windowController = windowController;
		}
	}
	
	public var leftGroup: UIBarItemGroup;
	
	public var rightGroup: UIBarItemGroup;
	
	public var controls: UIWindowControls;
	
	public var centerView: UIView? {
		didSet {
			// Remove the old value from the view.
			oldValue?.removeFromSuperview();
			if let centerView = centerView {
				self.addSubview(centerView);
				centerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
				centerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true;
			}
		}
	}
	
	public var titleLabel: UILabel? {
		get {
			return centerView as? UILabel;
		}
	}
	
	public var windowBarItem: UIWindowBarItem? {
		didSet {
			displayItem();
		}
	}
	
	public init() {
		leftGroup = UIBarItemGroup();
		rightGroup = UIBarItemGroup();
		controls = UIWindowControls();
		centerView = nil;
		super.init(frame: .null);
		self.backgroundColor = .windowBarBackground;
		self.layoutMargins = UIEdgeInsets(vertical: 8, horizontal: 8);
		controls.windowController = windowController;
		self.addSubview(leftGroup);
		self.addSubview(rightGroup);
		self.addSubview(controls);
		self.leftGroup.leftAnchor.constraint(equalTo: self.leftMarginAnchor).isActive = true;
		self.leftGroup.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
		self.controls.rightAnchor.constraint(equalTo: self.rightMarginAnchor).isActive = true;
		self.controls.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
		self.rightGroup.rightAnchor.constraint(equalTo: controls.leftAnchor, constant: -8).isActive = true;
		self.rightGroup.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
		self.setNeedsLayout();
	}
	
	// Displays the current item.
	public func displayItem() {
		if let windowBarItem = windowBarItem {
			var leftBarItems = windowBarItem.leftBarItems;
			// Add the back button if requested.
			if windowBarItem.showsBackButton {
				leftBarItems.insert(UIBarButtonItem(title: "Back", action: windowBarItem.backAction ?? { _ in self.windowController?.navigateBack() }), at: 0);
			}
			leftGroup.barItems = leftBarItems;
			// Layout the bar item immediately so its intrinsic content size is calculated.
			rightGroup.barItems = windowBarItem.rightBarItems;
			if let title = windowBarItem.title {
				// Make the center view a label if it does not exist or is not a label.
				if titleLabel == nil {
					centerView = UILabel();
				}
				titleLabel?.text = title;
			} else {
				if titleLabel != nil {
					centerView = nil;
				}
			}
		}
		setNeedsLayout();
		setNeedsDisplay();
	}
	
}

public extension UIColor {
	
	public static let windowBarBackground = UIColor(red: 242, green: 242, blue: 242);
	
}
