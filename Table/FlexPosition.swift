//
//  FlexPosition.swift
//  Table
//
//  Created by Bradley Hilton on 2/19/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

public struct FlexPosition {
    private let edges: FlexEdges
    private let isAbsolute: Bool
    
    public static func absolute(edges: FlexEdges) -> FlexPosition {
        return FlexPosition(edges: edges, isAbsolute: true)
    }
    
    public static func absolute(_ build: (inout FlexEdges) -> ()) -> FlexPosition {
        return FlexPosition(edges: FlexEdges(build), isAbsolute: true)
    }
    
    public static func relative(edges: FlexEdges) -> FlexPosition {
        return FlexPosition(edges: edges, isAbsolute: false)
    }
    
    public static func relative(_ build: (inout FlexEdges) -> ()) -> FlexPosition {
        return FlexPosition(edges: FlexEdges(build), isAbsolute: false)
    }
    
    func updateNode(_ node: YGNodeRef) {
        YGNodeStyleSetPositionType(node, isAbsolute ? .absolute : .relative)
        edges.updateNode(
            node,
            setEdge: YGNodeStyleSetPosition,
            setEdgePercent: YGNodeStyleSetPositionPercent
        )
    }
}
