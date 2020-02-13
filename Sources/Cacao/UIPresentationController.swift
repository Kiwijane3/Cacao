//
//  File.swift
//  
//
//  Created by Jane Fraser on 21/11/19.
//

import Foundation
import Silica

// Manages a popover presentation.
public class UIPresentationController {
	
	// The view controller doing the presentation. If a presentation controller is initialised prior to presentation, such as via access, this defaults to the window controller, and will be updated once presentation begins.
	public var presentingViewController: UIViewController;
	
	public var presentedViewController: UIViewController;
	
	// The view of the presenting view controller.
	public var containerView: UIView? {
		get {
			return presentingViewController.view;
		}
	}
	
	// The view being presented.
	public var presentedView: UIView? {
		get {
			return presentedViewController.view;
		}
	}
	
	public var frameOfPresentedViewContainerViewInContainerView: CGRect {
		get {
			return CGRect(origin: .zero, size: .zero);
		}
	}
	
	public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
		self.presentedViewController = presentedViewController;
		if let presentingViewController = presentingViewController {
			self.presentingViewController = presentingViewController;
		} else {
			self.presentingViewController = UIScreen.main.keyWindow?.windowController ?? UIViewController();
		}
	}
	
		
	public func containerViewWillLayoutSubviews() {
		// Do Nothing.
	}
	
	public func presentationTransitionWillBegin() {
		// Do nothing.
	}
	
	public func presentationTransitionDidEnd() {
		// Do Nothing.
	}
	
	public func dismissalTransitionWillBegin() {
		// Do Nothing.
	}
	
	public func dismissalTransitionDidEnd() {
		// Do Nothing.
	}
	
}

public class UIDialogPresentationController: UIPresentationController {
	
	private var calculatedFrame: CGRect?;
	
	public override var frameOfPresentedViewContainerViewInContainerView: CGRect {
		get {
			if calculatedFrame == nil {
				calculateTargetFrame();
			}
			// Since this can lead to crashes, ensure calculated frame is populated during calculatedFrame.
			return calculatedFrame ?? .zero;
		}
	}
	
	internal func calculateTargetFrame() {
		if let containerView = containerView {
			calculatedFrame = frameCenteredIn(container: containerView.frame, forPreferredSize: presentedViewController.preferredContentSize);
		} else {
			calculatedFrame = .zero;
		}
	}
	
}


public var arrowSize: CGFloat = 16;

public class UIPopoverPresentationController: UIPresentationController {

	public var popoverLayoutMargins: UIEdgeInsets = .init(vertical: 8, horizontal: 8);
	
	public var backgroundColor: UIColor?;
	
	public var barButtonItem: UIBarButtonItem?;
	
	public var sourceView: UIView?;
	
	public var sourceRect: CGRect?;
	
	public var sourceRectInContainer: CGRect {
		get {
			if let barButtonItem = barButtonItem, let itemView = barButtonItem.view, let superview = itemView.superview {
				return superview.convert(itemView.frame, to: sourceView) ?? CGRect(origin: .zero, size: .zero);
			} else if let sourceRect = sourceRect {
				let originView = sourceView ?? containerView;
				return originView?.convert(sourceRect, from: originView) ?? CGRect(origin: .zero, size: .zero);
			} else {
				return CGRect(origin: .zero, size: .zero);
			}
		}
	}
	
	public var permittedArrowDirections: UIPopoverArrowDirection = .any;
	
	public private(set) var arrowDirection: UIPopoverArrowDirection = .unknown;
	
	private var calculatedFrame: CGRect?;
	
	public override var frameOfPresentedViewContainerViewInContainerView: CGRect {
		get {
			if calculatedFrame == nil {
				calculateTargetFrame();
			}
			// Since this is can result in crash, ensure that calculateTargetFrame() populates calculatedFrame;
			return calculatedFrame!;
		}
	}
	
	internal func determinePresentingDirection() {
		if let containerView = containerView {
			// Check the permitted arrow directions anti-clockwise from .up, and select the first direction that can accommodate the preferred size.
			if permittedArrowDirections.contains(.up) {
				// This is a vertical display, so check that there is sufficient vertical space below to accommodate the preferred size and arrow display.
				var availableSize = containerView.frame.maxY - sourceRectInContainer.maxY;
				if availableSize > presentedViewController.preferredContentSize.height + arrowSize {
					self.arrowDirection = .up;
					return;
				}
			}
			if permittedArrowDirections.contains(.right) {
				var availableSize = containerView.frame.maxX - sourceRectInContainer.maxX;
				if availableSize > presentedViewController.preferredContentSize.width + arrowSize{
					self.arrowDirection = .right;
					return;
				}
			}
			if permittedArrowDirections.contains(.down) {
				var availableSize = containerView.frame.minY;
				if availableSize > presentedViewController.preferredContentSize.height + arrowSize {
					self.arrowDirection = .down;
					return;
				}
			}
			if permittedArrowDirections.contains(.left) {
				var availableSize = containerView.frame.minX;
				if availableSize > presentedViewController.preferredContentSize.width + arrowSize {
					self.arrowDirection = .left;
					return;
				}
			}
		}
	}
	
