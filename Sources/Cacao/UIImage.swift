//
//  UIImage.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 6/15/17.
//

import Foundation
import Silica
import Cairo
import SDL

public final class UIImage {
	
	public let cgImage: Silica.CGImage;
	
	public let size: CGSize;
	
	public init?(contentsOfFile filePath: String) {
		guard let data = FileManager.default.contents(atPath: filePath) else {
			return nil;
		}
		guard let cgImage = CGImageSourcePNG(data: data)?.createImage(at: 0) else {
			return nil;
		}
		self.cgImage = cgImage;
		self.size = CGSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height));
	}
	
	/**
	// Creates an image of the given size, drawn using the draw function provided.
	public init?(withId id: String, size: CGSize, drawingWith draw: () -> (Void)) {
		if let imageSurface = try? Cairo.Surface.Image(format: .argb32, width: Int(size.width), height: Int(size.height)), let context = try? CGContext(surface: imageSurface, size: size) {
			// Push the context to draw into using draw() function. If this code is being called on a non-UI thread, the UI thread may alter the context during draw, leading to issues, so call this function from the UI thread; This kind of drawing is fairly efficient, anyway.
			UIGraphicsPushContext(context);
			draw();
			UIGraphicsPopContext();
			self.size = size;
		} else {
			return nil;
		}
	}
	**/
	
	/// Draws the image in the current context at the given point with the image's intrinsic size.
	public func draw(at point: CGPoint) {
	
		guard let context = UIGraphicsGetCurrentContext() else {
			return;
		}
		
		context.draw(cgImage, in: CGRect(origin: point, size: size));
	}
	
	public func draw(in rect: CGRect) {
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return;
		}
		
		context.draw(cgImage, in: rect);
		
	}
	
}
