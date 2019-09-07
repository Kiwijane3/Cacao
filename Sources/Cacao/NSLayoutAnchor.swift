//
//  NSLayoutAnchor.swift
//  CacaoLib
//
//  Created by Jane Fraser on 14/01/19.
//

import Foundation

// A series of protocol types that exist purely to specify anchor types.

public protocol Attribute {}

public class XAxisAttribute: Attribute {}

public class YAxisAttribute: Attribute {}

public class Dimension: Attribute {}

public class NSLayoutAnchor<AttributeType: Attribute>{
	
	// The axis for the given anchor class. Used for debug information.
	public var axis: String {
		get {
			return attribute.axis?.description ?? "Missing axis description";
		}
	}
	
	// The view of the variable that this anchor represents.
	public unowned let item: AnyObject;
	
	public let attribute: NSLayoutConstraint.Attribute;
	
	fileprivate init(for attribute: NSLayoutConstraint.Attribute, on item: AnyObject, axis: NSLayoutConstraint.Axis) throws {
		if attribute.axis == axis {
			self.item = item;
			self.attribute = attribute;
		} else {
			throw UIError.invalidAnchorInitialisation(item: item, attribute: attribute, axis: axis.description);
		}
	}
	
	private func constraintGeneric(to target: NSLayoutAnchor<AttributeType>, relatedBy relation: NSLayoutConstraint.Relation, constant: CGFloat, multiplier: CGFloat, withPriority priority: UILayoutPriority) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.item, attribute: self.attribute, relatedBy: relation, toItem: target.item, attribute: target.attribute, multiplier: multiplier, constant: constant, withPriority: priority);
	}
	
	public func constraint(equalTo target: NSLayoutAnchor<AttributeType>, constant: CGFloat = 0, multiplier: CGFloat = 1, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .equal, constant: constant, multiplier: multiplier, withPriority: priority);
	}
	
	public func constraint(greaterThanOrEqualTo target: NSLayoutAnchor<AttributeType>, constant: CGFloat = 0, multiplier: CGFloat = 1, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .greaterThanOrEqual, constant: constant, multiplier: multiplier, withPriority: priority);
	}
	
	public func constraint(lessThanOrEqualTo target: NSLayoutAnchor<AttributeType>, constant: CGFloat = 0, multiplier: CGFloat = 1, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .lessThanOrEqual, constant: constant, multiplier: multiplier, withPriority: priority);
	}

}

public class NSLayoutXAxisAnchor: NSLayoutAnchor<XAxisAttribute> {
	
	internal init(for attribute: NSLayoutConstraint.Attribute, on item: AnyObject) throws {
		try super.init(for: attribute, on: item, axis: .horizontal);
	}
	
}

public class NSLayoutYAxisAnchor: NSLayoutAnchor<YAxisAttribute> {
	
	internal init(for attribute: NSLayoutConstraint.Attribute, on item: AnyObject) throws {
		try super.init(for: attribute, on: item, axis: .vertical);
	}
	
}

public class NSLayoutDimension: NSLayoutAnchor<Dimension> {

	internal init(for attribute: NSLayoutConstraint.Attribute, on item: AnyObject) throws {
		try super.init(for: attribute, on: item, axis: .dimension);
	}
	
	public func constraint(equalTo constant: CGFloat, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.item, attribute: self.attribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant, withPriority: priority);
	}
	
	public func constraint(lessThanOrEqualTo constant: CGFloat, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.item, attribute: self.attribute, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant, withPriority: priority);
	}
	
	public func constraint(greaterThanOrEqualTo constant: CGFloat, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.item, attribute: self.attribute, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant, withPriority: priority);
	}
	
}

