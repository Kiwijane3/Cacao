//
//  SplitViewDemoController.swift
//  CacaoPackageDescription
//
//  Created by Jane Fraser on 2/07/19.
//

import Foundation
import Cacao

public class SplitViewDemoController: UISplitViewController {
	
	public override init() {
		super.init(withPrimary: PrimaryController(), withDetail: DetailController());
		self.headerBarItem.leftBarItems.append(UIBarButtonItem(title: "Toggle Primary", style: .plain, action: { (_) in
			if self.preferredDisplayMode == .primaryHidden {
				self.preferredDisplayMode = .allVisible;
			} else {
				self.preferredDisplayMode = .primaryHidden;
			}
		}));
	}
	
}

public class PrimaryController: UIViewController {
	
	public override func loadView() {
		self.view = UIView();
		let textView = UILabel();
		textView.text = "This is the primary panel in a split view controller";
		textView.preferredMaxLayoutWidth = 128;
		self.view.addSubview(textView);
		textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
		textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true;
		self.view.setNeedsDisplay();
	}
	
}

public class DetailController: UIViewController {
	
	public override func loadView() {
		self.view = UIView();
		let textView = UILabel();
		textView.text = "This is the detail panel is a split view controller";
		textView.preferredMaxLayoutWidth = 128;
		self.view.addSubview(textView);
		textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
		textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true;
	}
	
}
