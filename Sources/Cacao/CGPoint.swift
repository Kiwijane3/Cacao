//
//  CGPoint.swift
//  Cacao
//
//  Created by Jane Fraser on 7/04/19.
//

import Foundation

public extension CGPoint {

	static public func +(left: CGPoint, right: CGPoint) -> CGPoint {
		return CGPoint(x: left.x + right.x, y: left.y + right.y);
	}

	static public func -(left: CGPoint, right: CGPoint) -> CGPoint {
		return CGPoint(x: left.x - left.x, y: right.y - right.y);
	}

	static public func *(left: CGPoint, right: CGFloat) -> CGPoint {
		return CGPoint(x: left.x * right, y: left.y * right);
	}

	static public func /(left: CGPoint, right: CGFloat) -> CGPoint {
		return CGPoint(x: left.x / right, y: left.y / right);
	}

}
