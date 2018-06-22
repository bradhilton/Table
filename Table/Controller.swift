//
//  Controller.swift
//  Table
//
//  Created by Bradley Hilton on 2/16/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Controller {
    
    let type: AnyHashable
    /// Creates a new instance of the view controller
    fileprivate let create: () -> UIViewController
    /// Configures the view controller before the view is loaded
    fileprivate let configureController: (UIViewController) -> ()
    /// Configures the view controller after the view is loaded
    fileprivate let configureView: (UIViewController) -> ()
    /// Updates the view controller immediately
    fileprivate let updateController: (UIViewController) -> ()
    /// If true, calls updateView every time the controller's layout changes.
    fileprivate let updateViewOnLayout: Bool
    /// Updates the view controller when visible
    fileprivate let updateView: (UIViewController) -> ()
    
    public init<Controller : UIViewController>(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        class: Controller.Type = Controller.self,
        create: @escaping () -> Controller = { Controller() },
        configureController: @escaping (Controller) -> () = { _ in },
        configureView: @escaping (Controller) -> () = { _ in },
        updateController: @escaping (Controller) -> () = { _ in },
        updateViewOnLayout: Bool = false,
        updateViewLayout: @escaping (Controller) -> () = { _ in },
        updateView: @escaping (Controller) -> () = { _ in }
    ) {
        self.type = "\(Controller.self):\(file):\(function):\(line):\(column)"
        self.create = create
        self.configureController = { ($0 as? Controller).map(configureController) }
        self.configureView = { ($0 as? Controller).map(configureView) }
        self.updateController = { ($0 as? Controller).map(updateController) }
        self.updateViewOnLayout = updateViewOnLayout
        self.updateView = { ($0 as? Controller).map(updateView) }
    }
    
    func matches(key: AnyHashable) -> (UIViewController) -> Bool {
        return { $0.type == self.type && $0.key == key }
    }
    
    func viewController(reusing pool: inout [UIViewController], key: AnyHashable = .auto) -> UIViewController {
        guard let index = pool.index(where: matches(key: key)) else {
            return newViewController(key: key)
        }
        let viewController = pool.remove(at: index)
        viewController.update(with: self)
        return viewController
    }
    
    func viewController(reusing viewController: UIViewController?) -> UIViewController {
        guard let viewController = viewController, viewController.type == type else {
            return newViewController()
        }
        viewController.update(with: self)
        return viewController
    }
    
    public func newViewController(key: AnyHashable = .auto) -> UIViewController {
        let viewController = create()
        viewController.type = type
        viewController.key = key
        configureController(viewController)
        viewController.configureView = configureView
        viewController.update(with: self)
        return viewController
    }
    
}

extension UIViewController {
    
    public func update(with controller: Controller) {
        controller.updateController(self)
        updateViewOnLayout = controller.updateViewOnLayout
        updateView = controller.updateView
    }
    
    var previousPresentedController: Controller? {
        get {
            return storage[\.previousPresentedController]
        }
        set {
            storage[\.previousPresentedController] = newValue
        }
    }
    
    public var presentedController: Controller? {
        get {
            return storage[\.presentedController]
        }
        set {
            guard presentedController != nil || newValue != nil else { return }
            swizzleViewControllerMethods()
            previousPresentedController = presentedController
            storage[\.presentedController] = newValue
            presentController()
        }
    }
    
    func presentController() {
        switch (presentedController, presentedViewController) {
        case (let controller?, let viewController?):
            if viewController.type == controller.type {
                viewController.update(with: controller)
            } else {
                viewController.dismiss(animated: true) {
                    self.presentController()
                }
            }
        case (let controller?, nil):
            guard viewHasAppeared else { return }
            present(controller.newViewController(), animated: true)
        case (nil, let viewController?):
            guard let previousPresentedController = previousPresentedController, previousPresentedController.type == viewController.type
            else { return }
            viewController.dismiss(animated: true) {
                self.presentController()
            }
        case (nil, nil):
            break
        }
    }
    
}

extension UIWindow {
    
    public var rootController: Controller? {
        get {
            return storage[\.rootController]
        }
        set {
            storage[\.rootController] = newValue
            guard let controller = rootController, let viewController = rootViewController else {
                return rootViewController = rootController?.newViewController()
            }
            if viewController.type == controller.type {
                viewController.update(with: controller)
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
        }
    }
    
}

