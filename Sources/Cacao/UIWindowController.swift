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
	
	public init(withRootController rootController: UIViewController, becomeKey: Bool = true) {
		self.rootViewController = rootController;
		self.windowBar = UIWindowBar();
		super.init();
		self.windowBar.windowController = self;
		self.view = UIWindow();
		self.view.addSubview(self.windowBar);
		self.windowBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true;
		self.windowBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
		installRoot();
		window.isHidden = false;
		if becomeKey {
			window.makeKey();
		}
		UIScreen.main.addWindowController(self);
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
