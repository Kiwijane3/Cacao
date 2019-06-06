//
//  CGSize.swift
//  Cacao
//
//  Created by Jane Fraser on 5/04/19.
//

import Foundation

public extension CGSize {
	
	public static func +(a: CGSize, b: CGSize) -> CGSize {
		return CGSize(width: a.width + b.width, height: a.height + b.height);
	}

	public static func -(a: CGSize, b: CGSize) -> CGSize {
		return CGSize(width: a.width - b.width, height: a.height - b.height);
	}
	
	public static func +(a: CGSize, b: CGFloat) -> CGSize {
		return CGSize(width: a.width + b, height: a.height + b);
	}
	
	public static func -(a: CGSize, b: CGFloat) -> CGSize {
		return CGSize(width: a.width - b, height: a.height - b);
	}
	
}
