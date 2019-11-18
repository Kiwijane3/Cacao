//
//  CGRect.swift
//  Cacao
//
//  Created by Jane Fraser on 13/01/19.
//

import Foundation

public extension CGRect {
	
	// A default CGRect for views that have their frames determined by other means, like AutoLayout.
	public static func null() -> CGRect {
		return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0));
	}
	
}
