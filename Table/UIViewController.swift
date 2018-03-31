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
    return {}
}()

extension UIViewController {
    
    var configure: ((UIViewController) -> ())? {
        get {
            return storage[\.configure]
        }
        set {
            swizzleViewControllerMethods()
            if viewIsVisible {
                newValue?(self)
            } else {
                storage[\.configure] = newValue
            }
        }
    }
    
    var update: ((UIViewController) -> ())? {
        get {
            return storage[\.update]
        }
        set {
            swizzleViewControllerMethods()
            if viewIsVisible {
                newValue?(self)
            } else {
                storage[\.update] = newValue
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
            configure.pop()?(self)
        }
    }
    
    @objc func swizzledViewWillAppear(animated: Bool) {
        self.swizzledViewWillAppear(animated: animated)
        UIView.performWithoutAnimation {
            configure.pop()?(self)
            updateNavigationItem.pop()?(self.navigationItem)
            update.pop()?(self)
        }
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
    
//    #if DEBUG
//    @objc func injected() {
//        viewIfLoaded.map { uiview in view.configure(uiview) }
//    }
//    #endif
    
}
