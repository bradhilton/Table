//
//  SectionsDelta.swift
//  Table
//
//  Created by Bradley Hilton on 1/31/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

struct SectionsDelta {
    
    let sectionDeletes: IndexSet
    let sectionInserts: IndexSet
    let sectionMoves: [(Int, Int)]
    let rowDeletes: [IndexPath]
    let rowInserts: [IndexPath]
    let rowMoves: [(IndexPath, IndexPath)]
    
    var isEmpty: Bool {
        return sectionDeletes.isEmpty
            && sectionInserts.isEmpty
            && sectionMoves.isEmpty
            && rowDeletes.isEmpty
            && rowInserts.isEmpty
            && rowMoves.isEmpty
    }
    
    init(from: [Section], to: [Section]) {
        var sectionDeletes = IndexSet()
        var sectionInserts = IndexSet()
        var sectionMoves = [(Int, Int)]()
        sectionMoves.reserveCapacity(from.count / 2)
        var rowDeletes = [AnyHashable: IndexPath]()
        var rowInserts = [AnyHashable: IndexPath]()
        var rowMoves = [(IndexPath, IndexPath)]()
        var lookup = [AnyHashable: (index: Int, section: Section)](minimumCapacity: from.count)
        for (index, section) in zip(from.indices, from) {
            lookup[section.key] = (index, section)
        }
        for to in zip(to.indices, to).map({ (index: $0, section: $1)}) {
            if let from = lookup.removeValue(forKey: to.section.key) {
                if (to.section.headerTitle == nil) != (from.section.headerTitle == nil) || (to.section.footerTitle == nil) != (from.section.footerTitle == nil) {
                    sectionDeletes.insert(from.index)
                    sectionInserts.insert(to.index)
                } else {
                    let rowsDelta = RowsDelta(from: from.section.rows, to: to.section.rows)
                    switch (rowsDelta.noChanges, to.section.sortKey == from.section.sortKey) {
                    case (true, true): break
                    case (true, false):
                        sectionMoves.append((from.index, to.index))
                    case (false, true):
                        for (key, deletePath) in rowsDelta.deletes.map({ key, row in (key, IndexPath(row: row, section: from.index)) }) {
                            if let insertionPath = rowInserts.removeValue(forKey: key) {
                                rowMoves.append((deletePath, insertionPath))
                            } else {
                                rowDeletes[key] = deletePath
                            }
                        }
                        for (key, insertionPath) in rowsDelta.inserts.map({ key, row in (key, IndexPath(row: row, section: to.index)) }) {
                            if let deletePath = rowDeletes.removeValue(forKey: key) {
                                rowMoves.append((deletePath, insertionPath))
                            } else {
                                rowInserts[key] = insertionPath
                            }
                        }
                        rowMoves.append(contentsOf: rowsDelta.moves.map { (IndexPath(row: $0, section: from.index), IndexPath(row: $1, section: to.index))})
                    case (false, false):
                        sectionDeletes.insert(from.index)
                        sectionInserts.insert(to.index)
                    }
                }
            } else {
                sectionInserts.insert(to.index)
            }
        }
        for from in lookup.values {
            sectionDeletes.insert(from.index)
        }
        self.sectionInserts = sectionInserts
        self.sectionDeletes = sectionDeletes
        self.sectionMoves = sectionMoves
        self.rowInserts = Array(rowInserts.values)
        self.rowDeletes = Array(rowDeletes.values)
        self.rowMoves = rowMoves
    }
    
}

struct RowsDelta {
    
    var deletes: [AnyHashable: Int]
    var inserts: [AnyHashable: Int]
    var moves: [(Int, Int)]
    
    var noChanges: Bool {
        return inserts.count == 0 && deletes.count == 0 && moves.count == 0
    }
    
    init(from: [Row], to: [Row]) {
        deletes = [AnyHashable: Int](minimumCapacity: from.count / 2)
        inserts = [AnyHashable: Int](minimumCapacity: to.count / 2)
        moves = [(Int, Int)]()
        moves.reserveCapacity(from.count / 2)
        var lookup = [AnyHashable: (sortKey: AnyHashable, index: Int)](minimumCapacity: from.count)
        for (row, index) in zip(from, from.indices) {
            lookup[row.key] = (sortKey: row.sortKey, index: index)
        }
        for to in zip(to, to.indices).map({ (key: $0.key, sortKey: $0.sortKey, index: $1) }) {
            if let from = lookup.removeValue(forKey: to.key) {
                if to.sortKey != from.sortKey {
                    moves.append((from.index, to.index))
                }
            } else {
                inserts[to.key] = to.index
            }
        }
        for (key, from) in lookup {
            deletes[key] = from.index
        }
    }
    
}
