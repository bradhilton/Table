//
//  Subviews.swift
//  Table
//
//  Created by Bradley Hilton on 6/1/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Subview {
    let key: AnyHashable
    let constraints: [Constraint]
    let view: View?
    
    public init(
        key: AnyHashable = .auto,
        constraints: [Constraint],
        view: View? = nil
    ) {
        self.key = key
        self.constraints = constraints
        self.view = view
    }
    
}

struct ResolvedConstraint {
    let firstItem: AnyObject
    let firstAttribute: NSLayoutAttribute
    let relation: NSLayoutRelation
    let secondItem: AnyObject?
    let secondAttribute: NSLayoutAttribute
    let multiplier: CGFloat
    let constant: CGFloat
    let priority: UILayoutPriority
    
    init(constraint: Constraint, firstItem: AnyObject, secondItem: AnyObject?) {
        self.firstItem = firstItem
        self.firstAttribute = constraint.attribute
        self.relation = constraint.relation
        self.secondItem = secondItem ?? (constraint.targetAttribute != .notAnAttribute ? firstItem : nil)
        self.secondAttribute = constraint.targetAttribute
        self.multiplier = constraint.multiplier
        self.constant = constraint.constant
        self.priority = constraint.priority
    }
    
}

struct ResolvedConstraintType : Hashable {}

extension NSLayoutConstraint {
    
    func matches(_ constraint: ResolvedConstraint) -> Bool {
        return firstItem === constraint.firstItem
            && firstAttribute == constraint.firstAttribute
            && relation == constraint.relation
            && secondItem === constraint.secondItem
            && secondAttribute == constraint.secondAttribute
            && Float(multiplier) == Float(constraint.multiplier)
    }
    
    convenience init(_ constraint: ResolvedConstraint) {
        self.init(
            item: constraint.firstItem,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: constraint.multiplier,
            constant: constraint.constant
        )
        type = ResolvedConstraintType()
        priority = constraint.priority
    }
    
}

fileprivate protocol ItemProtocol : class {
    var key: AnyHashable? { get }
    var constraintsAffectingLayout: [NSLayoutConstraint] { get }
}

extension ItemProtocol {
    
    var resolvedConstraintsAffectingLayout: [NSLayoutConstraint] {
        return constraintsAffectingLayout.filter { $0.firstItem === self && $0.type == ResolvedConstraintType() as AnyHashable }
    }
    
}

extension UILayoutGuide : ItemProtocol {
    
    fileprivate var constraintsAffectingLayout: [NSLayoutConstraint] {
        if #available(iOS 10.0, *) {
            return constraintsAffectingLayout(for: .horizontal) + constraintsAffectingLayout(for: .vertical)
        } else {
            return []
        }
    }
    
}

extension NSObjectProtocol where Self : UIView {
    
    public var subviews: [Subview] {
        get {
            return storage[\.subviews, default: []]
        }
        set {
            swizzleViewMethods()
            storage[\.subviews] = newValue
            if window != nil {
                updateSubviews(newValue)
            } else {
                shouldUpdateSubviews = true
            }
        }
    }
    
}

