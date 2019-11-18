//
//  UIWindow.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 6/7/17.
//

import Foundation
import Silica

import SDL
import CSDL2

/// An object that provides the backdrop for your app’s user interface and provides important event-handling behaviors.
open class UIWindow: UIView {
    
    // MARK: - Properties
    
    /// The screen on which the window is displayed.
    public final var screen: UIScreen = UIScreen.main
    
    /// The position of the window in the z-axis.
    public final var windowLevel: UIWindowLevel = UIWindowLevelNormal
    
    /// A Boolean value that indicates whether the window is the key window for the app.
    public final var isKeyWindow: Bool { return UIApplication.shared.keyWindow === self }
	
	public var windowController: UIWindowController? {
		get {
			return viewController as? UIWindowController;
		}
	}

	public final var sdlWindow: SDLWindow;
	
	public final var id: Int {
		get {
			return Int(sdlWindow.identifier);
		}
	}
	
	public var scale: CGFloat { return nativeSize.width / windowSize.width }
	
	public var nativeScale: CGFloat { return scale }
	
	// The size of the windows, in UI units.
	public var windowSize: CGSize {
		get {
			let sdlSize = sdlWindow.size;
			return CGSize(width: CGFloat(sdlSize.width), height: CGFloat(sdlSize.height));
		}
		set(size) {
			sdlWindow.size = (width: Int(size.width), height: Int(size.height));
			updateSize();
		}
	}
	
	// The size of the window, in pixels, as given by the renderer size property on the underlying SDL window.
	public var nativeSize: CGSize {
		get {
			let drawableSize = sdlWindow.drawableSize
			return CGSize(width: CGFloat(drawableSize.width), height: CGFloat(drawableSize.height));
		}
	}
	
	private var position: CGPoint {
		get {
			let position = sdlWindow.position;
			return CGPoint(x: position.x, y: position.y);
		}
		set {
			sdlWindow.position = (Int(newValue.x), Int(newValue.y));
		}
	}
	
	internal let renderer: SDLRenderer;
    
    // MARK: - Initialization
    
    public init() {
		// Generate the underlying SDL Window.
		// Get the options from the shared application.
		let options = UIApplication.shared.options;
		
		var windowOptions: BitMaskOptionSet<SDLWindow.Option> = [.allowRetina, .opengl];
		
		if options.canResizeWindow {
			windowOptions.insert(.resizable);
		}
		
		let initialWindowSize = options.windowSize;
		
		debugPrint()
		
		sdlWindow = try! SDLWindow(title: options.windowName, frame: (x: .centered, y: .centered, width: Int(initialWindowSize.width), height: Int(initialWindowSize.height)), options: windowOptions);
		
		renderer = try! SDLRenderer(window: sdlWindow);
		
		
		super.init(frame: .zero);
		self.backgroundColor = .background;
		self.updateSize();
    }
	
	internal func updateSize() {
		sizeChanged();
		self.setNeedsLayout();
		self.setNeedsDisplay();
	}
	
	internal func sizeChanged() {
		frame = CGRect(origin: .zero, size: windowSize);
	}
	
	internal func update() throws {
		if needsLayout {
			
			defer {
				needsLayout = false;
			}
			
			self.layoutIfNeeded();
			
			needsDisplay = true;
			
		}
		
		if needsDisplay {
			
			defer {
				needsDisplay = false;
			}
			
			try renderer.clear();
			
			try render(view: self);
			
			renderer.present();
			
		}
		
	}
	
	private func render(view: UIView, origin: CGPoint = .zero) throws {
		
		guard view.shouldRender
			else { return }
		
		// add translation
		//context.translate(x: view.frame.x, y: view.frame.y)
		var relativeOrigin = origin
		relativeOrigin.x += (view.frame.origin.x + (view.superview?.bounds.origin.x ?? 0.0)) * scale
		relativeOrigin.y += (view.frame.origin.y + (view.superview?.bounds.origin.y ?? 0.0)) * scale
		
		// frame of view relative to SDL window
		let rect = SDL_Rect(x: Int32(relativeOrigin.x),
							y: Int32(relativeOrigin.y),
							w: Int32(view.bounds.size.width * scale),
							h: Int32(view.bounds.size.height * scale))
		
		let scale = self.scale;
		
		// render view
		try view.render(on: self, in: rect)
		
		// render subviews
		try view.subviews.forEach { try render(view: $0, origin: relativeOrigin) }
	}
	
