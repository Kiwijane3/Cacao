//
//  NSLayoutConstraint.swift
//  Cacao
//
//  Created by Jane Fraser on 26/11/18.
//

import Foundation

import Cassowary

public typealias UILayoutPriority = Float

public class NSLayoutConstraint {
	
	/// Specifies the property of the target constrained by this constraint.
	public enum Attribute: Int {
		case left = 1
		case right
		case top
		case bottom
		case leading
		case trailing
		case width
		case height
		case centerX
		case centerY
		case lastBaseline
		case firstBaseline
		case leftMargin
		case rightMargin
		case topMargin
		case bottomMargin
		case leadingMargin
		case trailingMargin
		case centerXWithinMargins
		case centerYWithinMargins
		case notAnAttribute
	}
	
	/// Describes the relationship between the constrained properties. Case names should be fairly self explanatory.
	public enum Relation {
		case lessThanOrEqual
		case equal
		case greaterThanOrEqual
	}
	
	public enum Axis {
		case horizontal
		case vertical
		case dimension
	}
	
	public static func activate(_ constraints: [NSLayoutConstraint]) {
		for constraint in constraints {
			constraint.isActive = true;
		}
	}
	
	public static func deactivate(_ constraints: [NSLayoutConstraint]) {
		for constraint in constraints {
			constraint.isActive = false;
		}
	}
	
	public required init(item firstItem: Any, attribute firstAttribute: Attribute, relatedBy relation: Relation, toItem secondItem: Any?, attribute secondAttribute: Attribute, multiplier: CGFloat, constant: CGFloat) {
		// TODO: Add error checking.
		self.isActive = false;
		self.firstItem = firstItem as? AnyObject;
		self.firstAttribute = firstAttribute;
		self.relation = relation;
		self.secondItem = secondItem as? AnyObject;
		self.secondAttribute = secondAttribute;
		self.multiplier = multiplier;
		self.constant = constant;
		self.priority = UILayoutPriority.required;
		self.identifier = nil;
		self.shouldBeArchived = false;
	}
	
	public var isActive: Bool {
		didSet {
			// Only update if there is a change.
			if isActive != oldValue {
				// If there is a superview, add or remove the constraint to it, depending on whether the constraint has been activated or deactivated, respectively.
				if let superview = (firstItem as? UIView)?.superview {
					if isActive {
						superview.addConstraint(self);
					} else {
						superview.removeConstraint(self);
					}
				}
			}
		}
	}
	
	/// The first object that has a property constrained by this constraint.
	public var firstItem: AnyObject?;
	
	/// The property of the first object that is constrained by this constraint.
	public var firstAttribute: NSLayoutConstraint.Attribute;
	
	/// The second object that has a property constrained by this constraint.
	public var secondItem: AnyObject?;
	
	/// The property of the second object that is constrained by this constraint.
	public var secondAttribute: NSLayoutConstraint.Attribute;
	
	/// The relation between the constrained properties, i.e, greater than, less than, or equal.
	public var relation: Relation;
	
	public var multiplier: CGFloat;
	
	public var constant: CGFloat;
	
	/// Apparently, there are "Anchors" in the UIKit implementation. I don't know what they do or how to do it, so I've left them unimplemented.
	
	/// The priority of this constraint; i.e, how important it is to be implemented.
	public var priority: UILayoutPriority;
	
	public var identifier: String?;
	
	public var shouldBeArchived: Bool;
	
}

// Defines priority constants.
public extension UILayoutPriority {
	
	public static let required: UILayoutPriority = 1000;
	// TODO: Validate that these values work well.
	public static let defaultHigh: UILayoutPriority = 750;
	public static let defaultLow: UILayoutPriority = 500;
	public static let fittingSizeLevel: UILayoutPriority = 250;
	
}

public extension NSLayoutConstraint.Attribute {
	
	public var axis: NSLayoutConstraint.Axis? {
		get {
			switch self {
		case .left, .right, .leading, .trailing, .centerX, .leftMargin, .rightMargin, .leadingMargin, .trailingMargin, .centerXWithinMargins:
				return .horizontal;
			case .top, .bottom, .centerY, .lastBaseline, .firstBaseline, .topMargin, .bottomMargin, .centerYWithinMargins:
				return .vertical;
			case .width, .height:
				return .dimension
			default:
				return nil;
			}
		}
	}
	
}

public extension NSLayoutConstraint.Axis {
	
	public var description: String {
		get {
			switch self {
			case .horizontal:
				return "X";
			case .vertical:
				return "Y";
			case .dimension:
				return "Dimension";
			}
		}
	}
	
}

