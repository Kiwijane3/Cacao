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
	
	public var isLive: Bool {
		get {
			// The event is valid if there is at least one live touch within it.
			if let allTouches = allTouches {
				for touch in allTouches {
					if touch.isLive {
						return true;
					}
				}
			}
			return false;
		}
	}
    
    internal private(set) var touches = Set<UITouch>();
	
	internal var liveTouches: Set<UITouch> {
		get {
			return touches.filter { (touch) in
				return touch.isLive;
			}
		}
	}
	
    internal func addTouch(_ touch: UITouch) {
        touches.insert(touch)
    }
}
