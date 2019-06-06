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
	}
	
	// Renders the image within the margins of the UIImageView
	open override func draw(_ rect: CGRect) {
		// Calculate the origin and size to render the image within the margins.
		let origin = CGPoint(x: layoutMargins.left, y: layoutMargins.top);
		let size = CGSize(width: frame.size.width - layoutMargins.size.width, height: frame.size.height - layoutMargins.size.height);
		let imageBounds = CGRect(origin: origin, size: size);
		image?.draw(in: imageBounds);
	}
	
}
