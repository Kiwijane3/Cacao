//
//  File.swift
//  
//
//  Created by Jane Fraser on 3/12/19.
//

import Foundation

public class UIStackView: UIView {
	
	public enum Alignment {
		case fill
		case leading
		case top
		case center
		case trailing
		case bottom
	}
	
	public enum Distribution {
		case fill
		case fillEqually
		case fillProportionally
		case equalSpacing
	}
	
	public private(set) var arrangedSubviews: [UIView] = [];
	
	public var alignment: Alignment = .fill {
		didSet {
			switch axis {
			case .horizontal:
				switch alignment {
				case .leading:
					alignment = .top;
				case .trailing:
					alignment = .bottom;
				default:
					break;
				}
			case .vertical:
				switch alignment {
				case .top:
					alignment = .leading;
				case .bottom:
					alignment = .trailing;
				default:
					break;
				}
			default:
				break;
			}
		}
	}
	
	public var axis: NSLayoutConstraint.Axis = .horizontal {
		didSet {
			switch axis {
			case .horizontal:
				switch alignment {
				case .leading:
					alignment = .top;
				case .trailing:
					alignment = .bottom;
				default:
					break;
				}
			case .vertical:
				switch alignment {
				case .top:
					alignment = .leading;
				case .bottom:
					alignment = .trailing;
				default:
					break;
				}
			default:
				break;
			}
		}
	}
	
	public var distribution: Distribution = .fill;
	
	public var spacing: CGFloat = 8.0;
	
	public var isLayoutMarginsRelativeArrangement: Bool = false;
	
	private var cachedIntrinsicSize: CGSize = .zero;
	
	// The index of the view to be compressed if view size exceeds the available size. This is the first view with the lowest content compression resistance priority.
	private var viewToCompress: Int {
		get {
			var candidate = 0;
			if self.arrangedSubviews.count > 1 {
				for index in 1..<arrangedSubviews.count {
					if arrangedSubviews[index].contentCompressionResistancePriority(for: axis) < arrangedSubviews[candidate].contentCompressionResistancePriority(for: axis) {
						candidate = index;
					}
				}
			}
			return candidate;
		}
	}
	
	// The index of the view to expanded if the distribution is fill and there is excess space. This is the first view with the lowest content hugging priority.
	private var viewToExpand: Int {
		get {
			var candidate = 0;
			for index in 1..<arrangedSubviews.count {
				if arrangedSubviews[index].contentHuggingPriority(for: axis) < arrangedSubviews[candidate].contentHuggingPriority(for: axis) {
					candidate = index;
				}
			}
			return candidate;
		}
	}
	
	public override var intrinsicContentSize: CGSize {
		get {
			return cachedIntrinsicSize;
		}
	}
	
	public init(arrangedSubviews: [UIView]) {
		self.arrangedSubviews = arrangedSubviews;
		super.init(frame: .zero);
	}
	
	public override init(frame: CGRect) {
		super.init(frame: .zero);
	}
	
	public func addArrangedSubview(_ view: UIView) {
		self.addSubview(view);
		self.arrangedSubviews.append(view);
		self.recalculateIntrinsicSize();
		self.setNeedsLayout();
	}
	
	public func insertArrangedSubview(_ view: UIView, at index: Int) {
		self.addSubview(view);
		self.arrangedSubviews.insert(view, at: index);
		self.recalculateIntrinsicSize();
		self.setNeedsLayout();
	}
	
	public func removeArrangedSubview(_ view: UIView) {
		view.removeFromSuperview();
		if let arrangedIndex = self.arrangedSubviews.firstIndex(of: view) {
			self.arrangedSubviews.remove(at: arrangedIndex);
			self.recalculateIntrinsicSize();
			self.setNeedsLayout();
		}
	}
	
	public override func childIntrinsicSizeChanged() {
		self.recalculateIntrinsicSize();
	}
	
	public override func layoutSubviews() {
		switch axis {
		case .horizontal:
			calculateHorizontalDistribution();
			calculateVerticalAlignment();
		case .vertical:
			calculateVerticalDistribution();
			calculateHorizontalAlignment();
		default:
			break;
		}
	}
	
