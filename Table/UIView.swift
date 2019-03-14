//
//  UIView.swift
//  Table
//
//  Created by Bradley Hilton on 3/28/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIView {
    
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
    
    var isVisible: Bool {
        return window != nil && layer.isVisible
    }
    
}

extension CALayer {
    
    fileprivate var isVisible: Bool {
        return presentation()?.hasVisibleBoundsAndOpacity ?? hasVisibleBoundsAndOpacity
    }
    
    private var hasVisibleBoundsAndOpacity: Bool {
        return bounds.width > 0 && bounds.height > 0 && opacity > 0
    }
    
}

extension NSObjectProtocol where Self : UITextField {
    
    public var inputView: View? {
        get {
            return storage[\.inputView]
        }
        set {
            storage[\.inputView] = newValue
            inputView = newValue?.view(reusing: inputView)
        }
    }
    
    public var inputAccessoryView: View? {
        get {
            return storage[\.inputAccessoryView]
        }
        set {
            storage[\.inputAccessoryView] = newValue
            inputAccessoryView = newValue?.view(reusing: inputAccessoryView)
        }
    }
    
}

extension UIView {
    
    var breadthFirstSubviews: AnySequence<UIView> {
        var index = 0
        var subviews = self.subviews
        return AnySequence {
            return AnyIterator {
                guard index != subviews.endIndex else { return nil }
                let subview = subviews[index]
                subviews.append(contentsOf: subview.subviews)
                index += 1
                return subview
            }
        }
    }
    
    public func firstSubview<T : UIView>(class: T.Type = T.self, key: AnyHashable? = nil) -> T? {
        return breadthFirstSubviews.first { subview in
            guard
                let subview = subview as? T,
                key == nil || subview.key == key,
                subview.alpha > 0,
                !subview.isHidden
            else { return nil }
            return subview
        }
    }
    
}

func breadthFirstSubviews(of view: UIView) -> AnySequence<UIView> {
    return AnySequence(
        sequence(state: AnySequence(view.subviews)) { (state: inout AnySequence<UIView>) -> AnySequence<UIView>? in
            guard state.underestimatedCount > 0 || state.makeIterator().next() != nil else { return nil }
            defer {
                state = AnySequence(
                    [
                        state,
                        AnySequence(state.lazy.flatMap { $0.subviews })
                    ].lazy.flatMap { $0 }
                )
            }
            return state
        }.lazy.flatMap { $0 }
    )
}
