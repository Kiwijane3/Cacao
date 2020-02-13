//
//  RootViewController.swift
//  Cacao
//
//  Created by Jane Fraser on 6/04/19.
//

import Foundation

import Cacao

public class RootViewController: UIViewController {
	
	public weak var label: UILabel?;
	
	public override func loadView() {
		self.view = UIView();
		self.view.backgroundColor = .background;
		self.headerBarItem.title = "Default";
		self.headerBarItem.rightBarItems = [
			UIBarButtonItem(title: "Dialog", style: .suggested, action: { _ in
				debugPrint("Displaying Dialog");
				let dialogController = UIPresenterController(presenting: DialogTestController());
				self.present(dialogController, animated: true, completion: nil);
			}),
			UIBarButtonItem(title: "Popover", style: .suggested, action: { (_) in
				self.showPopover();
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
	
	public func showPopover() {
		if let barItem = self.headerBarItem.rightBarItems[1] as? UIBarButtonItem {
			let popoverController = UIPresenterController(presenting: DialogTestController());
			popoverController.modalPresentationStyle = .popover;
			popoverController.popoverPresentationController?.barButtonItem = barItem;
			self.present(popoverController, animated: true, completion: nil);
		}
	}
	
}
