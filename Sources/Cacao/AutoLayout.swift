//
//  AutoLayout.swift
//  Cacao
//
//  Created by Jane Fraser on 27/11/18.
//

import Foundation

import Cassowary

/// This file contains various utility classes used for auto layout.

internal struct Property: Hashable {
	
	internal enum Attribute: Int {
		// These cases are copied from NSLayout.Attribute, and have corresponding raw values.
		case left = 1
		case right
		case top
		case bottom
		case leading
		case trailing
		case width
		case height
		case centerX
		case centerY
		case lastBaseline
		case firstBaseline
		case leftMargin
		case rightMargin
		case topMargin
		case bottomMargin
		case leadingMargin
		case trailingMargin
		case centerXWithinMargins
		case centerYWithinMargins
		case notAnAttribute
		// These cases are for intrinsic content size, which can't be referenced by constraints but are involved in the auto layout system regardless.
		case intrinsicSizeX
		case intrinsicSizeY
		case marginInsetLeft
		case marginInsetRight
		case marginInsetTop
		case marginInsetBottom
	}
	
	private let target: UIView;
	
	private let attribute: Attribute;
	
	public var description: String {
		get {
			return "\(target)::\(attribute)";
		}
	}
	
	internal init(for attribute: Attribute, on target: UIView) {
		self.target = target;
		self.attribute = attribute;
	}
	
	internal static func == (a: Property, b: Property) -> Bool {
		return a.target === b.target && a.attribute == b.attribute;
	}
	
	internal func hash(into hasher: inout Hasher) {
		hasher.combine(target);
		hasher.combine(attribute);
	}
	
}

extension NSLayoutConstraint.Attribute {

	internal var propertyAttribute: Property.Attribute {
		// These two enums have identical raw values for their shared values, so we can just initialise the Property version with this version's raw value.
		Property.Attribute.init(rawValue: self.rawValue)!;
	}
	
}
	

// Manages the relationship between properties, via Property structures, and Cassowary variables.
internal class VariableSet {
	
	public var map: [Property: Variable];
	
	public init() {
		self.map = [Property: Variable]();
	}
	
	public func variable(for property: Property) -> Variable {
		if let variable = map[property] {
			// Try to find the variable and return it.
			return variable;
		} else {
			// Otherwise, create a new property, store it, and return it.
			let variable = Variable(property.description);
			map[property] = variable;
			return variable;
		}
	}
	
	public func variable(for attribute: Property.Attribute, on target: UIView) -> Variable {
		return variable(for: Property(for: attribute, on: target));
	}
	
}

// Converts a UILayoutPriority to a cassowary priority.
internal func getPriority(for priority: UILayoutPriority) -> Double {
	if priority >= UILayoutPriority.required {
		return 1000;
	} else {
		return Double(priority);
	}
}

// Handles autolayout for a view.
internal class AutoLayoutManager {
	
	// MARK: - Variables

	private var solver: Cassowary.Solver = Cassowary.Solver();
	
	private var variables: VariableSet = VariableSet();
	
	private var container: UIView;
	
	private var constraintMap: [AnyHashable: [Cassowary.Constraint]] = [AnyHashable: [Cassowary.Constraint]]();
	
	// Whether this manager has initialised its state. Used to allow the manager to setup an initial valid linear system which can then be modified.
	private var initialised = false;
	
	internal init(for view: UIView) {
		container = view;
		createContainerVariables();
	}
	
	private func variable(for attribute: Property.Attribute, on view: UIView) -> Variable {
		return variables.variable(for: attribute, on: view);
	}
	
	// Constructs the constraint system.
	private func construct() {
		// Add all constraints simultaneously.
		createContainerVariables();
		updateContainerVariables();
		for subview in container.subviews {
			addIntrinsicConstraints(for: subview);
			if subview.intrinsicContentSize.width != UIViewNoIntrinsicMetric {
				addIntrinsicSizeXConstraints(for: subview)
				// Initialise variable.
				
			}
			if subview.intrinsicContentSize.height != UIViewNoIntrinsicMetric {
				addIntrinsicSizeYConstraints(for: subview);
				// Initialise variable.
			}
		}
		for uiConstraint in container.constraints {
			addUIConstraint(for: uiConstraint);
		}
		do {
			initialised = true;
		} catch {
			debugPrint("Could not initialise constraints due to error: \(error)");
		}
	}
	
