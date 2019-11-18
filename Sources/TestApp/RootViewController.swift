//
//  RootViewController.swift
//  Cacao
//
//  Created by Jane Fraser on 6/04/19.
//

import Foundation

import Cacao

public class RootViewController: UIViewController {
	
	public weak var label: UILabel?
	
	public override func loadView() {
		self.view = UIView();
		self.view.backgroundColor = .white;
		self.windowBarItem.title = "Root";
		self.windowBarItem.rightBarItems = [
			UIBarButtonItem(title: "Next", style: .suggested, action: { _ in
				self.showChildController();
			})
		];
		let label = UILabel();
		self.view.addSubview(label);
		self.label = label;
		self.label?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
		self.label?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true;
		self.label?.preferredMaxLayoutWidth = 256;
		self.label?.text = "This is the root view controller of a navigation controller. Press the button labelled next to have the navigation controller transition to the next view controller.";
	}
	
	private func showChildController() {
		debugPrint("Called showChildController");
	}
	
}
