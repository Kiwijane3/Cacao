//
//  WindowBarTestController.swift
//  CacaoPackageDescription
//
//  Created by Jane Fraser on 6/09/19.
//

import Foundation
import Cacao

public class WindowBarTestController: UIViewController {
	
	public var label: UILabel?;
	
	public override func loadView() {
		self.view = UIView();
		let label = UILabel();
		self.view.addSubview(label);
		self.label = label;
		self.label?.text = "This is a test controller for the window bar and window bar item API";
		self.label?.preferredMaxLayoutWidth = 256;
		self.label?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
		self.label?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true;
		self.windowBarItem.showsBackButton = true;
		self.windowBarItem.rightBarItems = [UIBarButtonItem(title: "Normal", style: .plain), UIBarButtonItem(title: "Suggested", style: .suggested)];
		self.windowBarItem.leftBarItems = [UIBarButtonItem(title: "Cancel", style: .destructive)];
		self.windowBarItem.title = "Window Bar Test";
	}
	
}
