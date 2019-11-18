//
//  NSLayoutConstraint.swift
//  Cacao
//
//  Created by Jane Fraser on 26/11/18.
//

import Foundation

import Cassowary

public typealias UILayoutPriority = Float

public class NSLayoutConstraint: Hashable {
	
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
	
	public var uuid: UUID;
	
	/// The first object that has a property constrained by this constraint.
	public var firstItem: AnyObject? {
		didSet {
			didUpdate();
		}
	}
	
	/// The property of the first object that is constrained by this constraint.
	public var firstAttribute: NSLayoutConstraint.Attribute  {
	   didSet {
		   didUpdate();
	   }
   	}
	
	/// The second object that has a property constrained by this constraint.
	public var secondItem: AnyObject? {
	   didSet {
		   didUpdate();
	   }
   }
	
	/// The property of the second object that is constrained by this constraint.
	public var secondAttribute: NSLayoutConstraint.Attribute {
	   didSet {
		   didUpdate();
	   }
	}

	/// The relation between the constrained properties, i.e, greater than, less than, or equal.
	public var relation: Relation {
	   didSet {
		   didUpdate();
	   }
   }
	
	public var multiplier: CGFloat {
	   didSet {
		   didUpdate();
	   }
   }
	
	public var constant: CGFloat {
	   didSet {
		   didUpdate();
	   }
   }
	
	/// The priority of this constraint; i.e, how important it is to be implemented.
	public var priority: UILayoutPriority {
	   didSet {
		   didUpdate();
	   }
   }
	
	public var identifier: String?;
	
	public var shouldBeArchived: Bool;
	
	/// The view whose layout manager is responsible for satisfying this constraint;
	private var implementingView: UIView? {
		get {
			if let firstView = firstItem as? UIView {
				// If there are two views, then find the superview from those.
				if let secondView = secondItem as? UIView {
					// If one view is the superview of the other, the superview is the implementing view.
					if firstView.superview == secondView {
						return secondView;
					} else if secondView.superview == firstView {
						return firstView;
					// If neither view is the superview of the other, then return their shared superview.
					} else if firstView.superview == secondView.superview {
						return firstView.superview;
					}
					// If the views are not in a parent-child relationship and do not share a superview, then the constraint is not implemented.
					else {
						return nil;
					}
				}
				// If there is only view constrained to a constant, then the superview of the first view is the implementing view.
				else {
					return firstView.superview;
				}
			}
			return nil;
		}
	}
	
	public required init(item firstItem: Any, attribute firstAttribute: Attribute, relatedBy relation: Relation, toItem secondItem: Any?, attribute secondAttribute: Attribute, multiplier: CGFloat, constant: CGFloat, withPriority priority: UILayoutPriority = .required) {
		// TODO: Add error checking.
		self.uuid = UUID();
		self.isActive = false;
		self.firstItem = firstItem as? AnyObject;
		self.firstAttribute = firstAttribute;
		self.relation = relation;
		self.secondItem = secondItem as? AnyObject;
		self.secondAttribute = secondAttribute;
		self.multiplier = multiplier;
		self.constant = constant;
		self.priority = priority;
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
	
	public func constrains(_ object: AnyObject) -> Bool {
		if let firstItem = firstItem, object === firstItem {
			return true;
		}
		if let secondItem = secondItem, object === secondItem {
			return true;
		}
		return false;
	}
	
	private func didUpdate() {
	}
	
	public static func ==(a: NSLayoutConstraint, b: NSLayoutConstraint) -> Bool {
		return a.uuid == b.uuid;
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(uuid.hashValue);
	}
	
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

