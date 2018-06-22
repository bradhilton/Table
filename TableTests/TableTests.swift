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
            .left == superview.left : Constraint(.left, equalTo: superview.left),
            .left == superview.left + 8 : Constraint(.left, equalTo: superview.left, constant: 8),
            .left == superview.left | .defaultHigh :  Constraint(.left, equalTo: superview.left, priority: .defaultHigh),
            .left == superview.left + 8 | .defaultHigh : Constraint(.left, equalTo: superview.left, constant: 8, priority: .defaultHigh),
            .width == superview.width : Constraint(.width, equalTo: superview.width),
            .width == superview.width * 0.8 : Constraint(.width, equalTo: superview.width, multiplier: 0.8),
            .width == superview.width * 0.8 + 8 : Constraint(.width, equalTo: superview.width, multiplier: 0.8, constant: 8),
            .width == superview.width * 0.8 + 8 | .defaultHigh :
                Constraint(.width, equalTo: superview.width, multiplier: 0.8, constant: 8, priority: .defaultHigh),
            .width == .width : Constraint(.width, equalTo: .width),
            .width == .width * 0.8 : Constraint(.width, equalTo: .width, multiplier: 0.8),
            .width == .width * 0.8 + 8 : Constraint(.width, equalTo: .width, multiplier: 0.8, constant: 8),
            .width == .width * 0.8 + 8 | .defaultHigh :
                Constraint(.width, equalTo: .width, multiplier: 0.8, constant: 8, priority: .defaultHigh),
            .width == 8 : Constraint(.width, equalTo: 8),
            .width == 8 | .defaultHigh : Constraint(.width, equalTo: 8, priority: .defaultHigh)
        ]
        for (lhs, rhs) in constraints {
            XCTAssertEqual(lhs, rhs)
        }
        for (lhs, rhs) in zip(constraints.map({ $0.key }), constraints.dropFirst().map({ $0.value })) {
            XCTAssertNotEqual(lhs, rhs)
        }

    }
    
}
