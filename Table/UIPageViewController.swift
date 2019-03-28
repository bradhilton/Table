//
//  UIPageViewController.swift
//  Table
//
//  Created by Bradley Hilton on 4/27/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIView {
    
    fileprivate func findView<T : UIView>() -> T? {
        if let view = self as? T { return view }
        for subview in subviews {
            if let view = subview.findView() as? T { return view }
        }
        return nil
    }
    
}

private class DefaultDelegate : NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageViewController.containerViewControllers.firstIndex(of: viewController) else { return nil }
        if index == 0 {
            return pageViewController.cycleControllers ? pageViewController.containerViewControllers.last : nil
        } else {
            return pageViewController.containerViewControllers[index - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageViewController.containerViewControllers.firstIndex(of: viewController) else { return nil }
        if index == pageViewController.containerViewControllers.endIndex - 1 {
            return pageViewController.cycleControllers ? pageViewController.containerViewControllers.first : nil
        } else {
            return pageViewController.containerViewControllers[index + 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.first,
            let index = pageViewController.containerViewControllers.firstIndex(of: viewController),
            index != pageViewController.selectedIndex
            else { return }
        pageViewController.selectedIndex = index
        pageViewController.didSelectIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageViewController.containerViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pageViewController.selectedIndex
    }
    
}

extension UIPageViewController {
    
    public var cycleControllers: Bool {
        get {
            return storage[\.cycleControllers, default: false]
        }
        set {
            storage[\.cycleControllers] = newValue
        }
    }
    
    public var pageControl: UIPageControl? {
        return view.findView()
    }
    
    public func setControllers(_ controllers: [Controller]) {
        setControllers(controllers, selectedIndex: selectedIndex, didSelectIndex: didSelectIndex)
    }
    
    public func setControllers(
        _ controllers: [Controller],
        selectedIndex: Int,
        didSelectIndex: @escaping (Int) -> ()
    ) {
        delegate = defaultDelegate
        dataSource = defaultDelegate
        var pool = containerViewControllers
        containerViewControllers = controllers
            .map { ContainerController(childController: $0) }
            .map { controller in controller.viewController(reusing: &pool) }
        setViewControllers(
            [containerViewControllers[selectedIndex]],
            direction: selectedIndex < self.selectedIndex ? .reverse : .forward,
            animated: viewIsVisible
        )
        self.selectedIndex = selectedIndex
        self.didSelectIndex = didSelectIndex
    }
    
    fileprivate var selectedIndex: Int {
        get {
            return storage[\.selectedIndex, default: 0]
        }
        set {
            storage[\.selectedIndex] = newValue
        }
    }
    
    fileprivate var didSelectIndex: (Int) -> () {
        get {
            return storage[\.didSelectIndex, default: { _ in }]
        }
        set {
            storage[\.didSelectIndex] = didSelectIndex
        }
    }
    
    fileprivate var containerViewControllers: [UIViewController] {
        get {
            return storage[\.containerViewControllers, default: []]
        }
        set {
            storage[\.containerViewControllers] = newValue
        }
    }
    
    private var defaultDelegate: DefaultDelegate {
        return storage[\.defaultDelegate, default: DefaultDelegate()]
    }
    
}
