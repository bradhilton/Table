//
//  ItemsDelta.swift
//  Table
//
//  Created by Bradley Hilton on 6/18/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

struct ItemsDelta {
    var deletes: [Int]
    var inserts: [Int]
    var moves: [(Int, Int)]
    
    var noChanges: Bool {
        return inserts.count == 0 && deletes.count == 0 && moves.count == 0
    }
    
    init(from: [Item], to: [Item]) {
        deletes = [Int]()
        deletes.reserveCapacity(from.count / 2)
        inserts = [Int]()
        inserts.reserveCapacity(to.count / 2)
        moves = [(Int, Int)]()
        moves.reserveCapacity(from.count / 2)
        var lookup = [AnyHashable: (sortKey: AnyHashable, index: Int)](minimumCapacity: from.count)
        for (item, index) in zip(from, from.indices) {
            lookup[item.key] = (sortKey: item.sortKey, index: index)
        }
        for to in zip(to, to.indices).map({ (key: $0.key, sortKey: $0.sortKey, index: $1) }) {
            if let from = lookup.removeValue(forKey: to.key) {
                if to.sortKey != from.sortKey {
                    moves.append((from.index, to.index))
                }
            } else {
                inserts.append(to.index)
            }
        }
        for (_, index) in lookup.values {
            deletes.append(index)
        }
    }
    
}
