//
//  AnyHashable+Extensions.swift
//  Table
//
//  Created by Bradley Hilton on 1/24/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

struct Auto : Hashable {
    let hashValue = 0
    static func ==(lhs: Auto, rhs: Auto) -> Bool { return true }
}

extension AnyHashable {
    static let auto: AnyHashable = Auto()
}
