//
//  Screen.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 5/27/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import Foundation
import CSDL2
import SDL
import Silica

public final class UIScreen {
    
    public static var main: UIScreen { return _main }
    internal static var _main: UIScreen!
    
    public static var screens: [UIScreen] { return [UIScreen.main] }
    
    // MARK: - Properties
    
    public var mirrored: UIScreen? { return nil }
    
    //public private(set) var coordinateSpace: UICoordinateSpace
    
    //var fixedCoordinateSpace: UICoordinateSpace
    
	internal var windowControllers: [UIWindowController] = [UIWindowController]();
	
	internal var windows: [UIWindow] {
		get {
			return windowControllers.map({ (windowController) in
				return windowController.window;
			})
		}
	}
    
	internal private(set) weak var keyWindow: UIWindow?;
    
    // MARK: - Intialization
    
    internal init() throws {
    }
	
    /// Layout (if needed) and redraw the screen
    internal func update() throws {
		
		try windows.forEach { (window) in
			try window.update();
		}
		
    }
    
    internal func addWindowController(_ windowController: UIWindowController) {
		
		windowControllers.append(windowController);
    }
	
	internal func removeWindowController(_ windowController: UIWindowController) {
		if let index = windowControllers.firstIndex(of: windowController) {
			windowControllers.remove(at: index);
		}
		// Quit if there are no more window controllers.
		if windowControllers.count < 1 {
			UIApplication.shared.quit();
		}
	}
	
	internal func window(withId id: Int) -> UIWindow? {
		for window in windows {
			if window.id == id {
				return window;
			}
		}
		return nil;
	}
	
	internal func sizeChanged(id: Int) {
		window(withId: id)?.updateSize();
	}
	
	internal func focusGained(id: Int) {
		if let window = window(withId: id) {
			debugPrint("Window \(window) gained focused, setting key");
			setKeyWindow(window);
		}
	}
	
	internal func focusLost(id: Int) {
		// NOOP
	}
	
    internal func setKeyWindow(_ window: UIWindow) {
		
        guard UIScreen.main.keyWindow !== self
            else { return }
        
        keyWindow?.resignKey()
        keyWindow = window
        keyWindow?.becomeKey()
		keyWindow?.notifyBecameKey();
		
		debugPrint("Key window changed: Key window is now \(keyWindow)");
    }
	
}
