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
            storage[\.arrangedSubviews] = newValue
            var arrangedSubviewsPool = arrangedSubviews.indexedPool
            let indicesAndViews: [(Int, UIView)] = newValue.map { child in
                return indexAndView(for: child.view, with: child.key, reusing: &arrangedSubviewsPool)
            }
            for subview in arrangedSubviewsPool.values.flatMap({ subviews in subviews.map { $0.1 } }) {
                subview.isHidden = true
            }
            for (_, view) in indicesAndViews {
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            let arrangedSubviewsSet = Set(arrangedSubviews)
            var lastIndex = 0
//            var insertionIndex = 0
            for (index, view) in indicesAndViews {
                if index <= lastIndex {
                    if arrangedSubviewsSet.contains(view) {
                        insertArrangedSubview(view, at: index)
                    } else {
                        UIView.performWithoutAnimation {
                            view.isHidden = true
                            insertArrangedSubview(view, at: index)
                            layoutSubviews()
                        }
                    }
                } else {
                    lastIndex = index
                }
                view.isHidden = false
//                insertionIndex += 1
            }
        }
    }
    
}
