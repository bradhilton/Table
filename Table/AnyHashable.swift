//
//  AnyHashable.swift
//  Table
//
//  Created by Bradley Hilton on 1/24/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Auto : Hashable {}

public struct Pair<T : Hashable, U : Hashable> : Hashable {
    public let first: T
    public let second: U
    public init(_ first: T, _ second: U) {
        self.first = first
        self.second = second
    }
}

extension AnyHashable {
    public static let auto: AnyHashable = Auto()
}
