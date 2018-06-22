//
//  UISplitViewController.swift
//  AlertBuilder
//
//  Created by Bradley Hilton on 3/14/18.
//

//private class NavigationControllerDelegate : NSObject, UINavigationControllerDelegate {
//
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if let splitViewController = navigationController.splitViewController, !(viewController is UINavigationController) {
//            splitViewController.state?.willPopDetail()
//        }
//    }
//
//}
//
//private class SplitViewControllerDelegate : NSObject, UISplitViewControllerDelegate {
//
//    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
//        return !(splitViewController.state?.collapseDetailOntoMaster ?? false)
//    }
//
//    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
//        return splitViewController.detailViewController ?? splitViewController.state?.detail.newViewController()
//    }
//
//}

extension UISplitViewController {
    
//    public struct State {
//        public let master: Controller
//        public let detail: Controller
//        public let collapseDetailOntoMaster: Bool
//        public let willPopDetail: () -> ()
//        public init(master: Controller, detail: Controller, collapseDetailOntoMaster: Bool, willPopDetail: @escaping () -> ()) {
//            self.master = master
//            self.detail = detail
//            self.collapseDetailOntoMaster = collapseDetailOntoMaster
//            self.willPopDetail = willPopDetail
//        }
//    }
//
//    public var state: State? {
//        get {
//            return storage[\.state]
//        }
//        set {
//            storage[\.state] = newValue
//            delegate = defaultDelegate
//            guard let state = state else { return }
//            let masterViewController = self.masterViewController.flatMap { viewController in
//                guard viewController.type == state.master.type else { return nil }
//                viewController.update = state.master.update
//                return viewController
//            } ?? state.master.newViewController()
//            let detailViewController = self.detailViewController.flatMap { viewController in
//                guard viewController.type == state.detail.type else { return nil }
//                viewController.update = update
//                return viewController
//            } ?? state.detail.newViewController()
//            switch (isCollapsed, state.collapseDetailOntoMaster) {
//            case (true, true):
//                if !detailIsCollapsedOntoMaster {
//                    viewControllers = [masterViewController]
//                    showDetailViewController(detailViewController, sender: nil)
//                    detailViewController.navigationController?.delegate = navigationControllerDelegate
//                }
//            case (true, false):
//                if detailIsCollapsedOntoMaster {
//
//                }
//                viewControllers = [masterViewController]
//            case (false, _):
//                viewControllers = [masterViewController, detailViewController]
//            }
//        }
//    }
//
//    var masterViewController: UIViewController? {
//        return viewControllers.first
//    }
//
//    var detailViewController: UIViewController? {
//        return viewControllers.count == 2 ? viewControllers[1] : nil
//    }
//
//    var detailIsCollapsedOntoMaster: Bool {
//        return (masterViewController as? UINavigationController)?.viewControllers.last.map { $0 is UINavigationController } ?? false
//    }
//
//    private var defaultDelegate: SplitViewControllerDelegate {
//        return storage[\.defaultDelegate, default: SplitViewControllerDelegate()]
//    }
//
//    private var navigationControllerDelegate: NavigationControllerDelegate {
//        return storage[\.navigationControllerDelegate, default: NavigationControllerDelegate()]
//    }
    
}

public class SplitNavigationController : UISplitViewController, UISplitViewControllerDelegate {
    
    public typealias State = (master: NavigationItem, detail: NavigationItem, showDetailWhenCompact: Bool)
    
    public var state: State {
        didSet {
            detailNavigationController.root = state.detail
            update(isCompact: traitCollection.horizontalSizeClass == .compact)
        }
    }
    public let masterNavigationController: UINavigationController
    public let detailNavigationController: UINavigationController
    
    public init() {
        state = (NavigationItem { _ in }, NavigationItem { _ in }, false)
        masterNavigationController = UINavigationController()
        detailNavigationController = UINavigationController()
        super.init(nibName: nil, bundle: nil)
        preferredDisplayMode = .allVisible
        masterNavigationController.root = state.master
        detailNavigationController.root = state.detail
        delegate = self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [masterNavigationController, detailNavigationController]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        update(isCompact: true)
        return true
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        update(isCompact: false)
        return detailNavigationController
    }
    
    private var willPop: (() -> ())?
    
    func update(isCompact: Bool) {
        if isCompact, state.showDetailWhenCompact {
            state.detail.willPop = state.detail.willPop ?? willPop
            if !state.master.stack.contains(where: { $0 === state.detail }) {
                state.master.stack.last?.next = state.detail
            }
            masterNavigationController.root = state.master
        } else {
            if let item = state.master.stack.first(where: { $0.next === state.detail }) {
                willPop = state.detail.willPop.pop()
                item.next = nil
            }
            masterNavigationController.root = state.master
            // MARK: Performance equality check
            if viewControllers != [masterNavigationController, detailNavigationController] {
                viewControllers = [masterNavigationController, detailNavigationController]
            }
        }
    }
    
}
