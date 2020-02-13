//
//  File.swift
//  
//
//  Created by Jane Fraser on 2/12/19.
//

import Foundation
import Cacao

public class DialogTestController: UIViewController {
	
	public var label: UILabel?;
	
	public override func viewDidLoad() {
		self.view = UIView();
		let label = UILabel();
		label.text = "This is a Dialog!";
		self.view.addSubview(label);
		label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
		label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true;
		self.label = label;
		headerBarItem.title = "Dialog";
		headerBarItem.rightBarItems = [
			UIBarButtonItem(title: "Close", style: .suggested, action: { (_) in
				print("Attempting to close");
				self.dismiss(animated: true, completion: nil);
			})
		];
		self.view.setNeedsLayout();
		self.view.setNeedsDisplay();
	}
	
}
