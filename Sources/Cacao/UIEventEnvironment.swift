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
		
		var dispatchTouchEvent = false;
		
		for hidEvent in eventQueue {
			debugPrint(hidEvent);
            guard let event = event(for: hidEvent)
                else { handleNonUIEvent(hidEvent); continue }
           // Dispatch non-touch events immediately. Since touch events use a single event for all touches, that is only dispatched once to avoid multiple calls.
			if !(event is UITouchesEvent) {
				application.sendEvent(event);
			} else {
				dispatchTouchEvent = true;
			}
        }
        if let hidEvent = eventQueue.first {
            // print("Processed \(eventQueue.count) events (\(SDL_GetTicks() - UInt32(hidEvent.timestamp))ms)")
        }
		// Dispatch touch event.
		if dispatchTouchEvent, let touchesEvent = touchesEvent {
			application.sendEvent(touchesEvent);
			debugPrint(touchesEvent);
		}
		// Remove 
		clearStoredEvents();
        // clear queue
        eventQueue.removeAll()
    }
	
	// Remove stored events, like keyboard or touch events, that have become invalid this cycle.
	private func clearStoredEvents() {
		if touchesEvent != nil, !touchesEvent!.isLive {
			touchesEvent = nil;
		}
	}
    
	// Processes an hidEvent and returns the UIEvent to be dispatched in response, if any.
    private func event(for hidEvent: IOHIDEvent) -> UIEvent? {
        
        let timestamp = Double(hidEvent.timestamp) / 1000

		
        switch hidEvent.data {
            
        case let .touch(mouseEvent, windowLocation):
			return nil;
			
		case let .mouse(mouseEvent, windowLocation):
			return eventForPress(event: mouseEvent, at: windowLocation, time: timestamp);
			
        case let .mouseWheel(translation):
            
            let event = UIWheelEvent(timestamp: timestamp, translation: translation)
            
            return event
            
        default:
            
            return nil
        }
    }
	
	// Processes an screen input event and returns the current touchesEvent if it needs updating.
	private func eventForPress(event mouseEvent: IOHIDEvent.ScreenInputEvent, at windowLocation: CGPoint, time timestamp: Double) -> UIEvent? {
		// Establish the event, either retrieving it or creating a new one.
		// If this touch is contiguous with a live touch sequence, then update that touch sequence. Currently, the code will always update the first touch sequence, and assumes that touch is live, as an event with one ended event will be cleared at the end of the dispatch cycle. This is sufficient for mouse and single touch, but does not support multi-touch. To support multi-touch, a function that identifies which live touch sequence is appropriate.
		if let event = touchesEvent, let touch = event.liveTouches.first {
			let newPhase: UITouchPhase;
			print(mouseEvent);
			if mouseEvent == .up {
				newPhase = .ended
			} else {
				if touch.location == windowLocation {
					newPhase = .stationary
				} else {
					newPhase = .moved
				}
			}
			let nextTouch = UITouch.Touch(location: windowLocation, timestamp: timestamp, phase: newPhase);
			touch.update(nextTouch);
			print(touch);
			debugPrint("Update touch with state \(newPhase), windowLocation: \(windowLocation)");
			return event;
		} else {
			// Create a new touch.
			if mouseEvent == .down {
				let event = UITouchesEvent(timestamp: timestamp);
				touchesEvent = event;
				let view = UIApplication.shared.keyWindow?.hitTest(windowLocation, with: touchesEvent);
				let gestureRecognizers = getAllGestureRecognizers(for: view);
				// Create a new touch and add it to the event.
				let internalTouch = UITouch.Touch(location: windowLocation, timestamp: timestamp, phase: .began);
				let touch = UITouch(touch: internalTouch, inputType: .touchscreen, view: view, gestureRecognizers: gestureRecognizers);
				event.addTouch(touch);
				debugPrint("Created new touch at windowLocation: \(windowLocation)");
				debugPrint(touchesEvent);
				return event;
			}
		}
		return nil;
	}
	
	private func getAllGestureRecognizers(for view: UIView?) -> [UIGestureRecognizer] {
		var output: [UIGestureRecognizer] = []
		if let view = view {
			var target: UIView? = view;
			while target != nil && !(target is UIWindow) {
				if let recognizers = target?.gestureRecognizers {
					output.append(contentsOf: recognizers);
				}
				target = target?.superview;
			}
 		}
		return output;
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
