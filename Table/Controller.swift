//
//  Controller.swift
//  Table
//
//  Created by Bradley Hilton on 2/16/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Controller {
    
    let type: AnyHashable
    let key: AnyHashable
    let factory: () -> UIViewController
    let configure: (UIViewController) -> ()
    
    public init<Controller : UIViewController>(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        key: AnyHashable = .auto,
        class: Controller.Type = Controller.self,
        configure: @escaping (Controller) -> () = { _ in }
    ) {
        self.type = "\(Controller.self):\(file):\(function):\(line):\(column)"
        self.key = key
        self.factory = { Controller() }
        self.configure = { controller in
            guard let controller = controller as? Controller else { return }
            configure(controller)
        }
    }
    
    func newViewController() -> UIViewController {
        let viewController = factory()
        viewController.type = type
        UIView.performWithoutAnimation {
            configure(viewController)
        }
        return viewController
    }
    
}

var controllerTypeKey = "controllerType"
var controllerKeyKey = "controllerKey"
var presentedControllerKey = "presentedControllerKey"

extension UIViewController {
    
    var type: AnyHashable {
        get {
            return (objc_getAssociatedObject(self, &controllerTypeKey) as? AnyHashable) ?? (0 as AnyHashable)
        }
        set {
            objc_setAssociatedObject(self, &controllerTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var key: AnyHashable {
        get {
            return (objc_getAssociatedObject(self, &controllerKeyKey) as? AnyHashable) ?? (0 as AnyHashable)
        }
        set {
            objc_setAssociatedObject(self, &controllerKeyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var presentedController: Controller? {
        get {
            return objc_getAssociatedObject(self, &presentedControllerKey) as? Controller
        }
        set {
            objc_setAssociatedObject(self, &presentedControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if viewHasAppeared {
                presentController()
            }
        }
    }
    
    func presentController() {
        switch (presentedController, presentedViewController) {
        case (let controller?, let viewController?):
            if viewController.type == controller.type && viewController.key == controller.key {
                controller.configure(viewController)
            } else {
                viewController.dismiss(animated: true) {
                    self.present(controller.newViewController(), animated: true)
                }
            }
        case (let controller?, nil):
            self.present(controller.newViewController(), animated: true)
        case (nil, let viewController?):
            viewController.dismiss(animated: true, completion: nil)
        case (nil, nil):
            break
        }
    }
    
}

extension Array where Element == Controller {
    
    func viewControllers(using viewControllers: [UIViewController]) -> [UIViewController] {
        var pool = viewControllers
        return map { controller in
            guard let index = pool.index(where: { $0.type == controller.type && $0.key == controller.key }) else {
                return controller.newViewController()
            }
            let viewController = pool.remove(at: index)
            controller.configure(viewController)
            return viewController
        }
    }
    
}

var navigationControllersKey = "navigationControllers"

extension UINavigationController {
    
    public var controllers: [Controller] {
        get {
            return (objc_getAssociatedObject(self, &navigationControllersKey) as? [Controller]) ?? []
        }
        set {
            setViewControllers(newValue.viewControllers(using: viewControllers), animated: viewIsVisible)
            objc_setAssociatedObject(self, &navigationControllersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

var tabBarControllersKey = "tabBarControllers"

extension UITabBarController {
    
    public var controllers: [Controller] {
        get {
            return (objc_getAssociatedObject(self, &tabBarControllersKey) as? [Controller]) ?? []
        }
        set {
            setViewControllers(newValue.viewControllers(using: viewControllers ?? []), animated: viewIsVisible)
            objc_setAssociatedObject(self, &tabBarControllersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

var rootControllerKey = "rootController"

extension UIWindow {
    
    public var rootController: Controller? {
        get {
            return objc_getAssociatedObject(self, &rootControllerKey) as? Controller
        }
        set {
            guard let controller = newValue, let viewController = rootViewController else {
                return rootViewController = newValue?.newViewController()
            }
            if viewController.type == controller.type && viewController.key == controller.key {
                controller.configure(viewController)
            } else {
                UIView.transition(
                    with: self,
                    duration: 0.25,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.rootViewController = controller.newViewController()
                    },
                    completion: nil
                )
            }
            objc_setAssociatedObject(self, &rootControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

