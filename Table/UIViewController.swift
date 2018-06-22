//
//  UIViewController.swift
//  Table
//
//  Created by Bradley Hilton on 2/16/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension Optional {
    
    mutating func pop() -> Wrapped? {
        defer { self = .none }
        return self
    }
    
}

extension Sequence {
    
    func first<U>(where hasValue: (Element) -> U?) -> U? {
        for element in self {
            if let value = hasValue(element) {
                return value
            }
        }
        return nil
    }
    
}

let swizzleViewControllerMethods: () -> () = {
    method_exchangeImplementations(
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.swizzledViewDidLoad))!,
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidLoad))!
    )
    method_exchangeImplementations(
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.swizzledViewWillAppear))!,
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewWillAppear))!
    )
    method_exchangeImplementations(
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.swizzledViewDidAppear))!,
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidAppear))!
    )
    method_exchangeImplementations(
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.swizzledViewWillDisappear))!,
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewWillDisappear))!
    )
    method_exchangeImplementations(
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.swizzledViewDidLayoutSubviews))!,
        class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidLayoutSubviews))!
    )
    return {}
}()

extension UIViewController {
    
    public func firstSubview<T : UIView>(class: T.Type = T.self, key: AnyHashable? = nil) -> T? {
        return view.firstSubview(class: T.self, key: key)
            ?? childViewControllers.first { $0.firstSubview(class: T.self, key: key) }
    }
    
    var configureView: ((UIViewController) -> ())? {
        get {
            return storage[\.configureView]
        }
        set {
            swizzleViewControllerMethods()
            if viewIsVisible && storage[\.configureView] == nil {
                storage[\.configureView] = newValue
                newValue?(self)
            } else {
                storage[\.configureView] = newValue
            }
        }
    }
    
    var previousViewFrame: CGRect {
        get {
            return storage[\.previousViewFrame, default: .zero]
        }
        set {
            storage[\.previousViewFrame] = newValue
        }
    }
    
    var updateViewOnLayout: Bool {
        get {
            return storage[\.updateViewOnLayout, default: false]
        }
        set {
            storage[\.updateViewOnLayout] = newValue
        }
    }
    
    var updateView: ((UIViewController) -> ())? {
        get {
            return storage[\.updateView]
        }
        set {
            swizzleViewControllerMethods()
            if viewIsVisible {
                storage[\.updateView] = updateViewOnLayout ? newValue : nil
                newValue?(self)
            } else {
                storage[\.updateView] = newValue
            }
        }
    }
    
    var updateNavigationItem: ((UINavigationItem) -> ())? {
        get {
            return storage[\.updateNavigationItem]
        }
        set {
            swizzleViewControllerMethods()
            if viewIsVisible {
                storage[\.updateNavigationItem] = nil
                newValue?(self.navigationItem)
            } else {
                storage[\.updateNavigationItem] = newValue
            }
        }
    }
    
    var viewIsVisible: Bool {
        return viewIfLoaded?.window != nil
    }
    
    var viewHasAppeared: Bool {
        get {
            return storage[\.viewHasAppeared, default: false]
        }
        set {
            storage[\.viewHasAppeared] = newValue
        }
    }
    
    @objc func swizzledViewDidLoad() {
        self.swizzledViewDidLoad()
        UIView.performWithoutAnimation {
            configureView?(self)
            if !updateViewOnLayout {
                updateView.pop()?(self)
            }
        }
    }
    
    @objc func swizzledViewWillAppear(animated: Bool) {
        self.swizzledViewWillAppear(animated: animated)
        UIView.performWithoutAnimation {
            if !updateViewOnLayout {
                updateView.pop()?(self)
            }
            updateNavigationItem.pop()?(self.navigationItem)
        }
    }
    
    @objc func swizzledViewDidLayoutSubviews() {
        self.swizzledViewDidLayoutSubviews()
        if updateViewOnLayout && view.frame != previousViewFrame {
            if previousViewFrame == .zero {
                UIView.performWithoutAnimation {
                    updateView?(self)
                }
            } else {
                updateView?(self)
            }
        }
        previousViewFrame = view.frame
    }
    
    @objc func swizzledViewDidAppear(animated: Bool) {
        self.swizzledViewDidAppear(animated: animated)
        viewHasAppeared = true
        presentController()
    }
    
    @objc func swizzledViewWillDisappear(animated: Bool) {
        self.swizzledViewWillDisappear(animated: animated)
        viewHasAppeared = false
    }
    
}
