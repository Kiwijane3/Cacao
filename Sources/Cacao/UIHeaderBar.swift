//
//  UIWindowBar.swift
//  Cacao
//
//  Created by Jane Fraser on 22/04/19.
//

import Foundation

public class UIHeaderBar: UIView {
	
	// MARK: - Properties
	
	public override var intrinsicContentSize: CGSize {
		get {
			return CGSize(width: superview?.frame.size.width ?? 0, height: 48);
		}
	}
	
	public weak var windowController: UIWindowController? {
		didSet {
			controls?.windowController = windowController;
		}
	}
	
	public let doesShowControls: Bool;
	
	public var leftGroup: UIBarItemGroup;
	
	public var rightGroup: UIBarItemGroup;
	
	public var controls: UIWindowControls?;
	
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
	
	public var headerBarItem: UIHeaderBarItem? {
		didSet {
			displayItem();
		}
	}
	
	
	public init(showsWindowControls doesShowControls: Bool = true) {
		self.doesShowControls = doesShowControls;
		leftGroup = UIBarItemGroup();
		rightGroup = UIBarItemGroup();
		if doesShowControls {
			controls = UIWindowControls();
		}
		centerView = nil;
		super.init(frame: .null);
		self.backgroundColor = .windowBarBackground;
		self.layoutMargins = UIEdgeInsets(vertical: 8, horizontal: 8);
		if let controls = controls {
			controls.windowController = windowController;
			self.addSubview(controls);
		}
		self.addSubview(leftGroup);
		self.addSubview(rightGroup);
		self.leftGroup.leftAnchor.constraint(equalTo: self.leftMarginAnchor).isActive = true;
		self.leftGroup.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
		if let controls = controls {
			controls.rightAnchor.constraint(equalTo: self.rightMarginAnchor).isActive = true;
			controls.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
			rightGroup.rightAnchor.constraint(equalTo: controls.leftAnchor, constant: -8).isActive = true;
		} else {
			self.rightGroup.rightAnchor.constraint(equalTo: self.rightMarginAnchor).isActive = true;
		}
		self.rightGroup.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
		// Create a constraint to hide the window controls.
		self.setNeedsLayout();
	}
	
	// MARK: - Setup
	
	// Displays the current item.
	public func displayItem() {
		if let windowBarItem = headerBarItem {
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
	
	// MARK: - Window movement
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			self.window?.beginManipulation(withMode: .move, at: touch.location(in: self), in: self);
		}
	}
	
	public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			self.window?.updateManipulation(to: touch.location(in: self), in: self);
		}
	}
	
	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.window?.endManipulation();
	}
	
}

public extension UIColor {
	
	public static let windowBarBackground = UIColor(red: 242, green: 242, blue: 242);
	
}
