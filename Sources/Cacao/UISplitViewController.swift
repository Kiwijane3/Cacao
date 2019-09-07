//
//  UISplitViewController.swift
//  Cacao
//
//  Created by Jane Fraser on 25/06/19.
//

import Foundation

open class UISplitViewController: UIViewController {
	
	public enum DisplayMode {
		case primaryHidden
		case allVisible
	}
	
	public weak var primaryContainerView: UIView!;
	
	public weak var detailContainerView: UIView!;
	
	public private(set) var displayMode: DisplayMode = .allVisible {
		didSet {
			switch displayMode {
			case .primaryHidden:
				if isViewLoaded {
					hidePrimary(animated: true);
				}
			case .allVisible:
				if isViewLoaded {
					displayPrimary(animated: true);
				}
			}
		}
	}
	
	private var primaryDisplayed: Bool = true {
		didSet {
			if primaryDisplayed {
				primaryDisplayConstraint?.isActive = true;
				primaryHideConstraint?.isActive = false;
				primaryContainerView.isHidden = false;
				self.view.setNeedsLayout();
				self.view.setNeedsDisplay();
			} else {
				primaryDisplayConstraint?.isActive = false;
				primaryHideConstraint?.isActive = true;
				primaryContainerView.isHidden = true;
				self.view.setNeedsLayout();
				self.view.setNeedsDisplay();
			}
		}
	}
	
	public var preferredDisplayMode: DisplayMode = .allVisible {
		didSet {
			displayMode = preferredDisplayMode;
		}
	}
	
	private var primaryDisplayConstraint: NSLayoutConstraint?;
	
	private var primaryHideConstraint: NSLayoutConstraint?;
	
	public var minimumPrimaryColumnWidth: CGFloat = 256 {
		didSet {
			minimumPrimaryWidthConstraint?.constant = minimumPrimaryColumnWidth;
		}
	}
	
	private var minimumPrimaryWidthConstraint: NSLayoutConstraint?;
	
	public var maximumPrimaryColumnWidth: CGFloat = 256 {
		didSet {
			maximumPrimaryWidthConstraint?.constant = maximumPrimaryColumnWidth;
		}
	}
	
	private var maximumPrimaryWidthConstraint: NSLayoutConstraint?;
	
	public var primaryViewController: UIViewController? {
		get {
			return viewControllers[0];
		}
		set {
			viewControllers[0] = newValue;
		}
	}
	
	public var primaryView: UIView? {
		get {
			return primaryViewController?.view;
		}
	}
	
	public var detailViewController: UIViewController? {
		get {
			return viewControllers[1];
		}
		set {
			viewControllers[1] = newValue;
		}
	}
	
	public var detailView: UIView? {
		get {
			return detailViewController?.view;
		}
	}
	
	public var viewControllers: [UIViewController?] = [nil, nil] {
		didSet {
			if viewControllers[0] == oldValue[0] {
				installPrimaryViewController();
			}
			if viewControllers[1] == oldValue[1] {
				installDetailViewController();
			}
		}
	}
	
	public init(){
		super.init();
	}
	
	public init(withPrimary primaryViewController: UIViewController) {
		super.init();
		viewControllers[0] = primaryViewController;
		installPrimaryViewController();
	}
	
	public init(withPrimary primaryViewController: UIViewController, withDetail detailViewController: UIViewController) {
		super.init();
		viewControllers[0] = primaryViewController;
		viewControllers[1] = detailViewController;
	}
	
