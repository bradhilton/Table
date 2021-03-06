//
//  FlexValue.swift
//  Table
//
//  Created by Bradley Hilton on 2/19/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

public struct FlexValue {
    let value: Float
    let isPercentage: Bool
    
    func updateNode(
        _ node: YGNodeRef,
        setValue: (YGNodeRef, Float) -> (),
        setValuePercent: (YGNodeRef, Float) -> ()
    ) {
        if isPercentage {
            setValuePercent(node, value)
        } else {
            setValue(node, value)
        }
    }
}

extension FlexValue {
    
    public init(_ value: Int) {
        self = FlexValue(value: Float(value), isPercentage: false)
    }
    
    public init(_ value: Float) {
        self = FlexValue(value: value, isPercentage: false)
    }
    
    public init(_ value: CGFloat) {
        self = FlexValue(value: Float(value), isPercentage: false)
    }
    
}

extension FlexValue : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    
    public init(integerLiteral value: Int) {
        self = FlexValue(value)
    }
    
    public init(floatLiteral value: Float) {
        self = FlexValue(value)
    }
    
}

postfix operator %

public postfix func % (value: Float) -> FlexValue {
    return FlexValue(value: value, isPercentage: true)
}

