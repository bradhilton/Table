//
//  Item.swift
//  Table
//
//  Created by Bradley Hilton on 6/18/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct Item {
    public var key: AnyHashable = .auto
    public var sortKey: AnyHashable = .auto
    public var size: CGSize?
    public var cell = CollectionCell()
    public init(_ build: (inout Item) -> ()) {
        build(&self)
    }
}
