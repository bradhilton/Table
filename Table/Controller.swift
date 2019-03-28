//
//  Controller.swift
//  Table
//
//  Created by Bradley Hilton on 2/16/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Controller {
    
    let type: AnyHashable
    public var key: AnyHashable
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
        line: Int = #line,
        column: Int = #column,
        key: AnyHashable = .auto,
        class: Controller.Type = Controller.self,
        instance: @escaping @autoclosure () -> Controller = Controller(),
        configureController: @escaping (Controller) -> () = { _ in },
        configureView: @escaping (Controller) -> () = { _ in },
        updateController: @escaping (Controller) -> () = { _ in },
        updateViewOnLayout: Bool = false,
        updateViewLayout: @escaping (Controller) -> () = { _ in },
        updateView: @escaping (Controller) -> () = { _ in }
    ) {
        self.type = UniqueDeclaration(file: file, line: line, column: column)
        self.key = key
        self.create = instance
        self.configureController = { ($0 as? Controller).map(configureController) }
        self.configureView = { ($0 as? Controller).map(configureView) }
        self.updateController = { ($0 as? Controller).map(updateController) }
        self.updateViewOnLayout = updateViewOnLayout
        self.updateView = { ($0 as? Controller).map(updateView) }
    }
    
    func viewController(reusing pool: inout [UIViewController]) -> UIViewController {
        guard let index = pool.firstIndex(where: { $0.type == type && $0.key == key }) else {
            return newViewController()
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
    
    public func newViewController() -> UIViewController {
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
        if viewIsVisible {
            controller.updateController(self)
        } else {
            UIView.performWithoutAnimation {
                controller.updateController(self)
            }
        }
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
            let viewController = controller.newViewController()
            if
                let popoverPresentationController = viewController.popoverPresentationController,
                let sourceViewKey = popoverPresentationController.sourceViewKey,
                let sourceView = firstSubview(key: sourceViewKey)
            {
                popoverPresentationController.sourceView = sourceView
                if let sourceRectGetter = popoverPresentationController.sourceRectGetter {
                    popoverPresentationController.sourceRect = sourceRectGetter(sourceView)
                }
            }
            present(viewController, animated: true)
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
                    duration: UIView.inheritedAnimationDuration,
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

