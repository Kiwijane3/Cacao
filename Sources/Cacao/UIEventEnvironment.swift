//
//  UIEventEnvironment.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 11/19/17.
//

import Foundation
import CoreFoundation
import SDL
import CSDL2

internal final class UIEventEnvironment {
    
    internal private(set) weak var application: UIApplication!
    
    internal private(set) var eventQueue = [IOHIDEvent]()
    
    internal var commitTimeForTouchEvents: TimeInterval = 0
    
    internal private(set) var touchesEvent: UITouchesEvent?
    
    internal private(set) var physicalKeyboardEvent: UIPhysicalKeyboardEvent?
    
    internal private(set) var wheelEvent: UIWheelEvent?
    
    internal private(set) var gameControllerEvent: UIGameControllerEvent?
    
    internal init(application: UIApplication) {
        
        self.application = application
    }
    
    internal func enqueueHIDEvent(_ event: IOHIDEvent) {
        
        eventQueue.append(event) // prepend
    }
    
    internal func handleEventQueue() {
		
        for hidEvent in eventQueue {
            guard let event = event(for: hidEvent)
                else { handleNonUIEvent(hidEvent); continue }
           // Dispatch non-touch events immediately. Since touch events use a single event for all touches, that is only dispatched once to avoid multiple calls.
           application.sendEvent(event)
        }
        if let hidEvent = eventQueue.first {
            print("Processed \(eventQueue.count) events (\(SDL_GetTicks() - UInt32(hidEvent.timestamp))ms)")
        }
		// Dispatch touch event.
        application.sendEvent(touchesEvent);
		// Remove 
		cleanStoredEvents();
        // clear queue
        eventQueue.removeAll()
    }
    
    private func event(for hidEvent: IOHIDEvent) -> UIEvent? {
        
        let timestamp = Double(hidEvent.timestamp) / 1000
        
        switch hidEvent.data {
            
        case let .touch(mouseEvent, windowLocation):
			return eventForPress(event: mouseEvent, at: windowLocation, time: timestamp);
			
			
		case let .mouse(mouseEvent, windowLocation):
			return eventForPress(event: mouseEvent, at: windowLocation, time: timestamp);
			
        case let .mouseWheel(translation):
            
            let event = UIWheelEvent(timestamp: timestamp, translation: translation)
            
            return event
            
        default:
            
            return nil
        }
    }
	
	private func eventForPress(event mouseEvent: IOHIDEvent.ScreenInputEvent, at windowLocation: CGPoint, time timestamp: Double) -> UIEvent? {
		
		// Establish the event, either retrieving it or creating a new one.
		let event: UITouchesEvent
		
		if let currentEvent = touchesEvent {
			event = currentEvent
		} else {
			event = UITouchesEvent(timestamp: timestamp)
		}
		
		// Establish the relevant touch, either by retrieving or creating it.
		let touch: UITouch;
		
		// If this touch is contiguous with a live touch sequence, then update that touch sequence. Currently, the code will always update the first touch sequence, and assumes that touch is live, as an event with one ended event will be cleared at the end of the dispatch cycle. This is sufficient for mouse and single touch, but does not support multi-touch. To support multi-touch, a function that identifies which live touch sequence is appropriate.
		if let touch = event.touches.first {
			assert(touch.phase != .ended, "Did not create new event after touches ended")
			let newPhase: UITouchPhase;
			if mouseEvent == .up {
				newPhase = .ended
			} else {
				if touch.location == screenLocation {
					newPhase = .stationary
				} else {
					newPhase = .moved
				}
			}
			let nextTouch = UITouch.Touch(location: screenLocation, timestamp: timestamp, phase: newPhase);
			touch.update(internalTouch)
		} else {
			
			guard mouseEvent == .down else { 
				debugPrint("Attempted to process new touch, but mouseEvent was not .down");
				return nil; 
			}
			// Create a new touch and add it to the event.
			let internalTouch = UITouch.Touch(location: screenLocation, timestamp: timestamp, phase: .began);
			let touch = UITouch(touch: internalTouch, inputType: .touchscreen);
			event.addTouch(touch)
		}
		return event
	}
    
    private func handleNonUIEvent(_ hidEvent: IOHIDEvent) {
        
        guard let app = self.application
            else { fatalError("\(UIApplication.self) released") }
        
        switch hidEvent.data {
            
        case .quit:
            
            app.quit()
            
        case .lowMemory:
            
            app.lowMemory()
            
        case let .window(windowEvent):
            
            switch windowEvent {
            case let .sizeChange(windowId):
				UIScreen.main.sizeChanged(id: windowId);
            case let .focusGained(windowId):
				UIScreen.main.focusGained(id: windowId);
			case let .focusLost(windowId):
				UIScreen.main.focusLost(id: windowId);
			}
            
        default:
            
            break;
        }
    }
}
