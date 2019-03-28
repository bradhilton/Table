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
    
    var containerController: Controller {
        return ContainerController(key: keyOrTitle, childController: controller)
    }
    
    public init(
        title: String,
        key: AnyHashable? = nil,
        image: UIImage? = nil,
        selectedImage: UIImage? = nil,
        controller: Controller = Controller()
    ) {
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
            let index = (tabBarController.viewControllers ?? []).firstIndex(of: viewController),
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
                let viewController = tab.containerController.viewController(reusing: &pool)
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
            setViewControllers(viewControllers, animated: viewIsVisible && UIView.inheritedAnimationDuration > 0)
            let selectedIndex = tabs.firstIndex { $0.keyOrTitle == selectedTab } ?? self.selectedIndex
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
            guard let index = tabs.firstIndex(where: { $0.keyOrTitle == newValue }) else { return }
            if index != selectedIndex {
                UIView.performWithoutAnimation {
                    selectedIndex = index
                }
            }
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

extension UITabBar {
    
    public var tabs: [Tab] {
        get {
            return storage[\.tabs, default: []]
        }
        set {
            storage[\.tabs] = newValue
            var pool = items ?? []
            setItems(tabs.map { tab in
                    guard let item = pool.popFirst(where: { $0.key == tab.keyOrTitle }) else {
                        let item = UITabBarItem(title: tab.title, image: tab.image, selectedImage: tab.selectedImage)
                        item.key = tab.keyOrTitle
                        return item
                    }
                    return item
                },
                animated: UIView.inheritedAnimationDuration > 0
            )
            guard let item = items?.first(where: { $0.key == selectedTab }) else { return }
            selectedItem = item
        }
    }
    
    public var selectedTab: AnyHashable? {
        get {
            return storage[\.selectedTab]
        }
        set {
            storage[\.selectedTab] = newValue
            guard let item = items?.first(where: { $0.key == newValue }) else { return }
            selectedItem = item
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
    
    fileprivate var defaultDelegate: TabBarDelegate {
        return storage[\.defaultDelegate, default: TabBarDelegate(self)]
    }
    
}

private class TabBarDelegate : NSObject, UITabBarDelegate {
    
    var didSelectTab: ((AnyHashable) -> ())?
    
    init(_ tabBar: UITabBar) {
        super.init()
        tabBar.delegate = self
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let key = item.key else { return }
        didSelectTab?(key)
    }
    
}

