//
//  UIWindowManipulationView.swift
//  Cacao
//
//  Created by Jane Fraser on 13/10/19.
//

import Foundation

/// This is a view that allows the window to be manipulated, based on the specified mode.
public class UIWindowHandle: UIView {
	
	/// Determines what kind of window manipulation this control view performs.
	public var mode: UIWindow.ManipulationMode;
	
	public init(forMode mode: UIWindow.ManipulationMode) {
		self.mode = mode;
		super.init(frame: .zero);
	}
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			window?.beginManipulation(withMode: mode, at: touch.location, in: window!);
		}
	}
	
	public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			window?.updateManipulation(to: touch.location, in: window!);
		}
	}
	
	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		window?.endManipulation();
	}
	
}
