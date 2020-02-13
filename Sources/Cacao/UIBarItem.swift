//
//  UIBarItem.swift
//  Cacao
//
//  Created by Jane Fraser on 16/04/19.
//

import Foundation

// A generic protocol for all bar items.
open class UIBarItem {
	
	// The "title" to associated with the bar item. The precise use varies based on bar item subclass.
	public var title: String?;
	
	// The image associated with the bar item. The precise use varies based on bar item subclass.
	public var image: UIImage?;
	
	// The view representing this bar item. Used primarily for popover display.
	internal var view: UIView?;
	
	public init(title: String? = nil, image: UIImage? = nil) {
		self.title = title;
		self.image = image;
	}
	
	public func createView() -> UIView {
		return UIView();
	}
	
}

public class UIBarButtonItem: UIBarItem {
	
	public typealias Style = UIButton.ButtonType;
	
	public var action: ((UIEvent?) -> (Void))?;
	
	public var style: Style = .plain;
	
	public init(title: String?, style: Style = .plain, action: @escaping (UIEvent?) -> ()) {
		self.style = style;
		self.action = action;
		super.init(title: title);
	}
	
	public init(title: String?, style: Style = .plain) {
		self.style = style;
		self.action = nil;
		super.init(title: title);
	}
	
	public override func createView() -> UIView {
		let button = UIButton();
		button.setTitle(title, for: .normal);
		if let action = action {
			button.add(withId: "barItemDefault", action: action, for: .touchUpInside);
		}
		button.buttonType = style;
		return button;
	}
	
}
