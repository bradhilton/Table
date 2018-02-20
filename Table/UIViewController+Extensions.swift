//
//  UIViewController+Extensions.swift
//  Table
//
//  Created by Bradley Hilton on 2/16/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

var isViewDirtyKey = "isViewDirty"
var viewHasAppearedKey = "viewHasAppeared"
var viewKey = "view"
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
            return (objc_getAssociatedObject(self, &isViewDirtyKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &isViewDirtyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var viewIsVisible: Bool {
        return !(viewIfLoaded?.window == nil)
    }
    
    var viewHasAppeared: Bool {
        get {
            return (objc_getAssociatedObject(self, &viewHasAppearedKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &viewHasAppearedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var view: View {
        get {
            return (objc_getAssociatedObject(self, &viewKey) as? View) ?? View()
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
            objc_setAssociatedObject(self, &viewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