	internal func calculateTargetFrame() {
		// If direction is not yet determined, do so now.
		if arrowDirection == .unknown || arrowDirection == .any {
			determinePresentingDirection();
		}
		// If we have an arrow direction, start by placing the popover next to the sourceRect, centered with the sourceRect, and then shift into the frame.
		if arrowDirection == .up {
			var originY = sourceRectInContainer.maxY;
			originY += 8;
			var centerX = sourceRectInContainer.midX;
			var originX = centerX - (presentedViewController.preferredContentSize.width / 2);
			originX = shiftedIntoFrameIfNeededX(originX, width: presentedViewController.preferredContentSize.width);
			calculatedFrame = CGRect(origin: CGPoint(x: originX, y: originY), size: presentedViewController.preferredContentSize);
		} else if arrowDirection == .left {
			var originX = sourceRectInContainer.maxX;
			originX += 8;
			var centerY = sourceRectInContainer.midY;
			var originY = centerY - (presentedViewController.preferredContentSize.height / 2);
			originY = shiftedIntoFrameIfNeededY(originY, height: presentedViewController.preferredContentSize.height);
			calculatedFrame = CGRect(origin: CGPoint(x: originX, y: originY), size: presentedViewController.preferredContentSize)
		} else if arrowDirection == .down {
			var originY = sourceRectInContainer.minY - (presentedViewController.preferredContentSize.height + arrowSize);
			originY -= 8;
			var centerX = sourceRectInContainer.midX;
			var originX = centerX - (presentedViewController.preferredContentSize.width / 2);
			originX = shiftedIntoFrameIfNeededX(originX, width: presentedViewController.preferredContentSize.width);
			calculatedFrame = CGRect(origin: CGPoint(x: originX, y: originY), size: presentedViewController.preferredContentSize);
		} else if arrowDirection == .right {
			var originX = sourceRectInContainer.minX - (presentedViewController.preferredContentSize.width + arrowSize);
			originX -= 8;
			var centerY = sourceRectInContainer.midY;
			var originY = centerY - (presentedViewController.preferredContentSize.height / 2);
			originY = shiftedIntoFrameIfNeededY(originY, height: presentedViewController.preferredContentSize.height);
			calculatedFrame = CGRect(origin: CGPoint(x: originX, y: originY), size: presentedViewController.preferredContentSize);
		// If we don't have an arrow direction, just present centered in the container view.
		} else if let containerView = containerView {
			calculatedFrame = frameCenteredIn(container: containerView.frame, forPreferredSize: presentedViewController.preferredContentSize);
		}
		// If we don't have the containerView somehow, return a zero frame;
		else {
			calculatedFrame = .zero;
		}
	}
	
	// Takes an optimal x position and width for a popover frame and returns the best practical x position.
	internal func shiftedIntoFrameIfNeededX(_ x: CGFloat, width: CGFloat) -> CGFloat {
		// TODO: Account for layout margins.
		if let containerView = containerView {
			// If the x value is less than zero, return 0.
			if x < 8 {
				return 8;
			// If the max X value is outside the bounds, shift the x origin so it is in bounds.
			} else {
				let maxX = x + width;
				if maxX > containerView.frame.maxX - 8 {
					let delta = maxX - ( containerView.frame.maxX  - 8 ) ;
					return x - delta;
				}
			}
		}
		return x;
	}
	
	internal func shiftedIntoFrameIfNeededY(_ y: CGFloat, height: CGFloat) -> CGFloat {
		if let containerView = containerView {
			if (y < 8) {
				return 8;
			} else {
				let maxY = y + height;
				if maxY > containerView.frame.maxY - 8 {
					let delta = maxY - ( containerView.frame.maxY - 8 );
					return y - delta;
				}
			}
		}
		return y;
	}
	
}

public func frameCenteredIn(container: CGRect, forPreferredSize preferredSize: CGSize) -> CGRect {
	let originX = container.midX - (preferredSize.width / 2);
	let originY = container.midY - (preferredSize.height / 2);
	return CGRect(origin: CGPoint(x: originX, y: originY), size: preferredSize);
}

public struct UIPopoverArrowDirection: OptionSet {
	
	public let rawValue: Int;
	
	public init(rawValue: Int) {
		self.rawValue = rawValue;
	}
	
	static let up = UIPopoverArrowDirection(rawValue: 1 << 0);
	
	static let down = UIPopoverArrowDirection(rawValue: 1 << 1);
	
	static let left = UIPopoverArrowDirection(rawValue: 1 << 2);
	
	static let right = UIPopoverArrowDirection(rawValue: 1 << 3);
	
	static let any: UIPopoverArrowDirection = [.up, .down, .left, .right];
	
	static let unknown = UIPopoverArrowDirection(rawValue: 1 << 4);
	
}
