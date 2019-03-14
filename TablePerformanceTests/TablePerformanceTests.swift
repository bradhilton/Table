//
//  TablePerformanceTests.swift
//  TablePerformanceTests
//
//  Created by Bradley Hilton on 6/9/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import XCTest
import UIKit
@testable import Table

class TablePerformanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testInsertAboveSubview() {
        let view = UIView()
        for _ in 0..<1000 {
            view.addSubview(UIView())
        }
        self.measure {
            let reversedSubviews = view.subviews.reversed()
            var previousView = reversedSubviews.first!
            view.insertSubview(previousView, at: 0)
            for nextView in reversedSubviews.dropFirst() {
                view.insertSubview(nextView, aboveSubview: previousView)
                previousView = nextView
            }
        }
    }
    
    func testInsertAtIndex() {
        let view = UIView()
        for _ in 0..<1000 {
            view.addSubview(UIView())
        }
        self.measure {
            let reversedSubviews = view.subviews.reversed()
            var index = 0
            for nextView in reversedSubviews {
                view.insertSubview(nextView, at: index)
                index += 1
            }
        }
    }
    
    func testRemoveFirst() {
        self.measure {
            var removed = 0
            for _ in 0..<10000 {
                var array = Array(0..<20)
                while !array.isEmpty {
                    let value = array.removeFirst()
                    removed += 1
                }
            }
            print("Removed \(removed) elements")
        }
    }
    
    func testPopLast() {
        self.measure {
            var removed = 0
            for _ in 0..<10000 {
                var array = Array(0..<20)
                while !array.isEmpty {
                    let value = array.removeLast()
                    removed += 1
                }
            }
            print("Removed \(removed) elements")
        }
    }
    
    func testForLoop() {
        self.measure {
            var array = Array(0..<100_000)
            var seen = 0
            for element in array {
                seen += 1
            }
            print("Saw \(seen) elements")
        }
    }
    
    func testSetRefreshControlPerformance() {
        let scrollView = UIScrollView()
        let refreshControl1 = UIRefreshControl()
        let refreshControl2 = UIRefreshControl()
        
        func getRefreshControl(for index: Int) -> UIRefreshControl? {
            switch index % 9 {
            case 0, 1, 2:
                return refreshControl1
            case 3, 4, 5:
                return refreshControl2
            case 6, 7, 8:
                return nil
            default:
                fatalError()
            }
        }
        
        scrollView.refreshControl = refreshControl1
        
        let alwaysSetStartTime = Date()
        for i in 0..<100_000 {
            scrollView.refreshControl = getRefreshControl(for: i)
        }
        let alwaysSetDuration = Date().timeIntervalSince(alwaysSetStartTime)
        
        let conditionallySetStartTime = Date()
        for i in 0..<100_000 {
            let refreshControl = getRefreshControl(for: i)
            if (refreshControl != scrollView.refreshControl) {
                scrollView.refreshControl = refreshControl
            }
        }
        let conditionallySetDuration = Date().timeIntervalSince(conditionallySetStartTime)
        
        print(alwaysSetDuration, conditionallySetDuration)
        XCTAssert(conditionallySetDuration < alwaysSetDuration)
    }
    
    func testItemsDelta() {
        var items = (0..<10_000).map { _ in Item { _ in } }
        setIdentifiers(&items)
        _ = ItemsDelta(from: items, to: items)
        measure {
            _ = ItemsDelta(from: items, to: items)
        }
    }
    
}
