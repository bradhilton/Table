//
//  FlexEdges.swift
//  Table
//
//  Created by Bradley Hilton on 2/19/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

public struct FlexEdges {
    
    var all: FlexValue?
    public var horizontal: FlexValue?
    public var vertical: FlexValue?
    public var start: FlexValue?
    public var top: FlexValue?
    public var end: FlexValue?
    public var bottom: FlexValue?
    public var left: FlexValue?
    public var right: FlexValue?
    
    public init(_ build: (inout FlexEdges) -> () = { _ in }) {
        build(&self)
    }
    
    func updateNode(
        _ node: YGNodeRef,
        setEdge: @escaping (YGNodeRef, YGEdge, Float) -> (),
        setEdgePercent: @escaping (YGNodeRef, YGEdge, Float) -> ()
    ) {
        func updateNode(with value: FlexValue?, edge: YGEdge) {
            value.map { value in
                value.updateNode(
                    node,
                    setValue: { node, value in
                        setEdge(node, edge, value)
                    }, setValuePercent: { node, percentage in
                        setEdgePercent(node, edge, percentage)
                    }
                )
            }
        }
        updateNode(with: all, edge: .all)
        updateNode(with: horizontal, edge: .horizontal)
        updateNode(with: vertical, edge: .vertical)
        updateNode(with: start, edge: .start)
        updateNode(with: top, edge: .top)
        updateNode(with: end, edge: .end)
        updateNode(with: bottom, edge: .bottom)
        updateNode(with: left, edge: .left)
        updateNode(with: right, edge: .right)
    }
    
}

extension FlexEdges : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    
    public init(integerLiteral value: Int) {
        self = FlexEdges { (edges: inout FlexEdges) in
            edges.all = FlexValue(integerLiteral: value)
        }
    }
    
    public init(floatLiteral value: Float) {
        self = FlexEdges { (edges: inout FlexEdges) in
            edges.all = FlexValue(floatLiteral: value)
        }
    }
    
}

public postfix func % (value: Float) -> FlexEdges {
    return FlexEdges { (edges: inout FlexEdges) in
        edges.all = FlexValue(value: value, isPercentage: true)
    }
}
