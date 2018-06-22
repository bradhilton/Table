//
//  ControllerView.swift
//  Table
//
//  Created by Bradley Hilton on 4/26/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public class ContainerView : UIView {
    
    var childViewController: UIViewController
    
    public var controller: Controller {
        didSet {
            if controller.type == oldValue.type {
                childViewController.update(with: controller)
            } else if let viewController = viewController {
                let newChildViewController = controller.newViewController()
                viewController.addChildViewController(newChildViewController)
                if viewController.viewIsVisible {
                    viewController.transition(
                        from: childViewController,
                        to: newChildViewController,
                        duration: 0.25,
                        options: [.transitionCrossDissolve],
                        animations: {
                            self.addChildView(newChildViewController.view)
                        },
                        completion: { _ in
                            viewController.removeFromParentViewController()
                            newChildViewController.didMove(toParentViewController: viewController)
                        }
                    )
                } else {
                    childViewController.view.removeFromSuperview()
                    childViewController.removeFromParentViewController()
                    childViewController = controller.newViewController()
                    viewController.addChildViewController(childViewController)
                    addChildView(childViewController.view)
                    childViewController.didMove(toParentViewController: viewController)
                }
            }
        }
    }
    
    override public init(frame: CGRect) {
        self.controller = Controller()
        self.childViewController = self.controller.newViewController()
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addChildView(_ childView: UIView) {
        addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        childView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        childView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        childView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if childViewController.type != controller.type {
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParentViewController()
            childViewController = controller.newViewController()
            viewController?.addChildViewController(childViewController)
            addChildView(childViewController.view)
            childViewController.didMove(toParentViewController: viewController)
        }
    }
    
}
