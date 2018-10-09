//
//  UIStackView.swift
//  Table
//
//  Created by Bradley Hilton on 10/4/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension NSObjectProtocol where Self : UIStackView {
    
    public var arrangedSubviews: [ArrangedSubview] {
        get {
            return storage[\.arrangedSubviews, default: []]
        }
        set {
            swizzleViewMethods()
            storage[\.arrangedSubviews] = newValue
            guard let window = window else {
                shouldUpdateArrangedSubviews = true
                return
            }
            shouldUpdateArrangedSubviews = false
            updateArrangedSubviews(window: window)
        }
    }
    
}

extension UIStackView {
    
    var shouldUpdateArrangedSubviews: Bool {
        get {
            return storage[\.shouldUpdateArrangedSubviews, default: false]
        }
        set {
            storage[\.shouldUpdateArrangedSubviews] = newValue
        }
    }
    
    func updateArrangedSubviews(window: UIWindow) {
        let newValue: [ArrangedSubview] = arrangedSubviews
        var arrangedSubviewsPool = Dictionary(
            uniqueKeysWithValues: arrangedSubviews.lazy.compactMap { $0.typeAndKey != nil ? ($0.typeAndKey!, $0) : nil }
        )
        let views = newValue.map { ($0.key, $0.view) }.views(reusing: &arrangedSubviewsPool)
        let diff = ChildDiff(
            newChildren: views,
            oldChildren: arrangedSubviews.map { ChildAndState(child: $0, state: $0.childState) }
        )
        print(diff.map { ($0 as! UILabel).text! })
        let (newConstraints, visibleConstraints) = zip(newValue.map { $0.constraints }, views).constraints(superview: self, window: window)
        UIView.performWithoutAnimation {
            for child in diff.removeChildren {
                child.removeFromSuperview()
            }
            for (child, index) in diff.insertNewChildren {
                child.isHidden = true
                insertArrangedSubview(child, at: index)
            }
            updateConstraints(newConstraints)
            layoutIfNeeded()
        }
        for (child, index) in diff.moveVisibleChildren {
            insertArrangedSubview(child, at: index)
        }
        updateConstraints(visibleConstraints)
        let set = Set(views)
        for child in arrangedSubviews {
            child.isHidden = !set.contains(child)
        }
        for (view, uiview) in zip(newValue, views) {
            if #available(iOS 11.0, *) {
                setCustomSpacing(view.spacingAfterView, after: uiview)
            }
        }
        layoutIfNeeded()
    }
    
}