	private func recalculateIntrinsicSize() {
		if arrangedSubviews.count > 0 {
			switch axis {
			case .horizontal:
				// The width is based on the total width of the contained views plus spacing and horizontal margins.
				let totalViewWidth = arrangedSubviews.reduce(0) { (sum, view) in
					return sum + view.intrinsicContentSize.width;
				}
				let totalSpacing = CGFloat( self.arrangedSubviews.count + 1 ) * spacing;
				let totalXMargin: CGFloat;
				if isLayoutMarginsRelativeArrangement {
					totalXMargin = self.layoutMargins.left + self.layoutMargins.right;
				} else {
					totalXMargin = 0;
				}
				cachedIntrinsicSize.width = totalViewWidth + totalSpacing + totalXMargin;
				// The height is the size to accommodate the tallest view within the view margins.
				let maxIntrinsicHeight = self.arrangedSubviews.reduce(-CGFloat.infinity) { (currentMax, view) in
					if view.intrinsicContentSize.height > currentMax {
						return view.intrinsicContentSize.height;
					} else {
						return currentMax;
					}
				}
				let totalYMargin = self.layoutMargins.top + self.layoutMargins.bottom;
				cachedIntrinsicSize.height = maxIntrinsicHeight + totalYMargin;
			case .vertical:
				// The height is based on the total height of the contained views plus spacing and vertical margins.
				let totalViewHeight = arrangedSubviews.reduce(0) { (sum, view) in
					return sum + view.intrinsicContentSize.height;
				}
				let totalSpacing = CGFloat( self.arrangedSubviews.count - 1) * spacing;
				let totalYMargin: CGFloat;
				if isLayoutMarginsRelativeArrangement {
					totalYMargin = self.layoutMargins.top + self.layoutMargins.bottom;
				} else {
					totalYMargin = 0;
				}
				// The width is the size to accommodate the widest view within the view margins.
				cachedIntrinsicSize.height = totalViewHeight + totalSpacing + totalYMargin;
				let maxIntrinsicWidth = self.arrangedSubviews.reduce(-CGFloat.infinity) { (currentMax, view) in
					if view.intrinsicContentSize.width > currentMax {
						return view.intrinsicContentSize.width;
					} else {
						return currentMax;
					}
				}
			default:
				break;
			}
			invalidateIntrinsicContentSize();
		}
	}
	
	// Calculates the horizontal distribution when the axis is horizontal.
	private func calculateHorizontalDistribution() {
		if arrangedSubviews.count > 0 {
			// Calculate the width of each view;
			var widths: [CGFloat] = [];
			let totalIntrinsicWidth = arrangedSubviews.reduce(0) { (sum, view) in
				return sum + view.intrinsicContentSize.width;
			};
			var availableSpace = frame.width - CGFloat(arrangedSubviews.count + 1) * spacing;
			if isLayoutMarginsRelativeArrangement {
				availableSpace += layoutMargins.left + layoutMargins.right;
			}
			let excess = availableSpace - totalIntrinsicWidth;
			var layoutSpacing: CGFloat = spacing;
			switch distribution {
			case .equalSpacing, .fill:
				// Calculate initial widths based on intrinsic widths.
				widths = arrangedSubviews.compactMap({ (view) in
					return view.intrinsicContentSize.width;
				});
				switch distribution {
				case .equalSpacing:
				// If there is excess space, expand the spacing to accommodate.
				if excess > 0 {
					spacing += excess / CGFloat(arrangedSubviews.count + 1);
				// If there is insufficient space, compress the first view with the lowest compression resistance.
				} else if excess < 0 {
					widths[viewToCompress] -= excess;
				}
				case .fill:
				if excess > 0 {
					widths[viewToExpand] += excess;
				} else if excess < 0 {
					widths[viewToCompress] -= excess;
				}
				default:
					break;
				}
			case .fillEqually:
				// Calculate the widths such that all views have the same width and fill all the available space.
				let width = availableSpace / CGFloat(arrangedSubviews.count);
				widths = Array(repeating: width, count: arrangedSubviews.count);
			case .fillProportionally:
				let proportions = arrangedSubviews.compactMap { (view) in
					return view.intrinsicContentSize.width / totalIntrinsicWidth;
				}
				widths = proportions.compactMap { (proportion) in
					return proportion * availableSpace;
				}
			}
			// Track the insertion x point, beginning at spacing from origin, and insert each view at the tracked point.
			var tracker = spacing;
			for index in 0..<arrangedSubviews.count {
				let view = arrangedSubviews[index];
				view.frame.origin.x = tracker;
				view.frame.size.width = widths[index];
				// Advance the tracker by the width of the assigned view and spacing.
				tracker += view.frame.width + spacing;
			}
		}
	}
	
