//
//  AnyHashable+Extensions.swift
//  Table
//
//  Created by Bradley Hilton on 1/24/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Auto : Hashable {
    public let hashValue = 0
    public static func ==(lhs: Auto, rhs: Auto) -> Bool { return true }
}

extension AnyHashable {
    public static let auto: AnyHashable = Auto()
}
