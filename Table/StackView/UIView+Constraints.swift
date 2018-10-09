//
//  UIView+Constraints.swift
//  Table
//
//  Created by Bradley Hilton on 10/8/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension Sequence where Element == ([Constraint], UIView) {
    
    func constraints(superview: UIView, window: UIWindow) -> (
        newConstraints: (activated: [NSLayoutConstraint], deactivated: [NSLayoutConstraint]),
        visibleConstraints: (activated: [NSLayoutConstraint], deactivated: [NSLayoutConstraint])
    ) {
        let siblings = lazy.map { $1 }.siblings
        let constraints = map { (constraints, view) in
            return (
                constraints: view.constraints(
                    for: constraints.resolvedConstraints(
                        view: view,
                        superview: superview,
                        window: window,
                        siblings: siblings
                    )
                ),
                isVisible: view.isVisible
            )
        }
        return (
            newConstraints: (
                activated: constraints.lazy.filter { !$0.isVisible }.flatMap { $0.constraints.activated },
                deactivated: constraints.lazy.filter { !$0.isVisible }.flatMap { $0.constraints.deactivated }
            ),
            visibleConstraints: (
                activated: constraints.lazy.filter { $0.isVisible }.flatMap { $0.constraints.activated },
                deactivated: constraints.lazy.filter { $0.isVisible }.flatMap { $0.constraints.deactivated }
            )
        )
    }
    
}

extension Sequence where Element : NSObject {
    
    var siblings: [AnyHashable: AnyObject] {
        return Dictionary(uniqueKeysWithValues: filter { $0.key != nil && $0.key != .auto }.map { ($0.key!, $0) })
    }
    
}

extension Array where Element == Constraint {
    
    func resolvedConstraints(view: UIView, superview: UIView, window: UIWindow, siblings: [AnyHashable: AnyObject]) -> [ResolvedConstraint] {
        return map { constraint in
            ResolvedConstraint(
                constraint: constraint,
                firstItem: view,
                secondItem: constraint.target.map { $0.item(superview: superview, window: window, siblings: siblings) }
            )
        }
    }
    
}

extension UIView {
    
    func updateConstraints(_ constraints: (activated: [NSLayoutConstraint], deactivated: [NSLayoutConstraint])) {
        let (activated, deactivated) = constraints
        NSLayoutConstraint.deactivate(deactivated)
        NSLayoutConstraint.activate(activated)
    }
    
    func constraints(for resolvedConstraints: [ResolvedConstraint]) -> (activated: [NSLayoutConstraint], deactivated: [NSLayoutConstraint]) {
        var pool = constraintsPool
        return (
            activated: resolvedConstraints.compactMap { resolvedConstraint in
                if let constraint = pool.popFirst(where: { $0.matches(resolvedConstraint) }) {
                    return !constraint.isActive ? constraint : nil
                } else {
                    return NSLayoutConstraint(resolvedConstraint)
                }
            },
            deactivated: pool
        )
    }
    
    private var constraintsPool: [NSLayoutConstraint] {
        let allConstraints: [NSLayoutConstraint] = (superview?.constraints ?? []) + constraints
        return allConstraints.filter { $0.firstItem === self && $0.type == ResolvedConstraintType() as AnyHashable }
    }
    
}