	open override func loadView() {
		self.view = UIView();
		self.view.layoutMargins = .zero;
		let primaryContainerView = UIView();
		self.view.addSubview(primaryContainerView);
		self.primaryContainerView = primaryContainerView;		let detailContainerView = UIView();
		self.view.addSubview(detailContainerView);
		self.detailContainerView = detailContainerView;
		// Setup the constraints
		primaryContainerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
		primaryContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
		detailContainerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
		detailContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
		detailContainerView.leftAnchor.constraint(equalTo: primaryContainerView.rightAnchor).isActive = true;
		detailContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true;
		primaryDisplayConstraint = primaryContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor);
		primaryHideConstraint = primaryContainerView.rightAnchor.constraint(equalTo: self.view.leftAnchor);
		// Attach a divider view to the primaryContainer.
		// Set primary displayed based on the current display mode
		if displayMode == .allVisible {
			primaryDisplayed = true;
		} else if displayMode == .primaryHidden {
			primaryDisplayed = false;
		}
		minimumPrimaryWidthConstraint = primaryContainerView.widthAnchor.constraint(lessThanOrEqualTo: minimumPrimaryColumnWidth);
		minimumPrimaryWidthConstraint?.isActive = true;
		maximumPrimaryWidthConstraint = primaryContainerView.widthAnchor.constraint(greaterThanOrEqualTo: maximumPrimaryColumnWidth);
		maximumPrimaryWidthConstraint?.isActive = true;
		if primaryViewController != nil {
			installPrimaryViewController();
		}
		if detailViewController != nil {
			installDetailViewController();
		}
		self.view.setNeedsLayout();
	}
	
	// Hides the primary view, with optional animation.
	private func hidePrimary(animated: Bool) {
		if !animated {
			primaryDisplayed = false;
		} else {
			let animator = UIViewPropertyAnimator(duration: 0.5);
			animator.addAnimations {
				// Slide the primary container view offscreen.
				self.primaryContainerView.frame.origin.x = -self.primaryContainerView.frame.size.width;
				// Resize the detail container view to fit.
				self.detailContainerView.frame.origin.x = 0;
				self.detailContainerView.frame.size.width =	self.view.frame.size.width;
			}
			// Set primary displayed to setup the new location in the constraint system after the animation completes.
			animator.addCompletion { (_) in
				self.primaryDisplayed = false;
			}
			
			animator.startAnimation();
		}
	}
	
	private func displayPrimary(animated: Bool) {
		if !animated {
			primaryDisplayed = true;
		} else {
			let animator = UIViewPropertyAnimator(duration: 0.5);
			// Show the primary container view so it isn't invisible during the animation.
			self.primaryContainerView.isHidden = false;
			animator.addAnimations {
				// Move the primary container view onscreen.
				self.primaryContainerView.frame.origin.x = 0;
				// Resize the detail container to compensate for the primary moving onscreen.
				self.detailContainerView.frame.origin.x = self.primaryContainerView.frame.width;
				self.detailContainerView.frame.size.width = self.view.frame.width - self.primaryContainerView.frame.width;
			}
			animator.addCompletion { (_) in
				self.primaryDisplayed = true;
			}
			animator.startAnimation();
		}
	}
	
	public func installPrimaryViewController() {
		primaryContainerView.subviews.forEach { (view) in
			view.removeFromSuperview();
		}
		primaryContainerView.addSubview(primaryView!);
		primaryView?.topAnchor.constraint(equalTo: primaryContainerView.topAnchor).isActive = true;
		primaryView?.leftAnchor.constraint(equalTo: primaryContainerView.leftAnchor).isActive = true;
		primaryView?.rightAnchor.constraint(equalTo: primaryContainerView.rightAnchor).isActive = true;
		primaryView?.bottomAnchor.constraint(equalTo: primaryContainerView.bottomAnchor).isActive = true;
		primaryView!.setNeedsLayout();
		primaryContainerView.setNeedsLayout();
		primaryView!.setNeedsDisplay();
		primaryContainerView.setNeedsDisplay();
	}
	
	public func installDetailViewController() {
		detailContainerView.subviews.forEach { (view) in
			view.removeFromSuperview();
		}
		detailContainerView.addSubview(detailView!);
		detailView?.topAnchor.constraint(equalTo: detailContainerView.topAnchor).isActive = true;
		detailView?.leftAnchor.constraint(equalTo: detailContainerView.leftAnchor).isActive = true;
		detailView?.rightAnchor.constraint(equalTo: detailContainerView.rightAnchor).isActive = true;
		detailView?.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor).isActive = true;
		detailView?.setNeedsLayout();
		detailContainerView.setNeedsLayout();
		detailView?.setNeedsDisplay();
		detailContainerView.setNeedsDisplay();
	}
	
	// Installs the supplied view controller as the primary view.
	public func show(_ viewController: UIViewController, sender: Any?) {
		primaryViewController = viewController;
	}
	
	public func showDetailViewController(_ viewController: UIViewController, sender: Any?) {
		detailViewController = viewController;
	}
	
}
