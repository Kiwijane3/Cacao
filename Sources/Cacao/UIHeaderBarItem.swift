//
//  UIWindowBar.swift
//  Cacao
//
//  Created by Jane Fraser on 17/04/19.
//

import Foundation

public class UIHeaderBarItem {
	
	public var title: String? = nil;
	
	public var showsBackButton: Bool = false;
	
	public var backAction: ((UIEvent?) -> (Void))? = nil;
	
	public var leftBarItems: [UIBarItem] = [UIBarItem]();
	
	public var rightBarItems: [UIBarItem] = [UIBarItem]();
	
	public var isEmpty: Bool {
		return title == nil && showsBackButton == false && backAction == nil && leftBarItems.isEmpty && rightBarItems.isEmpty
	}
	
}