    // MARK: - Methods
    
    /// Shows the window and makes it the key window.
    public final func makeKeyAndVisible() {
        
        makeKey()
        
        isHidden = false
    }
    
    /// Makes the receiver the key window.
    public final func makeKey() {
        
        UIScreen.main.setKeyWindow(self)
    }
	
	/// Converts a position in the window into a position into the screen space.
	public func convertToScreen(_ windowPoint: CGPoint) -> CGPoint {
		// Simply add the screen position to the point.
		return windowPoint + self.position;
	}
	
	public func convertToScreen(_ point: CGPoint, from view: UIView) -> CGPoint {
		// Convert the point from the view's coordinate space to the window's space.
		let windowPoint = view.convert(point, to: self);
		// Return the screen position for the windowPoint.
		return convertToScreen(windowPoint);
	}
    
	internal func notifyBecameKey() {
		self.setNeedsLayout();
		self.setNeedsDisplay();
	}
	
    /// Called automatically to inform the window that it has become the key window.
    open func becomeKey() { /* subclass implementation */ }
    
    /// Called automatically to inform the window that it is no longer the key window.
    open func resignKey() { /* subclass implementation */ }
    
    /// last touch event, used for scrolling
    private var lastTouchEvent: UITouchesEvent?
    
    /// Dispatches the specified event to its views.
    public final func sendEvent(_ event: UIEvent) {
        
        let gestureEnvironment = UIApplication.shared.gestureEnvironment
        
        // handle touches event
        if let touchesEvent = event as? UITouchesEvent {
            
            // send touches to gesture recognizers
            gestureEnvironment.updateGestures(for: event, window: self)
            
            // send touches directly to views (legacy API)
            sendTouches(for: touchesEvent)
            
            // cache event
            lastTouchEvent = touchesEvent
        }
        // handle presses
        else if let pressesEvent = event as? UIPressesEvent {
            
            guard isUserInteractionEnabled else { return }
            
            gestureEnvironment.updateGestures(for: event, window: self)
            
            sendButtons(for: pressesEvent)
            
        } else if let moveEvent = event as? UIMoveEvent {
            // TODO: Implement self.focusResponder
            /*
            if let focusResponder = self.focusResponder {
                
                moveEvent.sendEvent(to: focusResponder)
            }*/
            
        } else if let wheelEvent = event as? UIWheelEvent {
            
            guard isUserInteractionEnabled else { return }
            
            guard let touchEvent = lastTouchEvent,
                let touch = touchEvent.touches.first,
                touch.phase == .moved,
                let view = touch.view
                else { return }
            
            wheelEvent.sendEvent(to: view)
        
        } else if let responderEvent = event as? UIResponderEvent {
            
            if let responder = self.firstResponder {
                
                responderEvent.sendEvent(to: responder)
            }
            
        } else {
            
            fatalError("Event not handled \(event)")
        }
    }
    
    // MARK: - UIResponder
    
    internal var _firstResponder: UIResponder?
    
    internal override var firstResponder: UIResponder? {
        
        return _firstResponder
    }
    
    /*
    internal override var firstResponder: UIResponder? {
        
        if let fieldEditor = _firstResponder as? UIFieldEditor {
            
            return fieldEditor.proxiedView
            
        } else {
            
            return _firstResponder
        }
    }*/
    
    public final override var next: UIResponder? {
        
        return UIApplication.shared
    }
    
