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
			return "All";
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
	
	private func constraintGeneric(to target: NSLayoutAnchor<AttributeType>, relatedBy relation: NSLayoutConstraint.Relation, constant: CGFloat) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.item, attribute: self.attribute, relatedBy: relation, toItem: target.item, attribute: target.attribute, multiplier: 1, constant: constant);
	}
	
	private func constraintGeneric(to target: NSLayoutAnchor<AttributeType>, relatedBy relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: relation, constant: 0);
	}
	
	public func constraint(equalTo target: NSLayoutAnchor<AttributeType>) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .equal);
	}
	
	public func constraint(equalTo target: NSLayoutAnchor<AttributeType>, constant: CGFloat) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .equal, constant: constant);
	}
	
	public func constraint(greaterThanOrEqualTo target: NSLayoutAnchor<AttributeType>) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .greaterThanOrEqual);
	}
	
	public func constraint(greaterThanOrEqualTo target: NSLayoutAnchor<AttributeType>, constant: CGFloat) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .greaterThanOrEqual, constant: constant);
	}
	
	public func constraint(lessThanOrEqualTo target: NSLayoutAnchor<AttributeType>) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .lessThanOrEqual);
	}
	
	public func constraint(lessThanOrEqualTo target: NSLayoutAnchor<AttributeType>, constant: CGFloat) -> NSLayoutConstraint {
		return constraintGeneric(to: target, relatedBy: .lessThanOrEqual, constant: constant);
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
	
}

