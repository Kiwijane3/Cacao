//
//  IOHIDEvent.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 11/24/17.
//

import Foundation
import CSDL2
import SDL

internal struct IOHIDEvent {
    
    let timestamp: UInt
    
    private(set) var data: Data
    
    init?(sdlEvent: inout SDL_Event) {
        
        self.timestamp = UInt(sdlEvent.common.timestamp)
        
        let eventType = SDL_EventType(rawValue: sdlEvent.type)
        
        switch eventType {
            
        case SDL_QUIT,
             SDL_APP_TERMINATING:
            
            self.data = .quit
            
        case SDL_FINGERDOWN,
             SDL_FINGERUP,
             SDL_FINGERMOTION:
            
            let screenEvent: ScreenInputEvent
            
            switch eventType {
            case SDL_FINGERDOWN: screenEvent = .down
            case SDL_FINGERUP: screenEvent = .up
            case SDL_FINGERMOTION: screenEvent = .motion
            default: return nil
            }
            
			// The sdl event components are given relative to the current window, not the screen.
			let windowLocation = CGPoint(x: CGFloat(sdlEvent.tfinger.x),
										 y: CGFloat(sdlEvent.tfinger.y))
            
            self.data = .touch(screenEvent, windowLocation);
            
        case SDL_MOUSEBUTTONDOWN,
             SDL_MOUSEBUTTONUP,
             SDL_MOUSEMOTION:
			
            // dont translate touch screen events.
            guard sdlEvent.button.which != Uint32(bitPattern: -1)
                else { return nil }
			
            let screenEvent: ScreenInputEvent
            switch eventType {
            case SDL_MOUSEBUTTONDOWN: screenEvent = .down
            case SDL_MOUSEBUTTONUP: screenEvent = .up
            case SDL_MOUSEMOTION: screenEvent = .motion
            default: return nil
            }
			// The sdl event components are given relative to the current window, not the screen.
			let windowLocation: CGPoint;
			// Attempt to read the windowLocation.
			switch eventType {
			case SDL_MOUSEBUTTONDOWN, SDL_MOUSEBUTTONUP:
				let mouseButtonEvent = sdlEvent.button;
				windowLocation = CGPoint(x: CGFloat(mouseButtonEvent.x), y: CGFloat(mouseButtonEvent.y));
			case SDL_MOUSEMOTION:
				let mouseMotionEvent = sdlEvent.motion;
				windowLocation = CGPoint(x: CGFloat(mouseMotionEvent.x), y: CGFloat(mouseMotionEvent.y));
			default: return nil;
			}
            self.data = .mouse(screenEvent, windowLocation);
            
        case SDL_MOUSEWHEEL:
            
            let translation = CGSize(width: CGFloat(sdlEvent.wheel.x),
                                     height: CGFloat(sdlEvent.wheel.y))
            
            self.data = .mouseWheel(translation)
            
        case SDL_WINDOWEVENT:
			
			
			
            let sdlWindowEvent = SDL_WindowEventID(rawValue: SDL_WindowEventID.RawValue(sdlEvent.window.event))
			
			let windowId = sdlEvent.window.windowID;
			
            let windowEvent: WindowEvent
            
            switch sdlWindowEvent {
			case SDL_WINDOWEVENT_SIZE_CHANGED: windowEvent = .sizeChange(windowId: Int(windowId));
			case SDL_WINDOWEVENT_FOCUS_GAINED: windowEvent = .focusGained(windowId: Int(windowId));
			case SDL_WINDOWEVENT_FOCUS_LOST: windowEvent = .focusLost(windowId: Int(windowId));
            default: return nil
            }
            
            self.data = .window(windowEvent)
            
        case SDL_APP_LOWMEMORY:
            
            self.data = .lowMemory
            
            /*
        case SDL_KEYUP,
             SDL_KEYDOWN:
            
            let state: KeyState
            
            switch Int32(sdlEvent.key.state) {
                
            case SDL_PRESSED:
                state = .pressed
                
            case SDL_RELEASED:
                state = .released
                
            default:
                fatalError("Invalid key state \(sdlEvent.key.state)")
            }
            
            sdlEvent.key.keysym.keyCode
            */
        default:
            
            return nil
        }
    }
	
    /// Merge the data if an event into another
    func merge(event: IOHIDEvent) -> IOHIDEvent? {
        
        switch (self.data, event.data) {
            
        case (.quit, .quit):
            return event
            
        case let (.touch(lhsEvent, _), .touch(rhsEvent, _)):
            return lhsEvent == rhsEvent ? event : nil
            
        case let (.mouse(lhsEvent, _), .mouse(rhsEvent, _)):
            return lhsEvent == rhsEvent ? event : nil
            
        case (.window(_), .window(_)):
            return nil
            
        case let (.mouseWheel(lhsTranslation), .mouseWheel(rhsTranslation)):
            
            var mergedEvent = event
            
            let size = CGSize(width: lhsTranslation.width + rhsTranslation.width,
                              height: lhsTranslation.height + rhsTranslation.height)
            
            // update data
            mergedEvent.data = .mouseWheel(size)
            
            return mergedEvent
            
        default:
            
            return nil
        }
    }
}

internal extension IOHIDEvent {
    
    enum Data {
        
        case quit
        case mouse(ScreenInputEvent, CGPoint)
        case mouseWheel(CGSize)
        case touch(ScreenInputEvent, CGPoint)
        case window(WindowEvent)
        case lowMemory
    }
    
    enum ScreenInputEvent {
        
        case down
        case up
        case motion
    }
    
    enum WindowEvent {
        
		case sizeChange(windowId: Int)
		case focusGained(windowId: Int)
		case focusLost(windowId: Int)
    }
    
    enum KeyState {
        
        case pressed
        case released
    }
}
