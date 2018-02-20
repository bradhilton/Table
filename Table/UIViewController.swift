//
//  UIViewController.swift
//  Table
//
//  Created by Bradley Hilton on 2/16/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

struct ControllerView<View : UIView> {
    
}

protocol ControllerProtocol {
    associatedtype ViewType
}

extension ControllerProtocol {
    
    
    
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
    
    private var isViewDirty: Bool {
        get {
            return storage[\.isViewDirty, default: false]
        }
        set {
            storage[\.isViewDirty] = newValue
        }
    }
    
    var viewIsVisible: Bool {
        return !(viewIfLoaded?.window == nil)
    }
    
    var viewHasAppeared: Bool {
        get {
            return storage[\.viewHasAppeared, default: false]
        }
        set {
            storage[\.viewHasAppeared] = newValue
        }
    }
    
    public var view: View {
        get {
            return storage[\.view, default: View()]
        }
        set {
            swizzleViewControllerMethods()
            if let uiview = viewIfLoaded {
                if uiview.window == nil {
                    isViewDirty = true
                } else {
                    newValue.configure(uiview)
                }
            }
            storage[\.view] = newValue
        }
    }
    
    @objc func swizzledViewDidLoad() {
        self.swizzledViewDidLoad()
        UIView.performWithoutAnimation {
            self.view.configure(self.viewIfLoaded!)
        }
    }
    
    @objc func swizzledViewWillAppear(animated: Bool) {
        self.swizzledViewWillAppear(animated: animated)
        if isViewDirty {
            isViewDirty = false
            UIView.performWithoutAnimation {
                self.view.configure(viewIfLoaded!)
            }
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
