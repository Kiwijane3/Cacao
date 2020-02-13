//
//  UIControl.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 6/7/17.
//

import Foundation

/// The base class for controls, which are visual elements that convey
/// a specific action or intention in response to user interactions.
open class UIControl: UIView {

	private typealias TargetAction = (target: AnyObject?, id: String, Action: (UIEvent?) -> (), controlEvents: UIControlEvents);
    // MARK: - Configuring the Control’s Attributes
    
    /// The state of the control, specified as a bitmask value.
    ///
    /// The value of this property is a bitmask of the constants in the UIControlState type.
    /// A control can be in more than one state at a time.
    /// For example, it can be focused and highlighted at the same time.
    /// You can also get the values for individual states using the properties of this class.
	open var state: UIControlState { return .normal }
	
    // MARK: - Accessing the Control’s Targets and Actions
    
    /// Target-Action pairs
	private var targetActions = [TargetAction]();
	
	public override init(frame: CGRect) {
		super.init(frame: frame);
	}
	
	/// Registers an action to be called on the given control events. Target and id are used for identifying actions to allow for easy removal; Target represents the object that registered the action, and id defines the specific action.
	public func addTarget(_ target: AnyObject, id: String, action: @escaping (UIEvent?) -> (), for controlEvents: UIControlEvents) {
		targetActions.append((target, id, action, controlEvents));
	}
	
	/// Registers an action to be called on the given control events. Id is used to identify the action for easy removal. This should be used when the registering object is unimportant.
	public func add(withId id: String, action: @escaping (UIEvent?) -> (), for controlEvents: UIControlEvents) {
		targetActions.append((nil, id, action, controlEvents));
	}
	
	/// Removes all targetActions with the specified target, the specified id, and where that targetAction's control events are a subset of the parameter controlEvents. If any of these are nil, then any value will match the respective field for elimination.
	public func removeTarget(_ target: AnyObject?, id: String?, for controlEvents: UIControlEvents) {
		targetActions = targetActions.filter { targetAction -> Bool in
			let (elementTarget, elementId, _, elementControlEvents) = targetAction;
			return (elementTarget === target || target == nil) && (elementId == id || id == nil) && (controlEvents.isSuperset(of: elementControlEvents));
		}
	}
	
	/// Removes all target actions with no specified target (i.e, were registered via addTarget(withId:action:for:)), the specified id, and where their control events are a subset of the parameter controlEvents. If id is nil, all ids will be matched.
	public func remove(withId id: String?, for controlEvents: UIControlEvents) {
		targetActions = targetActions.filter { targetAction -> Bool in
			let (elementTarget, elementId, _, elementControlEvents) = targetAction;
			return (elementTarget == nil) && (elementId == id || id == nil ) && (controlEvents.isSuperset(of: elementControlEvents));
		}
	}
	
	/// Removes all targetActions from this control.
	public func clear() {
		targetActions = [TargetAction]();
	}
    
	/// Returns the actions performed on a target object when the specified event occurs. Not functional on Cacao.
    ///
    /// - Parameter target: The target object—that is, an object that has an action method associated with this control.
    /// You must pass an explicit object for this method to return a meaningful result.
    /// Specifying `nil` always returns `nil`.
    /// - Parameter controlEvent: A single control event constant representing the event
    /// for which you want the list of action methods.
    /// For a list of possible constants, see `UIControlEvents`.
    public func actions(forTarget target: AnyHashable?, forControlEvent controlEvent: UIControlEvents) -> [String]? {
		return nil;
	}
	
	// Returns all the ids currently in use by this control. Only available on Cacao.
	public var allIds: [String] {
		get {
			return targetActions.map { targetAction in
				let (_, id, _, _) = targetAction;
				return id;
			}
		}
	}
    
    /// Returns the events for which the control has associated actions.
    ///
    /// - Returns: A bitmask of constants indicating the events for which this control has associated actions.
    public var allControlEvents: UIControlEvents {
		get {
			return targetActions.reduce(UIControlEvents(), { events, targetAction -> UIControlEvents in
				return events.union(targetAction.controlEvents);
			} )
		}
    }
    
