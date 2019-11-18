//
//  UIWindowController.swift
//  Cacao
//
//  Created by Jane Fraser on 12/04/19.
//

import Foundation

public class UIWindowController: UIViewController {
	
	public private(set) var window: UIWindow {
		get {
			return view as! UIWindow;
		}
		set {
			view = newValue;
		}
	}
	
	public private(set) var windowBar: UIWindowBar;
	
	public var rootViewController: UIViewController? {
		didSet {
			// Transition to the new controller.
			if let rootViewController = rootViewController {
				if let oldController = oldValue {
					// Transition from the old controller to the new root controller.
					addChildViewController(rootViewController);
					transition(from: oldController, to: rootViewController);
					constrainRoot();
					redisplayWindowBar();
				} else {
					// Simply install the view if there was no previous ViewController.
					installRoot();
				}
			} else {
				// Remove the previous root view if there was one.
				oldValue?.view.removeFromSuperview();
			}
		}
	}
	
	public var rootView: UIView? {
		get {
			return rootViewController?.view;
		}
	}
	
	public var verticalResizeHandle: UIWindowHandle?;
	
	public var horizontalResizeHandle: UIWindowHandle?;
	
	public var bothResizeHandle: UIWindowHandle?;
	
	public init(withRootController rootController: UIViewController, becomeKey: Bool = true) {
		self.rootViewController = rootController;
		self.windowBar = UIWindowBar();
		super.init();
		self.windowBar.windowController = self;
		self.view = UIWindow();
		self.view.addSubview(self.windowBar);
		self.windowBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true;
		self.windowBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
		self.windowBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true;
		installResizeHandles();
		installRoot();
		window.isHidden = false;
		if becomeKey {
			window.makeKey();
		}
		UIScreen.main.addWindowController(self);
		window.setNeedsLayout();
		window.setNeedsDisplay();
	}
	
	private let handleDimension: CGFloat = 20;
	
	public func installResizeHandles() {
		let horizontalResizeHandle = UIWindowHandle(forMode: .resizeWidth);
		self.horizontalResizeHandle = horizontalResizeHandle;
		horizontalResizeHandle.backgroundColor = .black;
		horizontalResizeHandle.borderColor = .black;
		horizontalResizeHandle.borderWidth = 2;
		window.addSubview(horizontalResizeHandle);
		let verticalResizeHandle = UIWindowHandle(forMode: .resizeHeight);
		self.verticalResizeHandle = verticalResizeHandle;
		verticalResizeHandle.backgroundColor = .black;
		verticalResizeHandle.borderColor = .black;
		verticalResizeHandle.borderWidth = 2;
		window.addSubview(verticalResizeHandle);
		let bothResizeHandle = UIWindowHandle(forMode: .resizeBoth);
		self.bothResizeHandle = bothResizeHandle;
		bothResizeHandle.backgroundColor = .black;
		bothResizeHandle.borderColor = .black;
		bothResizeHandle.borderWidth = 2;
		window.addSubview(bothResizeHandle);
		// Constrain the both resize handle to the lower right.
		bothResizeHandle.widthAnchor.constraint(equalTo: handleDimension).isActive = true;
		bothResizeHandle.heightAnchor.constraint(equalTo: handleDimension).isActive = true;
		bothResizeHandle.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true;
		bothResizeHandle.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true;
		// Constrain the vertical handle to the bottom of the screen, with its right aligned to the both handle's left.
		verticalResizeHandle.heightAnchor.constraint(equalTo: handleDimension).isActive = true;
		verticalResizeHandle.leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true;
		verticalResizeHandle.rightAnchor.constraint(equalTo: bothResizeHandle.leftAnchor).isActive = true;
		verticalResizeHandle.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true;
		// Constraint the horizontal handle to the right of the screen, between the window bar and the both handle.
		horizontalResizeHandle.widthAnchor.constraint(equalTo: handleDimension).isActive = true;
		horizontalResizeHandle.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true;
		horizontalResizeHandle.topAnchor.constraint(equalTo: windowBar.bottomAnchor).isActive = true;
		horizontalResizeHandle.bottomAnchor.constraint(equalTo: bothResizeHandle.topAnchor).isActive = true;
	}
	
	// Brings the resize handles to the top of the view hierarchy
	public func bringResizeHandlesForward() {
		if let horizontalResizeHandle = horizontalResizeHandle, let verticalResizeHandle = verticalResizeHandle, let bothResizeHandle = bothResizeHandle {
			window.bringSubview(toFront: horizontalResizeHandle);
			window.bringSubview(toFront: verticalResizeHandle);
			window.bringSubview(toFront: bothResizeHandle);
		}
	}
	
	/// Adds the view of the root controller to the window and constrains it as appropriate.
	public func installRoot() {
		// This function assumes that there is no root view at present; If there is, use transition() from super.
		if let rootViewController = rootViewController, let rootView = rootView {
			addChildViewController(rootViewController);
			window.addSubview(rootView);
			constrainRoot();
		}
		redisplayWindowBar();
		// Bring the resize handles forward so they display over the root view.
		bringResizeHandlesForward();
	}
	
	public func constrainRoot() {
		rootView?.leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true;
		rootView?.topAnchor.constraint(equalTo: windowBar.bottomAnchor).isActive = true;
		rootView?.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true;
		rootView?.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true;
		window.setNeedsLayout();
	}
	
	public func navigateBack() {
		if let navigationController = rootViewController as? UINavigationController {
			navigationController.popViewController(animated: true);
		}
	}
	
	public func redisplayWindowBar() {
		windowBar.windowBarItem = rootViewController?.windowBarItem;
	}
	
	public func minimise() {
		window.minimise();
	}
	
	public func maximise() {
		window.maximise();
	}
	
	public func close() {
		UIScreen.main.removeWindowController(self);
		self.window.close();
		self.window.removeFromSuperview();
	}
	
}
