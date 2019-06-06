//
//  UIViewAnimation.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 6/24/17.
//

import Foundation;
import Silica;

// Stores the state of a view and its subviews, recursive, at a point in the animation, or prior. Used to store the initial state for the animation.
public struct UIAnimationFrame {
	
	// The view that this frame stores the state for.
	public let view: UIView;
	
	// The frame property of the view for this view.
	public let frame: CGRect;
	
	// Frames for the subviews of the target view.
	public let subframes: [UIAnimationFrame];
	
	public init(from view: UIView) {
		self.view = view;
		self.frame = view.frame;
		var subframes = [UIAnimationFrame]();
		for subview in view.subviews {
			subframes.append(UIAnimationFrame(from: subview));
		}
		self.subframes = subframes;
	}
	
	// Restores the target view and its hierarchy to the state described in this frame.
	public func restore() {
		self.view.frame = self.frame;
		for subframe in subframes {
			subframe.restore();
		}
	}
	
	
}



// This class contains enumerations describing animation
public enum UIAnimatableChange {
	
	case moveX(target: UIView, initial: CGFloat, final: CGFloat);
	case moveY(target: UIView, initial: CGFloat, final: CGFloat);
	case resizeWidth(target: UIView, initial: CGFloat, final: CGFloat);
	case resizeHeight(target: UIView, initial: CGFloat, final: CGFloat);
	
}

// This class records animatable state changes from a given relative point to another relative point, and provides functionality to animate these changes.
public class UIAnimation {
	
	// The relative point at which this animation starts.
	public let startPoint: CGFloat;
	
	// The relative point at which this animation ends.
	public let endPoint: CGFloat;
	
	public var relativeLength: CGFloat {
		get {
			return endPoint - startPoint;
		}
	}
	
	// The state changes for this animation.
	private var changes: [UIAnimatableChange];
	
	// Whether this Animation is currently in a recording state.
	public private(set) var recording: Bool;
	
	// The progress of the Animator this animation is in.
	public var progress: CGFloat {
		didSet {
			// Animate the change if the new progress is within the time bounds of this action, or the change crosses the endPoint.
			if (startPoint <= progress && progress <= endPoint) || (oldValue < endPoint) && (progress >= endPoint) {
				animate();
			}
		}
	}
	
	public init(from startPoint: CGFloat, to endPoint: CGFloat) {
		self.startPoint = startPoint;
		self.endPoint = endPoint;
		self.changes = [UIAnimatableChange]();
		self.recording = true;
		self.progress = 0.0;
	}
	
	// Records an animation for a view between the two frames.
	public func recordFrameChange(on target: UIView, from oldFrame: CGRect, to newFrame: CGRect) {
		if recording {
			// Check all properties for changes and add appropriate changes to change list if they have been altered.
			if oldFrame.origin.x != newFrame.origin.x {
				self.changes.append(.moveX(target: target, initial: oldFrame.origin.x, final: newFrame.origin.x));
			}
			if oldFrame.origin.y != newFrame.origin.y {
				self.changes.append(.moveY(target: target, initial: oldFrame.origin.y, final: newFrame.origin.y));
			}
			if oldFrame.size.width != newFrame.size.width {
				self.changes.append(.resizeWidth(target: target, initial: oldFrame.size.width, final: oldFrame.size.width));
			}
			if oldFrame.size.height != newFrame.size.height {
				self.changes.append(.resizeHeight(target: target, initial: oldFrame.size.height, final: oldFrame.size.height));
			}
		} else {
			debugPrint("Error: Attempted to record to UIAnimation after recording ended!");
		}
	}
	
	// Ends recording and prevents any further changes from being stored.
	public func endRecording() {
		recording = false;
	}
	
	private func animate() {
		for change in changes {
			switch change {
			case let .moveX(target, initial, final):
				target.frame.origin.x = tween(from: initial, to: final);
			case let .moveY(target: target, initial: initial, final: final):
				target.frame.origin.y = tween(from: initial, to: final);
			case let .resizeWidth(target, initial, final):
				target.frame.size.width = tween(from: initial, to: final);
			case let .resizeHeight(target, initial, final):
				target.frame.size.height = tween(from: initial, to: final);
			}
		}
	}
	
	// Calculates the tween for the current animator progress.
	private func tween(from initial: CGFloat, to final: CGFloat) -> CGFloat {
		return tween(at: progress, from: initial, to: final);
	}
	
