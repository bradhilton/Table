//
//  UINavigationController.swift
//  XTable
//
//  Created by Bradley Hilton on 3/14/18.
//


extension UINavigationItem {
    
    var allBarButtonItems: [UIBarButtonItem] {
        return (leftBarButtonItems ?? []) + (rightBarButtonItems ?? [])
    }
    
}

public class NavigationItem {
    public var key: AnyHashable = .auto
    public var title: String? = nil
    public var titleView: View? = nil
    public var prompt: String? = nil
    public var controller = Controller()
    public var rightBarButtonItems: [BarButtonItem] = []
    public var leftBarButtonItems: [BarButtonItem] = []
    public var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .automatic
    public var searchController: SearchController? = nil
    public var hidesSearchBarWhenScrolling: Bool = true
    public var willPop: (() -> ())? = nil
    public var next: NavigationItem?
    public var presentedController: Controller?
    
    public init(_ build: (NavigationItem) -> ()) {
        build(self)
    }
    
    public init(
        key: AnyHashable = .auto,
        title: String? = nil,
        controller: Controller
    ) {
        self.key = key
        self.title = title
        self.controller = controller
    }
    
    var stack: [NavigationItem] {
        var next = self.next
        var stack = [self]
        while let element = next {
            stack.append(element)
            next = element.next
        }
        return stack
    }
    
    var containerController: Controller {
        return ContainerController(key: key, childController: controller, presentedController: presentedController)
    }
    
    func updateItem(for controller: UIViewController) {
        let item = controller.navigationItem
        let bar = controller.navigationController?.navigationBar
        let editButtonItem = controller.editButtonItem
        editButtonItem.type = editButtonItemType
        editButtonItem.key = editButtonItemKey
        item.title = title
        if let titleView = titleView?.view(reusing: item.titleView) {
            item.titleView = titleView
        } else {
            UIView.performWithoutAnimation { item.titleView = nil }
        }
        item.prompt = prompt
        var pool = item.allBarButtonItems + [editButtonItem]
//        var pool = item.allBarButtonItems + (bar?.topItem?.allBarButtonItems ?? []) + (bar?.backItem?.allBarButtonItems ?? []) + [editButtonItem]
        item.setRightBarButtonItems(rightBarButtonItems.objects(reusing: &pool), animated: true)
        item.setLeftBarButtonItems(leftBarButtonItems.objects(reusing: &pool), animated: true)
        item.leftBarButtonItems?.forEach { $0.viewController = bar?.viewController }
        item.rightBarButtonItems?.forEach { $0.viewController = bar?.viewController }
        if #available(iOS 11.0, *) {
            item.largeTitleDisplayMode = largeTitleDisplayMode
            item.searchController = searchController?.object(reusing: item.searchController)
            item.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling
        }
    }
    
}

private class NavigationControllerDelegate : NSObject, UINavigationControllerDelegate {
    
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        guard let stack = navigationController.stack else { return }
//        if stack.count > navigationController.viewControllers.count {
//            stack.last?.willPop?()
//        }
//    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let stack = navigationController.stack else { return }
        if stack.count > navigationController.viewControllers.count {
            stack.last?.willPop?()
        }
    }
    
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return operation == .push && fromVC.navigationItem.key == toVC.navigationItem.key ? CrossFadeTransition(duration: UIView.inheritedAnimationDuration) : nil
//    }
    
}

private class CrossFadeTransition : NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        transitionContext.containerView.addSubview(toView)
        toView.alpha = 0
        UIView.animate(
            withDuration: duration,
            animations: {
                toView.alpha = 1
            },
            completion: { completed in
                transitionContext.completeTransition(completed)
            }
        )
    }
    
}

extension UINavigationController {
    
    public var root: NavigationItem? {
        get {
            return stack?.first
        }
        set {
            stack = newValue?.stack
        }
    }
    
    public var stack: [NavigationItem]? {
        get {
            return storage[\.stack]
        }
        set {
            self.delegate = defaultDelegate
            guard let stack = newValue else {
                storage[\.stack] = nil
                self.viewControllers = []
                return
            }
            var pool = self.viewControllers
            let viewControllers: [UIViewController] = stack.map { viewController(for: $0, with: &pool) }
            if viewControllers != self.viewControllers {
                setViewControllers(viewControllers, animated: viewIsVisible && (stack.count != (self.stack ?? []).count || stack.last?.key != self.stack?.last?.key))
            }
            storage[\.stack] = stack
        }
    }
    
    private func viewController(for item: NavigationItem, with pool: inout [UIViewController]) -> UIViewController {
        let viewController = item.containerController.viewController(reusing: &pool)
        viewController.navigationItem.key = item.key
        if isViewLoaded {
            // MARK: Immediately update title, do a performance equality check
            if item.title != viewController.navigationItem.title {
                viewController.navigationItem.title = item.title
            }
            viewController.updateNavigationItem = { viewController in
                item.updateItem(for: viewController)
            }
        } else /* configureController */ {
            item.updateItem(for: viewController)
        }
        return viewController
    }
    
    fileprivate var defaultDelegate: NavigationControllerDelegate {
        return storage[\.defaultDelegate, default: NavigationControllerDelegate()]
    }
    
}

extension NSObjectProtocol where Self : UIToolbar {
    
    public var items: [BarButtonItem]? {
        get {
            return storage[\.items]
        }
        set {
            storage[\.items] = newValue
            items = newValue?.objects(reusing: items ?? [])
        }
    }
    
}
