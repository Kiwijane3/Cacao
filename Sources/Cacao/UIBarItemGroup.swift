//
//  UIBarGroup.swift
//  Cacao
//
//  Created by Jane Fraser on 23/04/19.
//

import Foundation

// The UIBarItemGroup is used to display groups of bar items, generally in a bar of some sort, though nothing stops it from being used elsewhere.
public class UIBarItemGroup: UIView {

	public enum Direction {
		case leftToRight
		case rightToLeft
	}
	
	// Specifies the direction the bar items are presented in; .leftToRight indicates the first item will be on the left and subsequent items will be to the right, and .rightToLeft indicates vice versa.
	public var direction: Direction = .leftToRight;
	
	public var interViewMargin: CGFloat = 8.0;
	
	public var barItems: [UIBarItem]? {
		didSet {
			createItemsAndLayout();
		}
	}
	
	public var itemViews: [UIView]?;
	
	public init() {
		super.init(frame: .zero);
		self.intrinsicSizeFitsContent = true;
	}
	
	public func createItemsAndLayout() {
		createItems();
		layout();
	}
	
	public func createItems() {
		// Remove the current item views.
		itemViews?.forEach({ (itemView) in
			itemView.removeFromSuperview();
		})
		if let barItems = barItems {
			// Create new views for each of the current bar items.
			itemViews = [UIView]();
			for barItem in barItems {
				let itemView = barItem.createView();
				self.addSubview(itemView);
				itemViews?.append(itemView);
			}
		} else {
			itemViews = nil;
		}
		setNeedsDisplay();
	}
	
	public func layout() {
		if let itemViews = itemViews {
			// Constrain all itemViews to the top margin of this view.
			itemViews.forEach { (itemView) in
				itemView.topAnchor.constraint(equalTo: self.topMarginAnchor).isActive = true;
			}
			// Get an array of item views in left-to-right order.
			let orderedViews: [UIView];
			if direction == .rightToLeft {
				orderedViews = itemViews.reversed();
			} else {
				orderedViews = itemViews;
			}
			// Now that we have the items in the correct order, lay them out using autoLayout constraints.
			if orderedViews.count > 0 {
				// Constrain the first view to the left margin of this view.
				orderedViews[0].leftAnchor.constraint(equalTo: self.leftMarginAnchor).isActive = true;
				// Constraint all subsequent view to the prior view plus a margin.
				for index in 1..<orderedViews.count {
					orderedViews[index].leftAnchor.constraint(equalTo: orderedViews[index - 1].rightAnchor, constant: interViewMargin).isActive = true;
				}
			}
			setNeedsLayout();
			setNeedsDisplay();
		}
	}
	
}