	private func addUIConstraint(for uiConstraint: NSLayoutConstraint) {
		if let constraint = self.constraint(for: uiConstraint) {
			constraintMap[uiConstraint] = [constraint];
			try? solver.addConstraint(constraint);
		}
	}
	
	private func removeUIConstraint(for uiConstraint: NSLayoutConstraint) {
		constraintMap[uiConstraint]?.forEach { constraint in
			do {
				try solver.removeConstraint(constraint);
			} catch {
				debugPrint("Could not remove constraint for \(uiConstraint): \(error)");
			}
		};
		constraintMap[uiConstraint] = nil;
	}
	
	// Creates the intrinsic constraints for this UIView which consists of the fundamental rules of geometry, such as width = right - left, Should be used by superviews during their layout calculation.
	internal func addIntrinsicConstraints(for view: UIView) {
		// Create the intrinsic constraints, which represent inherent geometry.
		let intrinsicConstraints: [Constraint] = [
			modifyStrength( variable(for: .width, on: view) >= 0, 1000),
			modifyStrength( variable(for: .height, on: view) >= 0, 1000),
			modifyStrength( variable(for: .width, on: view) == variable(for: .right, on: view) - variable(for: .left, on: view), 1000),
			modifyStrength( variable(for: .right, on: view) == variable(for: .left, on: view) + variable(for: .width, on: view), 1000),
			modifyStrength( variable(for: .height, on: view) == variable(for: .bottom, on: view) - variable(for: .top, on: view), 1000),
			modifyStrength( variable(for: .bottom, on: view) == variable(for: .top, on: view) + variable(for: .height, on: view), 1000),
			modifyStrength( variable(for: .centerX, on: view) == variable(for: .left, on: view) + (variable(for: .width, on: view) * 0.5), 1000),
			modifyStrength( variable(for: .centerY, on: view) == variable(for: .top, on: view) + (variable(for: .height, on: view) * 0.5), 1000),
			modifyStrength( variable(for: .leftMargin, on: view) == variable(for: .left, on: view) + variable(for: .marginInsetLeft, on: view), 1000),
			modifyStrength( variable(for: .rightMargin, on: view) == variable(for: .right, on: view) - variable(for: .marginInsetRight, on: view), 1000),
			modifyStrength( variable(for: .topMargin, on: view) == variable(for: .top, on: view) + variable(for: .marginInsetTop, on: view), 1000),
			modifyStrength( variable(for: .bottomMargin, on: view) == variable(for: .bottom, on: view) - variable(for: .marginInsetBottom, on: view), 1000)
		];
		// Record the intrinsic constraints so they can be removed when necessary.
		constraintMap[view] = intrinsicConstraints;
		// Add the constraints to the solver.
		intrinsicConstraints.forEach { constraint in
			do {
				try solver.addConstraint(constraint);
			} catch {
				debugPrint("Could not add an intrinsic constraint for \(view): \(error)");
			}
		}
	}
	
	private func removeIntrinsicConstraints(for view: UIView) {
		constraintMap[view]?.forEach { constraint in
			do {
				try solver.removeConstraint(constraint);
			} catch {
				debugPrint("Could not remove intrinsic constraint for subview \(view): \(error)");
			}
		}
		constraintMap[view] = nil;
	}
	
	internal func addIntrinsicSizeXConstraints(for view: UIView) {
		// Add constraints for the intrinsic content size if present on the view.
		// Add a constraint for content compression on the horizontal axis with the appropriate priority
		// Add a constraint for content hugging on the horizontal axis with the apprrpriate priority
		let compressionPriority = getPriority(for: view.contentCompressionResistancePriority(for: .horizontal));
		let huggingPriority = getPriority(for: view.contentHuggingPriority(for: .horizontal));
		let constraints = [
			modifyStrength(variable(for: .width, on: view) >= variable(for: .intrinsicSizeX, on: view), compressionPriority),
			modifyStrength(variable(for: .width, on: view) <= variable(for: .intrinsicSizeX, on: view), huggingPriority)
		]
		constraintMap[Property(for: .intrinsicSizeX, on: view)] = constraints;
		constraints.forEach { constraint in
			do {
				try solver.addConstraint(constraint);
			} catch {
				debugPrint("Could not add intrinsic width constraint for \(view): \(error)");
			}
		}
	}
	
