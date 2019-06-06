//
//  UIWindowBar.swift
//  Cacao
//
//  Created by Jane Fraser on 17/04/19.
//

import Foundation

public class UIWindowBarItem {
	
	public var title: String? = nil;
	
	public var showsBackButton: Bool = false;
	
	public var backAction: ((UIEvent?) -> (Void))? = nil;
	
	public var leftBarItems: [UIBarItem] = [UIBarItem]();
	
	public var rightBarItems: [UIBarItem] = [UIBarItem]();
	
}
