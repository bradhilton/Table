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
        return Controller(
            updateController: { (controller: ContainerViewController) in
                controller.setChildController(self.controller)
            }
        )
    }
    
    func updateItem(_ item: UINavigationItem, bar: UINavigationBar?) {
        item.title = title
        if let titleView = titleView?.view(reusing: item.titleView) {
            item.titleView = titleView
        } else {
            UIView.performWithoutAnimation { item.titleView = nil }
        }
        item.prompt = prompt
        var pool = item.allBarButtonItems + (bar?.topItem?.allBarButtonItems ?? []) + (bar?.backItem?.allBarButtonItems ?? [])
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
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let stack = navigationController.stack else { return }
        if stack.count > navigationController.viewControllers.count {
            stack.last?.willPop?()
        }
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
            interactivePopGestureRecognizer?.isEnabled = false
            self.delegate = defaultDelegate
            guard let stack = newValue else {
                storage[\.stack] = nil
                self.viewControllers = []
                return
            }
            var pool = self.viewControllers
            let viewControllers: [UIViewController] = stack.map { viewController(for: $0, with: &pool) }
            if viewControllers != self.viewControllers {
                let animated = viewIsVisible && (stack.map { $0.key } != (self.stack ?? []).map { $0.key })
                setViewControllers(viewControllers, animated: animated)
            }
            storage[\.stack] = stack
        }
    }
    
    private func viewController(for item: NavigationItem, with pool: inout [UIViewController]) -> UIViewController {
        let viewController = item.containerController.viewController(reusing: &pool, key: item.key)
        if isViewLoaded {
            // MARK: Immediately update title, do a performance equality check
            if item.title != viewController.navigationItem.title {
                viewController.navigationItem.title = item.title
            }
            viewController.updateNavigationItem = { [weak self] navigationItem in
                item.updateItem(navigationItem, bar: self?.navigationBar)
            }
        } else /* configureController */ {
            item.updateItem(viewController.navigationItem, bar: self.navigationBar)
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
