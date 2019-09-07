//
//  UIImageView.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 6/7/17.
//

import Foundation
import Silica

open class UIImageView: UIView {
    
	public var image: UIImage?;
	
	public override init(frame: CGRect) {
		super.init(frame: frame);
		self.setNeedsDisplay();
	}
	
	// Renders the image within the margins of the UIImageView
	open override func draw(_ rect: CGRect) {
		// Calculate the origin and size to render the image within the margins.
		debugPrint("Rendering image: \(image)");
		let origin = CGPoint(x: layoutMargins.left, y: layoutMargins.top);
		let size = CGSize(width: frame.size.width - layoutMargins.size.width, height: frame.size.height - layoutMargins.size.height);
		let imageBounds = CGRect(origin: origin, size: size);
		image?.draw(in: imageBounds);
	}
	
	// Intrinic size is based on the innate size of the image. This is unlikely to be particularly useful in most instances, so use constraints.
	open override var intrinsicContentSize: CGSize {
		get {
			return image?.size ?? .zero + self.layoutMargins.size;
		}
	}
	
}
