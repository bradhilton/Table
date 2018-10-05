//
//  Sequence.swift
//  Table
//
//  Created by Bradley Hilton on 10/5/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension Sequence {
    
    func map<S, U>(state: S, transform: (_ state: inout S, _ element: Element) throws -> U) rethrows -> [U] {
        var state = state
        return try map { try transform(&state, $0) }
    }
    
}