	private func calculateVerticalDistribution() {
		if arrangedSubviews.count > 0 {
			// Calculate the width of each view;
			var heights: [CGFloat] = [];
			let totalIntrinsicHeight = arrangedSubviews.reduce(0) { (sum, view) in
				return sum + view.intrinsicContentSize.height;
			};
			var availableSpace = frame.height - CGFloat(arrangedSubviews.count + 1) * spacing;
			if isLayoutMarginsRelativeArrangement {
				availableSpace += layoutMargins.top + layoutMargins.bottom;
			}
			let excess = availableSpace - totalIntrinsicHeight;
			var layoutSpacing: CGFloat = spacing;
			switch distribution {
			case .equalSpacing, .fill:
				// Calculate initial widths based on intrinsic widths.
				heights = arrangedSubviews.compactMap({ (view) in
					return view.intrinsicContentSize.height;
				});
				switch distribution {
				case .equalSpacing:
				// If there is excess space, expand the spacing to accommodate.
				if excess > 0 {
					spacing += excess / CGFloat(arrangedSubviews.count + 1);
				// If there is insufficient space, compress the first view with the lowest compression resistance.
				} else if excess < 0 {
					heights[viewToCompress] -= excess;
				}
				case .fill:
				if excess > 0 {
					heights[viewToExpand] += excess;
				} else if excess < 0 {
					heights[viewToCompress] -= excess;
				}
				default:
					break;
				}
			case .fillEqually:
				// Calculate the widths such that all views have the same width and fill all the available space.
				let height = availableSpace / CGFloat(arrangedSubviews.count);
				heights = Array(repeating: height, count: arrangedSubviews.count);
			case .fillProportionally:
				let proportions = arrangedSubviews.compactMap { (view) in
					return view.intrinsicContentSize.height / totalIntrinsicHeight;
				}
				heights = proportions.compactMap { (proportion) in
					return proportion * availableSpace;
				}
			}
			// Track the insertion x point, beginning at spacing from origin, and insert each view at the tracked point.
			var tracker = spacing;
			for index in 0..<arrangedSubviews.count {
				let view = arrangedSubviews[index];
				view.frame.origin.y = tracker;
				view.frame.size.height = heights[index];
				// Advance the tracker by the width of the assigned view and spacing.
				tracker += view.frame.height + spacing;
			}
		}
	}
	
	private func calculateVerticalAlignment() {
		if arrangedSubviews.count > 0 {
			for view in arrangedSubviews {
				switch alignment {
				case .fill:
					view.frame.origin.y = layoutMargins.top;
					view.frame.size.height - frame.height - layoutMargins.top - layoutMargins.bottom;
				case .top:
					view.frame.origin.y = layoutMargins.top;
					view.frame.size.height = view.intrinsicContentSize.height;
				case .center:
					view.frame.size.height = view.intrinsicContentSize.height;
					view.frame.origin.y = (frame.height / 2) - (view.frame.height / 2);
				case .bottom:
					view.frame.size.height = view.intrinsicContentSize.height;
					view.frame.origin.y = frame.height - layoutMargins.bottom - view.frame.height;
				default:
					break;
				}
			}
		}
	}
	
	private func calculateHorizontalAlignment() {
		if arrangedSubviews.count > 0 {
		for view in arrangedSubviews {
				switch alignment {
				case .fill:
					view.frame.origin.x = layoutMargins.left;
					view.frame.size.width - frame.width - layoutMargins.left - layoutMargins.right;
				case .top:
					view.frame.origin.x = layoutMargins.left;
					view.frame.size.height = view.intrinsicContentSize.height;
				case .center:
					view.frame.size.width = view.intrinsicContentSize.width;
					view.frame.origin.x = (frame.width / 2) - (view.frame.width / 2);
				case .bottom:
					view.frame.size.width = view.intrinsicContentSize.width;
					view.frame.origin.x = frame.width - layoutMargins.right - view.frame.width;
				default:
					break;
				}
			}
		}
	}
	
}
