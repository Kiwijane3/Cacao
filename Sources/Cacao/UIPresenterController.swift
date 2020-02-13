//
//  UIPresentationContainerController.swift
//  
//
//  Created by Jane Fraser on 19/11/19.
//

import Foundation

// This controller contains another controller that is being presented, in order to provide a local header bar. It should be used instead of a navigationController for dialogs and popovers requiring a header bar.
public class UIPresenterController: UIViewController {

	public var presentedController: UIViewController;
	
	public var presentedView: UIView {
		get {
			return presentedController.view
		}
	}
	
	public var headerBar: UIHeaderBar?;
	
	public init(presenting presentedController: UIViewController) {
		self.presentedController = presentedController;
		super.init();
		// Attach the child view.
		self.addChildViewController(self.presentedController);
		self.modalPresentationStyle = .dialog;
	}
	
	public init(withNavigationRoot rootController: UIViewController) {
		self.presentedController = UINavigationController(rootViewController: rootController);
		super.init();
		self.addChildViewController(self.presentedController);
		self.modalPresentationStyle = .dialog;
	}
	
	public override func loadView() {
		view = UIView();
		view.borderRadius = 8;
		view.clipsToBounds = true;
		// Attach the child view.
		view.addSubview(presentedView);
		// If the view controller has specified header bar content, display a header bar.
		if !presentedController.headerBarItem.isEmpty {
			// Create the header bar and assign the header bar item.
			headerBar = UIHeaderBar(showsWindowControls: false);
			self.view.addSubview(headerBar!);
			headerBar?.headerBarItem = presentedController.headerBarItem;
			// Constrain the header bar
			headerBar?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true;
			headerBar?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true;
			headerBar?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
		}
		// Constraint child view to container.
		if let headerBar = headerBar {
			presentedView.topAnchor.constraint(equalTo: headerBar.bottomAnchor).isActive = true;
		} else {
			presentedView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
		}
		presentedView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true;
		presentedView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true;
		presentedView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true;
		view.setNeedsLayout();
		view.setNeedsDisplay();
		updatePreferredSize();
	}
	
	public func updatePreferredSize() {
		var width: CGFloat;
		if presentedController.preferredContentSize.width != UIViewNoIntrinsicMetric {
			width = presentedController.preferredContentSize.width;
		} else {
			width = 256;
		}
		var height: CGFloat;
		if presentedController.preferredContentSize.height != UIViewNoIntrinsicMetric {
			if let headerBar = headerBar {
				height = presentedController.preferredContentSize.height + headerBar.intrinsicContentSize.height;
			} else {
				height = presentedController.preferredContentSize.height;
			}
		} else {
			height = 512;
		}
		preferredContentSize = CGSize(width: width, height: height);
	}
	
}
