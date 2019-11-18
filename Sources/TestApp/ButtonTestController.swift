//
//  ButtonTestController.swift
//  CacaoPackageDescription
//
//  Created by Jane Fraser on 6/09/19.
//

import Foundation
import Cacao

public class ButtonTestController: UIViewController {
	
	public var button: UIButton? = nil;
	
	public override func loadView() {
		self.view = UIView();
		let button = UIButton();
		self.view.addSubview(button);
		self.button = button;
		self.button?.setTitle("Example", for: .normal);
		self.button?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
		self.button?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true;
		self.button?.addTarget(self, id: "default", action: { (_) in
			self.exampleFunction();
		}, for: .touchUpInside);
	}
	
	public func exampleFunction() {
		print("Function invoked!");
	}
	
	public func deactivateButton() {
		self.button?.removeTarget(self, id: nil, for: .allEvents);
	}
	
}