    public final override func becomeFirstResponder() -> Bool {
		
		// Make the window's root view controller the first responder if possible.
		guard let windowController = viewController as? UIWindowController,
			let rootController = windowController.rootViewController,
			rootController.becomeFirstResponder()
		else {
			return super.becomeFirstResponder()
		}
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func sendTouches(for event: UITouchesEvent) {
        let touches = event.touches
        for touch in touches {
			debugPrint("Touch at \(touch.location()), view was \(touch.view)");
            switch touch.phase {
            case .began: touch.view?.touchesBegan(touches, with: event)
            case .moved: touch.view?.touchesMoved(touches, with: event)
            case .stationary: break
            case .ended: touch.view?.touchesEnded(touches, with: event)
            case .cancelled: touch.view?.touchesCancelled(touches, with: event)
            }
        }
    }
    
    private func sendButtons(for event: UIPressesEvent) {
		for press in event.allPresses {
			switch press.phase {
			case .began:
				firstResponder?.pressBegan(press, with: event);
			case .changed:
				firstResponder?.pressChanged(press, with: event);
			case .ended:
				firstResponder?.pressEnded(press, with: event);
			case .cancelled:
				firstResponder?.pressCancelled(press, with: event);
			case .stationary:
				break;
			}
		}
    }
    
    internal override var responderWindow: UIWindow? {
        
        return self
    }
	
	public func minimise() {
		sdlWindow.minimise();
	}
	
	public func maximise() {
		sdlWindow.maximise();
	}
	
	public func close() {
		sdlWindow.close();
	}
	
	// MARK: - Window movement and resizing;
	
	/// Store the initial size and position so we have a reference point for applying deltas.
	
	private var manipulationMode: ManipulationMode?;
	
	private var initialPosition: CGPoint?;

	private var initialSize: CGSize?;
	
	// The position of the cursor in the window space at the beginning of the manipulation
	private var initialCursorPosition: CGPoint?;
	
	public enum ManipulationMode {
		case move
		case resizeWidth
		case resizeHeight
		case resizeBoth
	}
	
	/// Records the position and size of the window so manipulations can be performed.
	public func beginManipulation(withMode mode: ManipulationMode, at point: CGPoint, in view: UIView) {
		self.manipulationMode = mode;
		self.initialPosition = self.position;
		self.initialSize = self.bounds.size;
		self.initialCursorPosition = self.convertToScreen(point, from: view);
		debugPrint("Beginning manipulation \(self.manipulationMode) with initial cursor position \(initialCursorPosition), window position: \(self.initialPosition)");
		// Capture mouse input so we can track changes outside of the window, to prevent abrupt dragging stop if cursor leaves window.
		sdlWindow.mouseCaptured = true;
	}
	
	public func updateManipulation(to point: CGPoint, in view: UIView) {
		if let manipulationMode = manipulationMode, let initialPosition = initialPosition, let initialSize = initialSize, let initialCursorPosition = initialCursorPosition {
			let currentPosition = self.convertToScreen(point, from: view);
			let xDelta = currentPosition.x - initialCursorPosition.x;
			let yDelta = currentPosition.y - initialCursorPosition.y;
			debugPrint("Updated window manipulation with cursor position \(currentPosition), deltas of x: \(xDelta), y: \(yDelta). Initial position: \(initialCursorPosition)");
			switch manipulationMode {
			case .move:
				let targetPosition = CGPoint(x: initialPosition.x + xDelta, y: initialPosition.y + yDelta);
				debugPrint("Attempting to move window to position: \(targetPosition)")
				self.position = targetPosition;
			case .resizeWidth:
				self.windowSize = CGSize(width: initialSize.width + xDelta, height: initialSize.height);
			case .resizeHeight:
				self.windowSize = CGSize(width: initialSize.width, height: initialSize.height + yDelta);
			case .resizeBoth:
				self.windowSize = CGSize(width: initialSize.width + xDelta, height: initialSize.height + yDelta);
			}
			debugPrint("Window position at: \(position)");
		}
	}
	
	public func endManipulation() {
		self.manipulationMode = nil;
		self.initialPosition = nil;
		self.initialSize = nil;
		self.initialCursorPosition = nil;
		// Uncapture the mouse so other windows can receive events.
		sdlWindow.mouseCaptured = false;
		try? update();
	}
	
}

// MARK: - Supporting Types

/// The positioning of windows relative to each other.
///
/// The stacking of levels takes precedence over the stacking of windows within each level.
/// That is, even the bottom window in a level obscures the top window of the next level down.
/// Levels are listed in order from lowest to highest.
public typealias UIWindowLevel = CGFloat

/// The default level. Use this level for the majority of your content, including for your app’s main window.
public let UIWindowLevelNormal: UIWindowLevel = 0

/// The level for an alert view. Windows at this level appear on top of windows at the UIWindowLevelNormal level.
public let UIWindowLevelAlert: UIWindowLevel = 2000

/// The level for a status window. Windows at this level appear on top of windows at the UIWindowLevelAlert level.
public let UIWindowLevelStatusBar: UIWindowLevel = 1000
