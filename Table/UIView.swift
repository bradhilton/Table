//
//  UIView.swift
//  Table
//
//  Created by Bradley Hilton on 3/28/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

class KeyboardLayoutGuide : UILayoutGuide {
    
    var leftConstraint: NSLayoutConstraint?
    var topConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(selector), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func selector(notification: Notification) {
        guard let windowFrame = ((notification as Notification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let frame = owningView?.convert(windowFrame, from: nil),
            let duration = (notification as Notification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
            else { return }
        UIView.animate(withDuration: duration) {
            self.leftConstraint?.constant = frame.origin.x
            self.topConstraint?.constant = frame.origin.y
            self.widthConstraint?.constant = frame.width
            self.heightConstraint?.constant = frame.height
            self.owningView?.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView {
    
    public var keyboardLayoutGuide: UILayoutGuide {
        return storage[\.keyboardLayoutGuide, default: createKeyboardLayoutGuide()]
    }
    
    func createKeyboardLayoutGuide() -> KeyboardLayoutGuide {
        let guide = KeyboardLayoutGuide()
        addLayoutGuide(guide)
        guide.leftConstraint = guide.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        guide.topConstraint = guide.topAnchor.constraint(equalTo: topAnchor, constant: 1000)
        guide.widthConstraint = guide.widthAnchor.constraint(equalToConstant: 0)
        guide.heightConstraint = guide.heightAnchor.constraint(equalToConstant: 0)
        guide.leftConstraint?.isActive = true
        guide.topConstraint?.isActive = true
        guide.widthConstraint?.isActive = true
        guide.heightConstraint?.isActive = true
        return guide
    }
    
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
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

private let swizzleViewMethods: () -> () = {
    method_exchangeImplementations(
        class_getInstanceMethod(UIView.self, #selector(UIView.swizzledLayoutSubviews))!,
        class_getInstanceMethod(UIView.self, #selector(UIView.layoutSubviews))!
    )
    return {}
}()

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
    
    @objc fileprivate func swizzledLayoutSubviews() {
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