	// Returns the appropriate value for a property animating from initial to final at the given animator progress.
	private func tween(at progress: CGFloat, from initial: CGFloat, to final: CGFloat) -> CGFloat {
		// Efficiently handle progress values at or before the start of the animation and at or after the end of the animation.
		if progress <= startPoint {
			return initial;
		}
		if progress >= endPoint {
			return final;
		}
		// Interpolate intermediary values.
		// Calculate the progress relative to the start and end of this animation.
		let internalProgress = (progress - startPoint) / relativeLength;
		let totalDelta = final - initial;
		let delta = totalDelta * internalProgress;
		let tween = initial + delta;
		return tween;
	}
	
}

public class UIViewPropertyAnimator {
	
	private typealias TimedAnimations = (start: CGFloat, end: CGFloat, animations: () -> Void);
	
	private var animations: [UIAnimation] = [UIAnimation]();
	
	private var currentAnimations: [UIAnimation] {
		get {
			return animations.filter { (animation) in
				return animation.startPoint <= progress && progress <= animation.endPoint;
			}
		}
	}
	
	private var setup: (() -> Void)? = nil;
	
	private var animationBlocks: [TimedAnimations] = [TimedAnimations]();
	
	internal private(set) var completion: ((Bool) -> Void)? = nil;
	
	// The internal progress of the animator.
	private var progress: CGFloat {
		didSet {
			for animation in animations {
				animation.progress = progress;
			}
			// Redraw all windows
			_UIApp.windows.forEach { (window) in
				window.setNeedsDisplay();
			}
		}
	}
	
	// The external facing progress of the animator.
	public var fractionComplete: CGFloat {
		get {
			return progress;
		}
		set {
			// Scrub to the appropriate value;
		}
	}
	
	// The time, in seconds, that the animation runs for.
	public let duration: TimeInterval;
	
	// The number of times the animation advances to the next frame each second. Defaults to 30fps. Note that the animator itself doesn't directly trigger rendering, so fewer frames may be rendered depending on external factors.
	public let fps: Int;
	
	private var frameInterval: TimeInterval {
		get {
			return Double(1) / Double(fps);
		}
	}
	
	// The total number of frames in the animation; This is the mathematical product of duration and fps.
	private var frames: Int {
		get {
			return Int(duration * Double(fps));
		}
	}
	
	// The number of frames remaining in the animation.
	private var remainingFrames: Int {
		get {
			return Int(CGFloat(frames) * progress);
		}
	}
	
	// The amount of relative progress to advance each frame.
	private var progressPerFrame: CGFloat {
		get {
			return CGFloat(1.0) / CGFloat(frames);
		}
	}
	
	// The timer currently managing the animation.
	private var timer: Timer?;
	
	// A timer that will begin the animation after a delay from its creation.
	private var delayTimer: Timer?;
	
	public init(duration: TimeInterval, frameRate: Int = 60) {
		self.duration = duration;
		self.fps = frameRate;
		self.progress = 0.0;
	}
	
	// Adds an animation starting with a given relative delay and a given relative duration.
	public func addAnimations(_ animations: @escaping () -> Void, delayFactor: CGFloat, relativeDuration: CGFloat) {
		animationBlocks.append((start: delayFactor, end: delayFactor + relativeDuration, animations: animations));
	}
	
	// Adds an animation with a given relative delay that runs for remaining length of the animation.
	public func addAnimations(_ animations: @escaping () -> Void, delayFactor: CGFloat) {
		animationBlocks.append((start: delayFactor, end: 1, animations: animations));
	}
	
	public func addAnimations(_ animations: @escaping () -> Void) {
		animationBlocks.append((start: 0, end: 1, animations: animations));
	}
	
	// Adds a setup block specifying that modifies properties prior to the start of the animation.
	public func addSetup(_ setup: @escaping () -> Void) {
		self.setup = setup;
	}
	
	public func addCompletion(_ completion: @escaping (Bool) -> Void) {
		self.completion = completion;
	}
	
	private func recordAnimations() {
		// Store the state of the current view hierarchy to be restored on completion of animation recording.
		let currentViewState = _UIApp.windows.map { (window) in
			return UIAnimationFrame.init(from: window);
		}
		// Run setup to get the appropriate animation initial state.
		setup?();
		// Initialise and record animations in order of their starting point. Since animations that change the same properties should not overlap, it is assumed that any relevant property changes in blocks that start earlier are complete by the start of the current block, and hence that the state after executing earlier blocks represents the correct initial state for the current animation block. If animation blocks do overlap, this will not be true, and the recorded animations will have erroneous behaviour. This cannot be detected before animations are recorded, since what properties blocks alter cannot be known until they are executed, but it can be detected once recording is complete, and will be reported on the command line (TODO: Implement this).
		animationBlocks.sort { (a, b) in
			return a.start < b.start;
		}
		for (start, end, animationBlock) in animationBlocks {
			// Create an animation to record changes into.
			let animation = UIAnimation(from: start, to: end);
			// Instruct all views to record changes into this animation
			_UIApp.windows.forEach { (window) in
				window.beginRecordingAnimation(into: animation);
			}
			// Execute the block to record the animations it contains.
			animationBlock();
			// End recording for the animation and add it to the animations for this animator.
			animation.endRecording();
			_UIApp.windows.forEach { (window) in
				window.stopRecordingAnimation();
			}
			self.animations.append(animation);
		}
		// Now that animations have been completed, restore the view hierarchy state to what is was prior to recording.
		currentViewState.forEach { frame in frame.restore(); };
	}
	