	internal func removeIntrinsicSizeXConstraints(for view: UIView) {
		let intrinsicSizeVariable = variable(for: .intrinsicSizeX, on: view);
		constraintMap[intrinsicSizeVariable]?.forEach { constraint in
			do {
				try solver.removeConstraint(constraint);
			} catch {
				debugPrint("Could not remove intrinsic width constraint on \(view): \(error)");
			}
		}
		constraintMap[intrinsicSizeVariable] = nil;
	}
	
	internal func addIntrinsicSizeYConstraints(for view: UIView) {
		let compressionPriority = getPriority(for: view.contentCompressionResistancePriority(for: .vertical));
		let huggingPriority = getPriority(for: view.contentHuggingPriority(for: .vertical));
		let constraints = [
			modifyStrength( variable(for: .height, on: view) >= variable(for: .intrinsicSizeY, on: view), compressionPriority),
			modifyStrength( variable(for: .height, on: view) <= variable(for: .intrinsicSizeY, on: view), huggingPriority)
		];
		constraintMap[Property(for: .intrinsicSizeY, on: view)] = constraints;
		constraints.forEach { constraint in
			do {
				try solver.addConstraint(constraint);
			} catch {
				debugPrint("Could not add intrinsic height constraints for \(view): \(error)")
			}
		}
	}
	
	internal func removeIntrinsicSizeYConstraints(for view: UIView) {
		let intrinsicSizeVariable = variable(for: .intrinsicSizeY, on: view);
		constraintMap[intrinsicSizeVariable]?.forEach { constraint in
			do {
				try solver.removeConstraint(constraint);
			} catch {
				debugPrint("Could remove intrinsic height constraint for \(view): \(error)");
			}
		}
		constraintMap[intrinsicSizeVariable] = nil;
	}
	
