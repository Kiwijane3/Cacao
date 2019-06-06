//
//  UIWindowControlGroup.swift
//  Cacao
//
//  Created by Jane Fraser on 23/04/19.
//

import Foundation

// Displays the window controls. Primarily intended to be used in the window bar. If the window bar is absent, the programmer should display an instance of this object on the left on the left or right upper edge of the window.
public class UIWindowControls: UIView {
	
	public weak var windowController: UIWindowController?;
	
	// A close window control will always be available, so there is no variable for that.
	
	// Whether a minimise control should be displayed. This will generally be initialised from system settings, but can be overriden if that is desired.
	public var displayMinimiseControl: Bool = true {
		didSet {
			createControlsAndLayout();
		}
	}
	
	// Whether a maximise control should be displayed. This will generally be initialised from sytems settings, but can be overriden if that is desired.
	public var displayMaximiseControl: Bool = true {
		didSet {
			createControlsAndLayout();
		}
	}
	
	// An array of the current displayed controls.
	private var controls: [UIView] = [UIView]();
	
	public var internalMargin: CGFloat = 8;
	
	public init() {
		super.init(frame: .zero);
		createControlsAndLayout();
	}
	
	public func createControlsAndLayout() {
		// Remove previous controls
		controls.forEach { (control) in
			control.removeFromSuperview();
		}
		var controls = [UIView]();
		// Add the controls in a left-to-right order.
		if displayMinimiseControl {
			let minimiseControl = UIButton(type: .frameless);
			minimiseControl.setTitle("Minimise", for: .normal);
			minimiseControl.add(withId: "MinimiseWindow", action: { (_) in
				self.windowController?.minimise();
			}, for: .touchUpInside);
			controls.append(minimiseControl);
			self.addSubview(minimiseControl);
		}
		if displayMaximiseControl {
			let maximiseControl = UIButton(type: .frameless);
			maximiseControl.setTitle("Maximise", for: .normal);
			maximiseControl.add(withId: "MaximiseWindow", action: { (_) in
				self.windowController?.maximise();
			}, for: .touchUpInside);
			controls.append(maximiseControl);
			self.addSubview(maximiseControl);
		}
		// Add the close control.
		let closeControl = UIButton(type: .frameless);
		closeControl.setTitle("Close", for: .normal);
		closeControl.add(withId: "CloseWindow", action: { _ in self.windowController?.close(); }, for: .touchUpInside);
		controls.append(closeControl);
		self.addSubview(closeControl);
		// Constrain all controls to top.
		controls.forEach { (control) in
			control.topAnchor.constraint(equalTo: self.topMarginAnchor).isActive = true;
		}
		if controls.count > 0 {
			controls[0].leftAnchor.constraint(equalTo: self.leftMarginAnchor).isActive = true;
		}
		for index in 1..<controls.count {
			controls[index].leftAnchor.constraint(equalTo: controls[index - 1].rightAnchor, constant: internalMargin).isActive = true;
		}
		setNeedsLayout();
		setNeedsDisplay();
	}
	
}