	/// Returns all target objects associated with the control. Note:  Only hashables are returned due to practical considerations around conforming to UIKit. Use of targets is preferable.
    ///
    /// - Returns: A set of all target objects associated with the control.
    /// The returned set may include one or more `NSNull` objects to indicate actions that are dispatched to the responder chain.
    public var allTargets: Set<AnyHashable> {
		get {
			return Set(targetActions.compactMap({ targetAction in
				if let target = targetAction.target as? AnyHashable {
					return target;
				} else {
					 return nil
				};
			}));
		}
    }
	
	public var targets: [AnyObject] {
		get {
			return targetActions.compactMap() { targetAction in
				return targetAction.target;
			}
		}
	}
	
	public func has(target: AnyObject) -> Bool {
		for (actionTarget, _, _, _) in targetActions {
			if actionTarget === target {
				return true;
			}
		}
		return false;
	}
    
    /// Calls the action methods where controlEvents. is a superset of action's controlEvents.
    public func sendActions(for controlEvents: UIControlEvents) {
		for (target, id, action, actionControlEvents) in targetActions {
			if controlEvents.isSuperset(of: actionControlEvents) {
				action(nil);
			}
		}
    }
	
	open func onStateChanged() {}
	
}

private extension UIControl {
    
    final class Target: Hashable {
        
        let value: AnyHashable?
        
        init(_ value: AnyHashable? = nil) {
            
            self.value = value
        }
        
        var hashValue: Int {
            
            return value?.hashValue ?? 0
        }
        
        static func == (lhs: Target, rhs: Target) -> Bool {
            
            return lhs.value == rhs.value
        }
    }
}

/// Constants describing the state of a control.
///
/// A control can have more than one state at a time.
/// Controls can be configured differently based on their state.
/// For example, a `UIButton` object can be configured to display one image
/// when it is in its normal state and a different image when it is highlighted.
public struct UIControlState: OptionSet, Hashable {
    
    public let rawValue: Int
	
	public var hashValue: Int {
		get {
			return rawValue;
		}
	}
    
    public init(rawValue: Int = 0) {
        
        self.rawValue = rawValue
    }
    
    /// The normal, or default state of a control—that is, enabled but neither selected nor highlighted.
    public static let normal = UIControlState(rawValue: 0)
    
    public static let highlighted = UIControlState(rawValue: 1 << 0)
    
    public static let disabled = UIControlState(rawValue: 1 << 1)
    
    public static let selected = UIControlState(rawValue: 1 << 2)
    
    public static let focused = UIControlState(rawValue: 1 << 3)
    
    public static let application = UIControlState(rawValue: 0x00FF0000)
}

public struct UIControlEvents: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int = 0) {
        
        self.rawValue = rawValue
    }
    
    public static let touchDown = UIControlEvents(rawValue: 1 << 0)
    public static let touchDownRepeat = UIControlEvents(rawValue: 1 << 1)
    public static let touchDragInside = UIControlEvents(rawValue: 1 << 2)
    public static let touchDragOutside = UIControlEvents(rawValue: 1 << 3)
    public static let touchDragEnter = UIControlEvents(rawValue: 1 << 4)
    public static let touchDragExit = UIControlEvents(rawValue: 1 << 5)
    public static let touchUpInside = UIControlEvents(rawValue: 1 << 6)
    public static let touchUpOutside = UIControlEvents(rawValue: 1 << 7)
    public static let touchCancel = UIControlEvents(rawValue: 1 << 8)
    public static let valueChanged = UIControlEvents(rawValue: 1 << 12)
    public static let primaryActionTriggered = UIControlEvents(rawValue: 1 << 13)
    public static let editingDidBegin = UIControlEvents(rawValue: 1 << 16)
    public static let editingChanged = UIControlEvents(rawValue: 1 << 17)
    public static let editingDidEnd = UIControlEvents(rawValue: 1 << 18)
    public static let editingDidEndOnExit = UIControlEvents(rawValue: 1 << 19)
    public static let allTouchEvents = UIControlEvents(rawValue: 0x00000FFF)
    public static let allEditingEvents = UIControlEvents(rawValue: 0x000F0000)
    public static let applicationReserved = UIControlEvents(rawValue: 0x0F000000)
    public static let systemReserved = UIControlEvents(rawValue: 0xF0000000)
    public static let allEvents = UIControlEvents(rawValue: 0xFFFFFFFF)
}

extension UIControlEvents: Hashable {
    
    public var hashValue: Int {
        return rawValue
    }
}
