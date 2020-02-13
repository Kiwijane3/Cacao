//
//  UIBarGroup.swift
//  Cacao
//
//  Created by Jane Fraser on 23/04/19.
//

import Foundation

// The UIBarItemGroup is used to display groups of bar items, generally in a bar of some sort, though nothing stops it from being used elsewhere.
public class UIBarItemGroup: UIStackView {

	public enum Direction {
		case leftToRight
		case rightToLeft
	}
	
	// Specifies the direction the bar items are presented in; .leftToRight indicates the first item will be on the left and subsequent items will be to the right, and .rightToLeft indicates vice versa.
	public var direction: Direction = .leftToRight;
	
	public var barItems: [UIBarItem]? {
		didSet {
			createItems();
		}
	}
	
	public var itemViews: [UIView]?;
	
	public init() {
		super.init(frame: .zero);
		self.alignment = .center;
	}
	
	public func createItems() {
		// Remove the current item views.
		itemViews?.forEach({ (itemView) in
			itemView.removeFromSuperview();
		})
		if let barItems = barItems {
			// Remove current views.
			arrangedSubviews.forEach { (view) in
				self.removeArrangedSubview(view);
			}
			var views = barItems.compactMap { (barItem) -> UIView in
				let view: UIView = barItem.createView();
				barItem.view = view;
				return view;
			}
			if direction == .rightToLeft {
				views = views.reversed();
			}
			views.forEach { (view) in
				self.addArrangedSubview(view);
			}
		} else {
			itemViews = nil;
		}
		setNeedsLayout();
		setNeedsDisplay();
	}
	
}
