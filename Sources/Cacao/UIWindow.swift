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
	
	public var windowBounds: CGRect { return CGRect(origin: .zero, size: size.window) }
	
	public var nativeBounds: CGRect { return CGRect(origin: .zero, size: size.native) }
	
	public var scale: CGFloat { return size.native.width / size.window.width }
	
	public var nativeScale: CGFloat { return scale }
	
	private var size: (window: CGSize, native: CGSize) = (window: .zero, native: .zero) {
		didSet {
			sizeChanged();
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
		
		sdlWindow = try! SDLWindow(title: options.windowName, frame: (x: .centered, y: .centered, width: Int(initialWindowSize.width), height: Int(initialWindowSize.height)), options: windowOptions);
		
		renderer = try! SDLRenderer(window: sdlWindow);
		
		super.init(frame: .zero);
		self.updateSize();
    }
	
	internal func updateSize() {
		let windowSize = sdlWindow.size;
		let size = CGSize(width: CGFloat(windowSize.width), height: CGFloat(windowSize.height));
		let rendererSize = sdlWindow.drawableSize;
		let nativeSize = CGSize(width: CGFloat(rendererSize.width), height: CGFloat(rendererSize.height));
		self.size = (size, nativeSize);
		sizeChanged();
		self.needsLayout = true;
		self.needsDisplay = true;
	}
	
	internal func sizeChanged() {
		frame = CGRect(origin: .zero, size: size.window);
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
