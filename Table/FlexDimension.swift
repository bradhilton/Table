//
//  FlexDimension.swift
//  Table
//
//  Created by Bradley Hilton on 2/19/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

public struct FlexDimension {
    let value: FlexValue?
    let min: FlexValue?
    let max: FlexValue?
    
    func updateNode(
        _ node: YGNodeRef,
        setValue: (YGNodeRef, Float) -> (),
        setValuePercent: (YGNodeRef, Float) -> (),
        setMin: (YGNodeRef, Float) -> (),
        setMinPercent: (YGNodeRef, Float) -> (),
        setMax: (YGNodeRef, Float) -> (),
        setMaxPercent: (YGNodeRef, Float) -> ()
    ) {
        value.map { value in
            value.updateNode(node, setValue: setValue, setValuePercent: setValuePercent)
        }
        min.map { min in
            min.updateNode(node, setValue: setMin, setValuePercent: setMinPercent)
        }
        max.map { max in
            max.updateNode(node, setValue: setMax, setValuePercent: setMaxPercent)
        }
    }
    
}

extension FlexDimension : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    
    public init(integerLiteral value: Int) {
        self = FlexDimension(value: FlexValue(integerLiteral: value), min: nil, max: nil)
    }
    
    public init(floatLiteral value: Float) {
        self = FlexDimension(value: FlexValue(floatLiteral: value), min: nil, max: nil)
    }
    
}

public func ... (lhs: FlexValue, rhs: FlexValue) -> FlexDimension {
    return FlexDimension(value: nil, min: lhs, max: rhs)
}

public prefix func ... (max: FlexValue) -> FlexDimension {
    return FlexDimension(value: nil, min: nil, max: max)
}

public postfix func ... (min: FlexValue) -> FlexDimension {
    return FlexDimension(value: nil, min: min, max: nil)
}

public postfix func % (value: Float) -> FlexDimension {
    return FlexDimension(value: FlexValue(value: value, isPercentage: true), min: nil, max: nil)
}
