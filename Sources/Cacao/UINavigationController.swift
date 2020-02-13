//
//  UINavigationController.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 6/12/17.
//

import Foundation

open class UINavigationController: UIViewController {
    
	public var viewControllers: [UIViewController] {
		willSet {
			// Remove the previous view controllers from this controller.
			for viewController in viewControllers {
				viewController.removeFromParentViewController();
			}
		}
		didSet {
			for viewController in viewControllers {
				addChildViewController(viewController);
			}
		}
	}
	
	public var topViewController: UIViewController? {
		get {
			return viewControllers.last;
		}
	}
	
	public var topView: UIView? {
		get {
			return topViewController?.view;
		}
	}
	
	public var visibleViewControllers: UIViewController? {
		get {
			// TODO; This should return the presented view controller if a view is currently presented modally, so set that up once modal presentation is properly done.
			return topViewController;
		}
	}
	
	public override var headerBarItem: UIHeaderBarItem {
		get {
			return topViewController?.headerBarItem ?? UIHeaderBarItem();
		}
		set {
			topViewController?.headerBarItem = newValue;
		}
	}
	
	public init(rootViewController: UIViewController) {
		viewControllers = [UIViewController]();
		viewControllers.append(rootViewController);
		super.init();
		addChildViewController(rootViewController);
	}
	
	open override func loadView() {
		self.view = UIView();
		self.view.backgroundColor = .white;
		if let topView = topView {
			self.view.addSubview(topView);
			constrainMainView();
		}
	}
	
	// Constrains the topViewController's root view to the appropriate view area, and triggers a new layout pass.
	public func constrainMainView() {
		topView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
		topView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true;
		topView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true;
		topView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true;
		self.view.setNeedsLayout();
		topView?.setNeedsLayout();
	}
	
	public func pushViewController(_ viewController: UIViewController, animated: Bool) {
		viewControllers.append(viewController);
		addChildViewController(viewController);
		if viewControllers.count == 1 {
			view.addSubview(topViewController!.view);
		} else {
			// Create a push animator.
			let pushAnimator = UIViewPropertyAnimator(duration: 0.5);
			let newView = viewController.view;
			pushAnimator.addSetup {
				// Set the size of the new view to the size of the container and position it to the right side of the container.
				newView?.frame.size = self.view.frame.size;
				newView?.frame.origin.x = self.view.frame.size.width;
				newView?.frame.origin.y = 0;
			};
			pushAnimator.addAnimations {
				// Move the new view to fit in the container.
				newView?.frame.origin.x = 0;
			};
			pushAnimator.addCompletion { (_) in
				self.constrainMainView();
				self.updateHeaderBar();
			};
			transition(from: viewControllers[viewControllers.count - 2], to: topViewController!, withAnimator: pushAnimator);
		}
	}
	
	private func performPopTransition(from origin: UIViewController, to target: UIViewController, animated: Bool) {
		// Setup the animator.
		let popAnimator = UIViewPropertyAnimator(duration: 0.5);
		let newView = target.view;
		popAnimator.addSetup {
			// Set the size of the new view to the size of the container and position it to the left side of the container.
			newView?.frame.size = self.view.frame.size;
			newView?.frame.origin.x = -self.view.frame.size.width;
			newView?.frame.origin.y = 0;
		};
		popAnimator.addAnimations {
			// Move the new view to fit in the container
			newView?.frame.origin.x = 0;
		}
		popAnimator.addCompletion { (_) in
			self.constrainMainView();
			self.updateHeaderBar();
		}
		// Perform the transition with the animator.
		transition(from: origin, to: target, withAnimator: popAnimator);
	}
	
	public func popViewController(animated: Bool) -> UIViewController? {
		if viewControllers.count > 1 {
			let originController = viewControllers.removeLast();
			performPopTransition(from: originController, to: topViewController!, animated: animated);
			originController.removeFromParentViewController();
			return originController;
		} else {
			return nil;
		}
	}
	
	public func popToViewController(_ target: UIViewController, animated: Bool) -> [UIViewController]? {
		if let targetIndex = viewControllers.firstIndex(of: target), targetIndex != 0 {
			performPopTransition(from: topViewController!, to: target, animated: animated);
			let removedViewControllers = [UIViewController](viewControllers[targetIndex...]);
			removedViewControllers.forEach { (controller) in
				controller.removeFromParentViewController();
			}
			viewControllers = [UIViewController](viewControllers[...(targetIndex + 1)]);
			return removedViewControllers;
		} else {
			return nil;
		}
	}
	
	public func popToRootViewController(animated: Bool) -> [UIViewController]? {
		if viewControllers.count > 1 {
			return popToViewController(viewControllers[0], animated: animated);
		} else {
			return nil;
		}
	}
	
}


