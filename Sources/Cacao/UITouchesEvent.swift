//
//  UITouchesEvent.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 11/19/17.
//

import Foundation

internal final class UITouchesEvent: UIEvent {
    
    public override var type: UIEventType { return .touches }
    
    public override var allTouches: Set<UITouch>? { return touches }
	
	public var isValid: Bool {
		get {
			// The event is valid if there is at least on valid touch within it.
			if let allTouches = allTouches {
				for touch in allTouches {
					if touch.isValid {
						return true;
					}
				}
			}
			return false;
		}
	}
    
    internal private(set) var touches = Set<UITouch>();
	
    internal func addTouch(_ touch: UITouch) {
        touches.insert(touch)
    }
}
