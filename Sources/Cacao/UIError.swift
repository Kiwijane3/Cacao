//
//  UIError.swift
//  CacaoLib
//
//  Created by Jane Fraser on 15/01/19.
//

import Foundation

public enum UIError: Error {
	case invalidConstraintError(constraint: NSLayoutConstraint, message: String);
	case invalidAnchorInitialisation(item: AnyObject, attribute: NSLayoutConstraint.Attribute, axis: String);
}
