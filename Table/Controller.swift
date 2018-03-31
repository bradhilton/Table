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
    public let create: () -> UIViewController
    /// Configures the view controller after the view is loaded
    public let configure: (UIViewController) -> ()
    /// Updates the view controller when visible
    public let update: (UIViewController) -> ()
    
    public init<Controller : UIViewController>(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        class: Controller.Type = Controller.self,
        create: @escaping () -> Controller = { Controller() },
        configure: @escaping (Controller) -> () = { _ in },
        update: @escaping (Controller) -> () = { _ in }
    ) {
        self.type = "\(Controller.self):\(file):\(function):\(line):\(column)"
        self.create = create
        self.configure = { ($0 as? Controller).map(configure) }
        self.update = { ($0 as? Controller).map(update) }
    }
    
    func matches(key: AnyHashable) -> (UIViewController) -> Bool {
        return { $0.type == self.type && $0.key == key }
    }
    
    func viewController(reusing pool: inout [UIViewController], key: AnyHashable = .auto) -> UIViewController {
        guard let index = pool.index(where: matches(key: key)) else {
            return self.newViewController(key: key)
        }
        let viewController = pool.remove(at: index)
        viewController.update = update
        return viewController
    }
    
    public func newViewController(key: AnyHashable = .auto) -> UIViewController {
        let viewController = create()
        viewController.type = type
        viewController.key = key
        viewController.configure = configure
        viewController.update = update
        return viewController
    }
    
}

extension UIViewController {
    
    public var presentedController: Controller? {
        get {
            return storage[\.presentedController]
        }
        set {
            swizzleViewControllerMethods()
            storage[\.presentedController] = newValue
            if viewHasAppeared {
                presentController()
            }
        }
    }
    
    func presentController() {
        switch (presentedController, presentedViewController) {
        case (let controller?, let viewController?):
            if viewController.type == controller.type {
                viewController.update = controller.update
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
                viewController.update = controller.update
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

