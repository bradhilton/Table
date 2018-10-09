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
    
    var layout: (UIView) -> () {
        get {
            return storage[\.layout, default: { _ in }]
        }
        set {
            storage[\.layout] = newValue
            newValue(self)
        }
    }
    
    @objc func swizzledLayoutSubviews() {
        swizzledLayoutSubviews()
        layout(self)
    }
    
    public func firstSubview<T : UIView>(class: T.Type = T.self, key: AnyHashable? = nil) -> T? {
        for subview in subviews {
            if let view = subview as? T, key == nil || view.key == key, view.alpha > 0, !view.isHidden {
                return view
            } else if let view = subview.firstSubview(class: T.self, key: key) {
                return view
            }
        }
        return nil
    }
    
}