	public func startAnimation() {
		// Record the animation.
		recordAnimations();
		// Perform any setup actions.
		setup?();
		// Trigger a re-rendering to display inital state.
		_UIApp.windows.forEach { (window) in
			window.needsDisplay = true;
		}
		beginTimer();
	}
	
	public func startAnimation(afterDelay delay: TimeInterval) {
		if #available(OSX 10.12, *) {
			delayTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (_) in
				self.startAnimation();
			});
		} else {
			// Since Cacao primarily targets non OSX targets, animations are simply unsupported on macOS versions prior to 10.12.
			debugPrint("Animations not supported prior to OSX 10.12");
		};
	}
	
	// Starts a timer to trigger frame advances based on the animator's properties. This timer will be available in the timer property. It will automatically be invalidated once we advance to the final frame, and can be manually invalidated without issue.
	private func beginTimer() {
		if #available(OSX 10.12, *) {
			timer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true, block: { (_) in
				self.advanceFrame();
			})
		} else {
			// Since Cacao primarily targets non OSX targets, animations are simply unsupported on macOS versions prior to 10.12.
			debugPrint("Animations not supported prior to OSX 10.12");
		};
	}
	
	private func advanceFrame() {
		// Advance progress by the equivalent of one frame.
		progress += progressPerFrame;
		// Stop the timer and call completion if the animation is complete.
		if progress >= 1.0 {
			progress = 1.0;
			timer?.invalidate();
			completion?(true);
		}
	}
	
}

// MARK: - Supporting Types

public enum UIViewAnimationCurve: Int {
    
    case easeInOut
    case easeIn
    case easeOut
    case linear
}

public enum UIViewAnimationTransition: Int {
    
    case none
    case flipFromLeft
    case flipFromRight
    case curlUp
    case curlDown
}

///
public struct UIViewAnimationOptions: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
    
    public static let layoutSubviews = UIViewAnimationOptions(rawValue: 1 << 0)
    public static let allowUserInteraction = UIViewAnimationOptions(rawValue: 1 << 1)
    public static let beginFromCurrentState = UIViewAnimationOptions(rawValue: 1 << 2)
    public static let `repeat` = UIViewAnimationOptions(rawValue: 1 << 3)
    public static let autoreverse = UIViewAnimationOptions(rawValue: 1 << 4)
    public static let overrideInheritedDuration = UIViewAnimationOptions(rawValue: 1 << 5)
    public static let overrideInheritedCurve = UIViewAnimationOptions(rawValue: 1 << 6)
    public static let allowAnimatedContent = UIViewAnimationOptions(rawValue: 1 << 7)
    public static let showHideTransitionViews = UIViewAnimationOptions(rawValue: 1 << 8)
    public static let curveEaseInOut = UIViewAnimationOptions(rawValue: 0 << 16)
    public static let curveEaseIn = UIViewAnimationOptions(rawValue: 1 << 16)
    public static let curveEaseOut = UIViewAnimationOptions(rawValue: 2 << 16)
    public static let curveLinear = UIViewAnimationOptions(rawValue: 3 << 16)
    public static let transitionNone = UIViewAnimationOptions(rawValue: 0 << 20)
    public static let transitionFlipFromLeft = UIViewAnimationOptions(rawValue: 1 << 20)
    public static let transitionFlipFromRight = UIViewAnimationOptions(rawValue: 2 << 20)
    public static let transitionCurlUp = UIViewAnimationOptions(rawValue: 3 << 20)
    public static let transitionCurlDown = UIViewAnimationOptions(rawValue: 4 << 20)
    public static let transitionCrossDissolve = UIViewAnimationOptions(rawValue: 5 << 20)
    public static let transitionFlipFromTop = UIViewAnimationOptions(rawValue: 6 << 20)
    public static let transitionFlipFromBottom = UIViewAnimationOptions(rawValue: 7 << 20)
}
