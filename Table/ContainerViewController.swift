//
//  ContainerViewController.swift
//  Table
//
//  Created by Bradley Hilton on 4/23/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public func ContainerController(key: AnyHashable = .auto, childController: Controller, presentedController: Controller? = nil) -> Controller {
    return Controller(
        key: key,
        updateController: { (controller: ContainerViewController) in
            controller.childController = childController
            controller.presentedController = presentedController
        }
    )
}

public class ContainerViewController : UIViewController {
    
    public var childController: Controller = Controller() {
        didSet {
            if let viewController = childViewControllers.last {
                if viewController.type == childController.type, viewController.key == childController.key {
                    viewController.update(with: childController)
                } else {
                    let newViewController = childController.newViewController()
                    addChildViewController(newViewController)
                    addChildView(newViewController.view)
                    if viewIsVisible {
                        transition(
                            from: viewController,
                            to: newViewController,
                            duration: UIView.inheritedAnimationDuration,
                            options: [.transitionCrossDissolve],
                            animations: {},
                            completion: { _ in
                                viewController.removeFromParentViewController()
                                newViewController.didMove(toParentViewController: self)
                            }
                        )
                    } else {
                        viewController.view.removeFromSuperview()
                        viewController.removeFromParentViewController()
                        newViewController.didMove(toParentViewController: self)
                    }
                }
            } else {
                let newViewController = childController.newViewController()
                addChildViewController(newViewController)
                addChildView(newViewController.view)
                newViewController.didMove(toParentViewController: self)
            }
        }
    }
    
    func addChildView(_ childView: UIView) {
        UIView.performWithoutAnimation {
            view.addSubview(childView)
            childView.translatesAutoresizingMaskIntoConstraints = false
            childView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            childView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            childView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            childView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
    
    override public var editButtonItem: UIBarButtonItem {
        return childViewControllers.last?.editButtonItem ?? super.editButtonItem
    }
    
}
