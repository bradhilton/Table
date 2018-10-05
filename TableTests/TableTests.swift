//
//  TableTests.swift
//  TableTests
//
//  Created by Bradley Hilton on 6/9/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import XCTest
@testable import Table

class TableTests: XCTestCase {
    
    func testConstraints() {
        let constraint = .left == superview.left
        let parentView = UIView()
        let view = UIView()
        parentView.addSubview(view)
        let resolvedConstraint = ResolvedConstraint(constraint: constraint, firstItem: view, secondItem: parentView)
        let nsconstraint = NSLayoutConstraint(resolvedConstraint)
        
        XCTAssertEqual(view, nsconstraint.firstItem as? UIView)
        XCTAssertEqual(constraint.attribute, .left)
        XCTAssertEqual(constraint.attribute, nsconstraint.firstAttribute)
        XCTAssertEqual(constraint.relation, .equal)
        XCTAssertEqual(constraint.relation, nsconstraint.relation)
        XCTAssertEqual(parentView, nsconstraint.secondItem as? UIView)
        XCTAssertEqual(constraint.targetAttribute, .left)
        XCTAssertEqual(constraint.targetAttribute, nsconstraint.secondAttribute)
        XCTAssertEqual(constraint.multiplier, 1)
        XCTAssertEqual(constraint.multiplier, nsconstraint.multiplier)
        XCTAssertEqual(constraint.constant, 0)
        XCTAssertEqual(constraint.constant, nsconstraint.constant)
        XCTAssertEqual(constraint.priority, .required)
        XCTAssertEqual(constraint.priority, nsconstraint.priority)
        
        let constraints: DictionaryLiteral<Constraint, Constraint> = [
            .left == superview.left
                : Constraint(.left, equalTo: superview.left),
            .left == superview.left + 8
                : Constraint(.left, equalTo: superview.left, constant: 8),
            .left == superview.left | .defaultHigh
                :  Constraint(.left, equalTo: superview.left, priority: .defaultHigh),
            .left == superview.left + 8 | .defaultHigh
                : Constraint(.left, equalTo: superview.left, constant: 8, priority: .defaultHigh),
            .width == superview.width
                : Constraint(.width, equalTo: superview.width),
            .width == superview.width * 0.8
                : Constraint(.width, equalTo: superview.width, multiplier: 0.8),
            .width == superview.width * 0.8 + 8
                : Constraint(.width, equalTo: superview.width, multiplier: 0.8, constant: 8),
            .width == superview.width * 0.8 + 8 | .defaultHigh
                : Constraint(.width, equalTo: superview.width, multiplier: 0.8, constant: 8, priority: .defaultHigh),
            .width == .width
                : Constraint(.width, equalTo: .width),
            .width == .width * 0.8
                : Constraint(.width, equalTo: .width, multiplier: 0.8),
            .width == .width * 0.8 + 8
                : Constraint(.width, equalTo: .width, multiplier: 0.8, constant: 8),
            .width == .width * 0.8 + 8 | .defaultHigh
                : Constraint(.width, equalTo: .width, multiplier: 0.8, constant: 8, priority: .defaultHigh),
            .width == 8
                : Constraint(.width, equalTo: 8),
            .width == 8 | .defaultHigh
                : Constraint(.width, equalTo: 8, priority: .defaultHigh)
        ]
        for (lhs, rhs) in constraints {
            XCTAssertEqual(lhs, rhs)
        }
        for (lhs, rhs) in zip(constraints.map({ $0.key }), constraints.dropFirst().map({ $0.value })) {
            XCTAssertNotEqual(lhs, rhs)
        }
    }
    
    func testChildDiff() {
        var state: [(key: AnyHashable, state: ChildState)] = []
        
        var visibleChildren = ["A", "B", "C"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, visibleChildren)
        
        visibleChildren = ["A", "C"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["A", "B", "C"])
        
        visibleChildren = ["A", "C", "D", "E"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["A", "B", "C", "D", "E"])
        
        visibleChildren = ["B", "D", "E", "F"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["A", "B", "C", "D", "E", "F"])
        
        visibleChildren = ["A", "B", "F"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["A", "B", "C", "D", "E", "F"])
        
        visibleChildren = ["G", "H", "A", "B", "I", "F"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["G", "H", "A", "B", "I", "C", "D", "E", "F"])
        
        visibleChildren = ["G", "H", "B", "A", "I", "F"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["G", "H", "B", "A", "I", "C", "D", "E", "F"])
        
        visibleChildren = ["I", "C", "H", "B", "K", "A", "G"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["I", "C", "D", "E", "F", "H", "B", "K", "A", "G"])
        
        visibleChildren = ["M", "K", "C", "E", "L", "G", "B"]
        state.update(with: visibleChildren)
        XCTAssertEqual(state.visibleChildren, visibleChildren)
        XCTAssertEqual(state.children, ["M", "I", "K", "A", "C", "D", "E", "L", "F", "H", "G", "B"])
    }
    
}

struct Update {
    let `as`: [AnyHashable]
    let all: [AnyHashable]
}

extension Array where Element == (key: AnyHashable, state: ChildState) {
    
    var children: [AnyHashable] {
        return map { $0.key }
    }
    
    var visibleChildren: [AnyHashable] {
        return filter { $0.state == .visible }.children
    }
    
    mutating func update(with newChildren: [AnyHashable]) {
        let diff = ChildDiff(newChildren: newChildren, oldChildren: self)
        for (index, isHidden) in diff.hidden {
            self[index].state = isHidden ? .hiding : .visible
        }
        for (key, to, from) in diff.move {
//            guard let from = firstIndex(where: { $0.key == key }) else { continue }
            insert(remove(at: from), at: to)
        }
        for (key, index) in diff.insert {
            insert((key, .visible), at: index)
        }
    }
    
}

