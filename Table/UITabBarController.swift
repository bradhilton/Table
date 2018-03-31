//
//  UITabBarController.swift
//  Table
//
//  Created by Bradley Hilton on 2/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Tab {
    public let title: String
    public let key: AnyHashable?
    public let image: UIImage?
    public let selectedImage: UIImage?
    public let controller: Controller
    public var keyOrTitle: AnyHashable {
        return key ?? title as AnyHashable
    }
    public init(title: String, key: AnyHashable? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil, controller: Controller) {
        self.title = title
        self.key = key
        self.image = image
        self.selectedImage = selectedImage
        self.controller = controller
    }
}

private class TabBarControllerDelegate : NSObject, UITabBarControllerDelegate {
    
    init(_ tabBarController: UITabBarController) {
        super.init()
        tabBarController.delegate = self
    }
    
    var didSelectTab: ((AnyHashable) -> ())? = nil
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let didSelectTab = didSelectTab,
            let index = (tabBarController.viewControllers ?? []).index(of: viewController),
            tabBarController.tabs.count > index else {
            return true
        }
        let selectedTab = tabBarController.tabs[index].keyOrTitle
        guard selectedTab != tabBarController.selectedTab else { return false }
        defer { didSelectTab(selectedTab) }
        return false
    }
    
}

extension UITabBarItem {
    
    var untintedSelectedImage: UIImage? {
        get {
            return storage[\.untintedSelectedImage]
        }
        set {
            storage[\.untintedSelectedImage] = newValue
        }
    }
    
}

extension UITabBarController {
    
    public var tabs: [Tab] {
        get {
            return storage[\.tabs, default: []]
        }
        set {
            var pool = self.viewControllers ?? []
            let viewControllers: [UIViewController] = newValue.map { tab in
                let viewController = tab.controller.viewController(reusing: &pool, key: tab.keyOrTitle)
                viewController.tabBarItem.title = tab.title
                // MARK: Performance equality check
                if tab.image != viewController.tabBarItem.image {
                    viewController.tabBarItem.image = tab.image
                }
                // MARK: Performance equality check
                if tab.selectedImage != viewController.tabBarItem.untintedSelectedImage {
                    viewController.tabBarItem.untintedSelectedImage = tab.selectedImage
                    viewController.tabBarItem.selectedImage = tab.selectedImage
                }
                return viewController
            }
            setViewControllers(viewControllers, animated: viewIsVisible)
            let selectedIndex = tabs.index { $0.keyOrTitle == selectedTab } ?? self.selectedIndex
            // MARK: Performance equality check
            if selectedIndex != self.selectedIndex {
                self.selectedIndex = selectedIndex
            }
            storage[\.tabs] = newValue
        }
    }
    
    public func setSelectedTab<TabKey : Hashable>(_ tabKey: TabKey, didSelectTab: @escaping (TabKey) -> ()) {
        self.selectedTab = tabKey
        self.didSelectTab = { ($0.base as? TabKey).map(didSelectTab) }
    }
    
    public var selectedTab: AnyHashable {
        get {
            guard selectedIndex < tabs.endIndex else { return .auto }
            return tabs[selectedIndex].keyOrTitle
        }
        set {
            guard let index = tabs.index(where: { $0.keyOrTitle == newValue }) else { return }
            selectedIndex = index
        }
    }
    
    public var didSelectTab: ((AnyHashable) -> ())? {
        get {
            return defaultDelegate.didSelectTab
        }
        set {
            defaultDelegate.didSelectTab = newValue
        }
    }
    
    fileprivate var defaultDelegate: TabBarControllerDelegate {
        return storage[\.defaultDelegate, default: TabBarControllerDelegate(self)]
    }
    
}
