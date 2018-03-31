//
//  PerformanceTests.swift
//  Table
//
//  Created by Bradley Hilton on 1/19/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

import XCTest
import Table
import UIKit

final class Stack<Element> {
    
    var count: Int = 0
    var node: Node? = nil
    
    class Node {
        let element: Element
        let previous: Node?
        init(element: Element, previous: Node?) {
            self.element = element
            self.previous = previous
        }
    }
    
    func push(_ element: Element) {
        node = Node(element: element, previous: node)
        count += 1
    }
    
    func pop() -> Element? {
        guard let node = node else { return nil }
        self.node = node.previous
        count -= 1
        return node.element
    }
    
}

final class CacheKey : NSObject {
    
    let key: AnyHashable
    
    init(_ key: AnyHashable) {
        self.key = key
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CacheKey else {
            return false
        }
        return key == other.key
    }
    
    override var hash: Int {
        return key.hashValue
    }
    
}

final class ViewCache {
    
    private let stackLimit = 12000
    private let cache = NSCache<CacheKey, Stack<UIView>>()
    
    init() {
        cache.totalCostLimit = 12000
    }
    
    func push(view: UIView, for type: AnyHashable) {
        let key = CacheKey(type)
        let stack = cache.object(forKey: key) ?? Stack()
        if stack.count < stackLimit {
            stack.push(view)
            cache.setObject(stack, forKey: key, cost: stack.count)
        }
    }
    
    func popView(for type: AnyHashable) -> UIView? {
        let key = CacheKey(type)
        guard let stack = cache.object(forKey: key), let view = stack.pop() else {
            return nil
        }
        cache.setObject(stack, forKey: key, cost: stack.count)
        return view
    }
    
}

class PerformanceTests: XCTestCase {
    
    func testCreateViews() {
        measure {
            let views = (0..<1000).map { _ in UIView() }
            XCTAssert(views.count == 1000)
        }
    }
    
    func testReuseViewsCache() {
        let viewCache = ViewCache()
        for _ in 0..<10000 {
            viewCache.push(view: UIView(), for: 0)
        }
        measure {
            let views = (0..<1000).flatMap { _ in viewCache.popView(for: 0) }
            XCTAssert(views.count == 1000)
        }
    }
    
    func testReuseViewsArray() {
        var viewsCache = (0..<20000).map { _ in UIView() }
        measure {
            let views: [UIView] = (0..<1000).flatMap { _ in
                for index in viewsCache.indices {
                    if index == 1000 {
                        return viewsCache.remove(at: index)
                    }
                }
                return nil
            }
            XCTAssert(views.count == 1000)
        }
    }
    
    func testSetNavigationItemTitle() {
        let navigationItem = UINavigationItem()
        navigationItem.title = "Home"
        measure {
            for _ in 0..<10_000 {
                navigationItem.title = "Home"
            }
        }
    }
    
    func testSetNavigationItemTitleWithEqualityCheck() {
        let navigationItem = UINavigationItem()
        navigationItem.title = "Home"
        measure {
            for _ in 0..<10_000 {
                if navigationItem.title != "Home" {
                    navigationItem.title = "Home"
                }
            }
        }
    }
    
}