	internal func createContainerVariables() {
		// Create edit variables for each container value.
		do {
			try solver.addEditVariable(variable: variable(for: .width, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .height, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .left, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .right, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .top, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .bottom, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .centerX, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .centerY, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .leftMargin, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .rightMargin, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .topMargin, on: container), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .bottomMargin, on: container), strength: 1000);
		} catch {
			debugPrint("Could not initialise container variables: \(error)");
		}
	}
	
	internal func createMarginInsetVariables(for view: UIView) {
		do {
			try solver.addEditVariable(variable: variable(for: .marginInsetLeft, on: view), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .marginInsetRight, on: view), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .marginInsetTop, on: view), strength: 1000);
			try solver.addEditVariable(variable: variable(for: .marginInsetBottom, on: view), strength: 1000);
		} catch {
			debugPrint("Could not add margin inset variables for \(view): \(error)");
		}
	}
	
	internal func removeMarginInsetVariables(for view: UIView) {
		do {
			try solver.removeEditVariable(variable(for: .marginInsetLeft, on: view));
			try solver.removeEditVariable(variable(for: .marginInsetRight, on: view));
			try solver.removeEditVariable(variable(for: .marginInsetTop, on: view));
			try solver.removeEditVariable(variable(for: .marginInsetBottom, on: view));
		} catch {
			debugPrint("Could remove margin inset variables for \(view): \(error)");
		}
	}
	
	internal func createIntrinsicSizeXVariable(for view: UIView) {
		do {
			try solver.addEditVariable(variable: variable(for: .intrinsicSizeX, on: view), strength: 1000);
		} catch {
			debugPrint("Could not create intrinsic width variable for view \(view): \(error)");
		}
	}
	
	internal func removeIntrinsicSizeXVariable(for view: UIView) {
		do {
			try solver.removeEditVariable(variable(for: .intrinsicSizeX, on: view));
		} catch {
			debugPrint("Could not remove intrinsic width variable for view \(view): \(error)");
		}
	}
	
	internal func createIntrinsicSizeYVariable(for view: UIView) {
		do {
			try solver.addEditVariable(variable: variable(for: .intrinsicSizeY, on: view), strength: 1000);
		} catch {
			debugPrint("Could not add intrinsic height variable for view \(view): \(error)");
		}
	}
	
	internal func removeIntrinsicSizeYVariable(for view: UIView) {
		do {
			try solver.removeEditVariable(variable(for: .intrinsicSizeY, on: view));
		} catch {
			debugPrint("Could not remove intrinsic height variable for view \(view): \(error)");
		}
	}
	
	internal func clearIntrinsicSizeVariablesIfNeeded(for view: UIView) {
		if solver.hasEditVariable(variable(for: .intrinsicSizeX, on: view)) {
			removeIntrinsicSizeXVariable(for: view);
		}
		if solver.hasEditVariable(variable(for: .intrinsicSizeY, on: view)) {
			removeIntrinsicSizeYVariable(for: view);
		}
	}
	
	// Constraints for layouts contained by this UIView. To be used during this view's own layout calculation.
	internal func updateContainerVariables() {
		// This function updates the edit variables in the solver to reflect current values.
		let left: Double = 0;
		let width = Double(container.frame.size.width);
		let right = left + width;
		let centerX = left + (width / 2);
		let top: Double = 0;
		let height = Double(container.frame.size.height);
		let bottom = top + height;
		let centerY = top + (height / 2);
		let leftMargin = left + Double(container.layoutMargins.left);
		let rightMargin = right - Double(container.layoutMargins.right);
		let topMargin = top + Double(container.layoutMargins.top);
		let bottomMargin = bottom + Double(container.layoutMargins.bottom);
		do {
			try solver.suggestValue(variable: variable(for: .left, on: container), value: left);
			try solver.suggestValue(variable: variable(for: .right, on: container), value: right);
			try solver.suggestValue(variable: variable(for: .width, on: container), value: width);
			try solver.suggestValue(variable: variable(for: .height, on: container), value: height);
			try solver.suggestValue(variable: variable(for: .top, on: container), value: top);
			try solver.suggestValue(variable: variable(for: .bottom, on: container), value: bottom);
			try solver.suggestValue(variable: variable(for: .centerX, on: container), value: centerX);
			try solver.suggestValue(variable: variable(for: .centerY, on: container), value: centerY);
			try solver.suggestValue(variable: variable(for: .leftMargin, on: container), value: leftMargin);
			try solver.suggestValue(variable: variable(for: .rightMargin, on: container), value: rightMargin);
			try solver.suggestValue(variable: variable(for: .topMargin, on: container), value: topMargin);
			try solver.suggestValue(variable: variable(for: .bottomMargin, on: container), value: bottomMargin);
		} catch {
			debugPrint("Error in container variable update: \(error)");
		}
			
	}
	
	internal func updateMarginInsetVariables(for subview: UIView) {
		do {
			try solver.suggestValue(variable: variable(for: .marginInsetLeft, on: subview), value: Double(subview.layoutMargins.left));
			try solver.suggestValue(variable: variable(for: .marginInsetRight, on: subview), value: Double(subview.layoutMargins.right));
			try solver.suggestValue(variable: variable(for: .marginInsetTop, on: subview), value: Double(subview.layoutMargins.top));
			try solver.suggestValue(variable: variable(for: .marginInsetBottom, on: subview), value: Double(subview.layoutMargins.bottom));
		} catch {
			debugPrint("Could not update margin inset variables for \(subview): \(error)");
		}
	}
	
	internal func updateIntrinsicSizeVariables(for subview: UIView) {
		if subview.intrinsicContentSize.width != UIViewNoIntrinsicMetric {
			// Check the variable exists, and create it if it doesn't.
			if !solver.hasEditVariable(variable(for: .intrinsicSizeX, on: subview)) {
				// We assume that the the presence of the variable corresponds to the presence of the constraints.
				addIntrinsicSizeXConstraints(for: subview);
				createIntrinsicSizeXVariable(for: subview);
			}
			do {
				try solver.suggestValue(variable: variable(for: .intrinsicSizeX, on: subview), value: Double(subview.intrinsicContentSize.width));
			} catch {
				debugPrint("Could not suggest intrinsic width for \(subview): \(error)");
			}
		// If the value has been set to UIViewNoIntrinsic metric from a functional value, remove the edit variable and constraints.
		} else if solver.hasEditVariable(variable(for: .intrinsicSizeX, on: subview)) {
			removeIntrinsicSizeXConstraints(for: subview)
			removeIntrinsicSizeXVariable(for: subview);
		}
		if subview.intrinsicContentSize.height != UIViewNoIntrinsicMetric {
			if !solver.hasEditVariable(variable(for: .intrinsicSizeY, on: subview)) {
				addIntrinsicSizeYConstraints(for: subview);
				createIntrinsicSizeYVariable(for: subview);
			}
			do {
				try solver.suggestValue(variable: variable(for: .intrinsicSizeY, on: subview), value: Double(subview.intrinsicContentSize.height));
			} catch {
				debugPrint("Could not suggest intrinsic height for \(subview): \(error)");
			}
		} else if solver.hasEditVariable(variable(for: .intrinsicSizeY, on: subview)) {
			removeIntrinsicSizeYConstraints(for: subview);
			removeIntrinsicSizeYVariable(for: subview);
		}
	}
	
	/// Converts an NSLayoutConstraint to Cassowary Constraint.
	internal func constraint(for constraint: NSLayoutConstraint) -> Cassowary.Constraint? {
		if let firstView = constraint.firstItem as? UIView {
			// Get the variable for the firstView's attribute.
			let firstVariable = variable(for: constraint.firstAttribute.propertyAttribute, on: firstView);
			// Convert the constraint priority to a cassowary priority.
			let priority = getPriority(for: constraint.priority);
			// Handle the special case where the secondAttribute is notAnAttribute, where the first property is bound to the constant.
			if constraint.secondAttribute == .notAnAttribute {
				switch constraint.relation {
				case .equal:
					return modifyStrength(firstVariable == Double(constraint.constant), priority);
				case .greaterThanOrEqual:
					return modifyStrength(firstVariable >= Double(constraint.constant), priority);
				case .lessThanOrEqual:
					return modifyStrength(firstVariable <= Double(constraint.constant), priority);
				}
			} else if let secondView = constraint.secondItem as? UIView {
				// Handle the other cases.
				// Get the variable for the second property
				let secondVariable = variable(for: constraint.secondAttribute.propertyAttribute, on: secondView);
				switch constraint.relation {
				case .equal:
					return modifyStrength(firstVariable == (Double(constraint.multiplier) * secondVariable) + Double(constraint.constant), priority);
				case .lessThanOrEqual:
					return modifyStrength(firstVariable <= (Double(constraint.multiplier) * secondVariable) + Double(constraint.constant), priority);
				case .greaterThanOrEqual:
					return modifyStrength(firstVariable >= (Double(constraint.multiplier) * secondVariable) + Double(constraint.constant), priority);
				}
			}
		}
		// Fallthrough and return nil.
		return nil;
	}
	
	internal func notifyContainerResized() {
		updateContainerVariables();
	}
	
	internal func notifyConstraintAdded(_ uiConstraint: NSLayoutConstraint) {
		addUIConstraint(for: uiConstraint);
	}
	
	internal func notifyConstraintRemoved(_ uiConstraint: NSLayoutConstraint) {
		removeUIConstraint(for: uiConstraint);
	}
	
	internal func notifyViewAdded(_ view: UIView) {
		addIntrinsicConstraints(for: view);
		updateIntrinsicSizeVariables(for: view);
	}
	
	internal func notifyViewRemoved(_ view: UIView) {
		removeIntrinsicConstraints(for: view);
		clearIntrinsicSizeVariablesIfNeeded(for: view);
		removeMarginInsetVariables(for: view);
	}
	
	internal func notifyMarginsChanged(on view: UIView) {
		updateMarginInsetVariables(for: view);
	}
	
	internal func notifyIntrinsicContentSizeInvalidated(on view: UIView) {
		updateIntrinsicSizeVariables(for: view);
	}
	
	// Lays out this view's subviews according to autoLayout constraints.
	@usableFromInline
	internal func autoLayout() {
		do {			
			solver.updateVariables();
			var autoLayoutContentSize = CGSize();
			for subview in container.subviews {
				subview.frame.origin.x = CGFloat(variable(for: .left, on: subview).value);
				subview.frame.origin.y = CGFloat(variable(for: .top, on: subview).value);
				subview.frame.size.width = CGFloat(variable(for: .width, on: subview).value);
				subview.frame.size.height = CGFloat(variable(for: .height, on: subview).value);
				// Calculate the lower-right point, and if it can't be contained in contained in autoLayoutContentSize, expand autoLayoutContentSize to accommodate it.
				let maxX = subview.frame.maxX;
				if maxX > autoLayoutContentSize.width {
					autoLayoutContentSize.width = maxX;
				}
				let maxY = subview.frame.maxY;
				if maxY > autoLayoutContentSize.height {
					autoLayoutContentSize.height = maxY;
				}
				subview.setNeedsDisplay();
			}
			// Now that we have the size to accommodate all autolayout content, add the appropriate margins.
			autoLayoutContentSize.width = autoLayoutContentSize.width + container.layoutMargins.right;
			autoLayoutContentSize.height = autoLayoutContentSize.height + container.layoutMargins.bottom;
			// Set the autolayout content size;
			container.autoLayoutContentSize = autoLayoutContentSize;
			container.setNeedsDisplay();
		} catch {
			debugPrint("Could not solve layout; Error: \(error)");
		}
	}
	
}