private let swizzleViewMethods: () -> () = {
    method_exchangeImplementations(
        class_getInstanceMethod(UIView.self, #selector(UIView.swizzledDidMoveToWindow))!,
        class_getInstanceMethod(UIView.self, #selector(UIView.didMoveToWindow))!
    )
    return {}
}()

extension UIView : ItemProtocol {
    
    fileprivate var shouldUpdateSubviews: Bool {
        get {
            return storage[\.shouldUpdateSubviews, default: false]
        }
        set {
            storage[\.shouldUpdateSubviews] = newValue
        }
    }
    
    @objc fileprivate func swizzledDidMoveToWindow() {
        swizzledDidMoveToWindow()
        if window != nil, shouldUpdateSubviews {
            UIView.performWithoutAnimation {
                updateSubviews(subviews)
            }
        }
    }
    
    public func setSubviews(_ subviews: [Subview]) {
        self.subviews = subviews
    }
    
    fileprivate var constraintsAffectingLayout: [NSLayoutConstraint] {
        return constraintsAffectingLayout(for: .horizontal) + constraintsAffectingLayout(for: .vertical)
    }
    
    fileprivate func updateSubviews(_ subviews: [Subview]) {
        shouldUpdateSubviews = false
        let (newItems, updatedItems, removedItems) = resolvedItems(for: subviews)
        UIView.performWithoutAnimation {
            updateConstraints(for: newItems)
        }
        updateConstraints(for: updatedItems)
        newItems.compactMap { $0.item as? UIView }.forEach { view in
            let alpha = view.isRemoved && view.alpha == 0 ? 1 : view.alpha
            view.isRemoved = false
            UIView.performWithoutAnimation {
                view.alpha = 0
            }
            view.alpha = alpha
        }
        removedItems.forEach { item in
            if let view = item as? UIView {
                view.isRemoved = true
                view.alpha = 0
            }
        }
    }
    
    private var isRemoved: Bool {
        get {
            return storage[\.isRemoved, default: false]
        }
        set {
            storage[\.isRemoved] = newValue
        }
    }
    
    // MARK: Return resolved items for subviews
    
    private typealias ConstrainedItem<Constraint> = (item: ItemProtocol, constraints: [Constraint])
    private typealias ConstrainedItems<Constraint> = (
        newItems: [ConstrainedItem<Constraint>],
        updatedItems: [ConstrainedItem<Constraint>],
        removedItems: [ItemProtocol]
    )
    
    private func resolvedItems(for subviews: [Subview]) -> ConstrainedItems<ResolvedConstraint> {
        let (newItems, updatedItems, removedItems) = items(for: subviews)
        let siblings = Dictionary(
            uniqueKeysWithValues: (newItems + updatedItems)
                .map { $0.item }
                .filter { $0.key != .auto }
                .compactMap { item in
                    item.key.map { key in
                        (key, item)
                    }
                }
        )
        let resolvedItems = { (item: ItemProtocol, constraints: [Constraint]) in
            ConstrainedItem(
                item: item,
                constraints: constraints.map(self.resolvedConstraint(for: item, with: siblings))
            )
        }
        return (
            newItems: newItems.map(resolvedItems),
            updatedItems: updatedItems.map(resolvedItems),
            removedItems: removedItems
        )
    }
    
    private func items(for constrainedChildren: [Subview]) -> ConstrainedItems<Constraint> {
        var subviewsPool = subviews.indexedPool
        var layoutGuidesPool = layoutGuides.filter { $0.key != nil }
        var lastIndexAndView: (Int, UIView)?
        let itemsAndConstraints: [(item: ItemProtocol, constraints: [Constraint], isNew: Bool)] = constrainedChildren.map { child in
            if let view = child.view {
                let (index, uiview) = indexAndView(for: view, with: child.key, reusing: &subviewsPool)
                defer {
                    uiview.translatesAutoresizingMaskIntoConstraints = false
                    if let (lastIndex, lastView) = lastIndexAndView, index <= lastIndex {
                        insertSubview(uiview, aboveSubview: lastView)
                        lastIndexAndView = (lastIndex, uiview)
                    } else {
                        if uiview.superview != self {
                            insertSubview(uiview, at: 0)
                        }
                        lastIndexAndView = (index, uiview)
                    }
                }
                return (uiview, child.constraints, uiview.superview != self || uiview.isRemoved)
            } else if let layoutGuideIndex = layoutGuidesPool.index(where: { $0.key == child.key }) {
                let layoutGuide = layoutGuidesPool.remove(at: layoutGuideIndex)
                return (layoutGuide, child.constraints, false)
            } else {
                let layoutGuide = UILayoutGuide()
                layoutGuide.key = child.key
                addLayoutGuide(layoutGuide)
                return (layoutGuide, child.constraints, true)
            }
        }
        return (
            newItems: itemsAndConstraints.filter { $0.isNew }.map { ($0.item, $0.constraints) },
            updatedItems: itemsAndConstraints.filter { !$0.isNew }.map { ($0.item, $0.constraints) },
            removedItems: subviewsPool.values.flatMap { $0.lazy.map { $1 } } as [ItemProtocol] + layoutGuidesPool as [ItemProtocol]
        )
    }
    
    private func resolvedConstraint(for item: AnyObject, with siblings: [AnyHashable: AnyObject]) -> (Constraint) -> ResolvedConstraint {
        return { constraint in
            ResolvedConstraint(
                constraint: constraint,
                firstItem: item,
                secondItem: self.secondItem(for: constraint.target, with: siblings)
            )
        }
    }
    
    private func secondItem(for target: Target?, with siblings: [AnyHashable: AnyObject]) -> AnyObject? {
        return target.map { target in
            switch target {
            case .superview: return self
            case .superviewSafeArea:
                if #available(iOS 11.0, *) {
                    return safeAreaLayoutGuide
                } else {
                    fatalError()
                }
            case .superviewMargins: return layoutMarginsGuide
            case .superviewReadableContent: return readableContentGuide
            case .keyboard: return window?.keyboardLayoutGuide ?? self
            case .sibling(let key): return siblings[key]!
            }
        }
    }
    
    // MARK: Update constraints for items
    
    private func updateConstraints(for constrainedItems: [ConstrainedItem<ResolvedConstraint>]) {
        let (activated, deactivated) = constraints(for: constrainedItems)
        NSLayoutConstraint.deactivate(deactivated)
        NSLayoutConstraint.activate(activated)
        layoutIfNeeded()
    }
    
    private func constraints(for items: [ConstrainedItem<ResolvedConstraint>]) -> (activated: [NSLayoutConstraint], deactivated: [NSLayoutConstraint]) {
        let constraints = items.map(constraints(for:with:))
        return (constraints.flatMap { $0.activated }, constraints.flatMap { $0.deactivated })
    }
    
    private func constraints(for item: ItemProtocol, with resolvedConstraints: [ResolvedConstraint]) -> (activated: [NSLayoutConstraint], deactivated: [NSLayoutConstraint]) {
        var constraintsPool = self.constraintsPool(for: item)
        let activatedConstraints: [NSLayoutConstraint] = resolvedConstraints.compactMap { resolvedConstraint in
            if let constraint = constraintsPool.popFirst(where: { $0.matches(resolvedConstraint) }) {
                constraint.constant = resolvedConstraint.constant
                constraint.priority = resolvedConstraint.priority
                return !constraint.isActive ? constraint : nil
            } else {
                return NSLayoutConstraint(resolvedConstraint)
            }
        }
        return (activatedConstraints, constraintsPool)
    }
    
    private func constraintsPool(for item: ItemProtocol) -> [NSLayoutConstraint] {
        return constraints.filter { $0.firstItem === item && $0.type == ResolvedConstraintType() as AnyHashable }
            + ((item as? UIView)?.constraints.filter { $0.firstItem === item && $0.type == ResolvedConstraintType() as AnyHashable } ?? [])
    }
    
}
