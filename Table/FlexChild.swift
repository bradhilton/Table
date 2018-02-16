//
//  FlexNode.swift
//  Table
//
//  Created by Bradley Hilton on 2/14/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Flex {
    
    public init(build: (inout Flex) -> ()) {
        build(&self)
    }
    
}
