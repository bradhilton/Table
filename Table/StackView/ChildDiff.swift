//
//  ChildDiff.swift
//  Table
//
//  Created by Bradley Hilton on 10/4/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

enum ChildState {
    case visible
    case hiding
    case hidden
}

/*
 First set hidden flag for children at indices
 Then insert new children at indices
 Then remove children at incorrect indices
 Finally re-insert children at correct indices
*/
struct ChildDiff {
    internal private(set) var hidden: [(Int, Bool)] = []
    internal private(set) var move: [(key: AnyHashable, to: Int, from: Int)] = []
    internal private(set) var insert: [(key: AnyHashable, at: Int)] = []
    
    init(newChildren: [AnyHashable], oldChildren: [(key: AnyHashable, state: ChildState)]) {
        
        // Make a mutable copy of the old children
        var oldChildren = oldChildren
        oldChildren.reserveCapacity(newChildren.count)
        
        // Set hidden flag for children inserted or removed from the set
        let newChildrenSet = Set(newChildren)
        for (index, oldChild) in oldChildren.enumerated() {
            if oldChild.state != .visible && newChildrenSet.contains(oldChild.key) {
                hidden.append((index, false))
            } else if oldChild.state == .visible && !newChildrenSet.contains(oldChild.key) {
                hidden.append((index, true))
            }
        }
        
        var newIndexLookup = Dictionary(
            uniqueKeysWithValues: newChildren.enumerated().lazy.map { ($1, $0) }
        )
        
        var previousIndex = 0
        for child in oldChildren {
            if let newIndex = newIndexLookup[child.key] {
                previousIndex = newIndex
            } else {
                newIndexLookup[child.key] = previousIndex
            }
        }
        
        let newIndices = oldChildren.map(state: 0) { previousIndex, child in
            
        }
        
        func lessThan(_ lhs: (key: AnyHashable, ChildState), _ rhs: (key: AnyHashable, ChildState)) -> Bool {
            return newIndexLookup[lhs.key]! < newIndexLookup[rhs.key]!
        }
        
        for (index, child) in oldChildren.enumerated() {
            var insertionIndex = index
            var aMove: (key: AnyHashable, to: Int, from: Int)?
            while insertionIndex > 0 && lessThan(oldChildren[insertionIndex], oldChildren[insertionIndex - 1]) {
                aMove = (child.key, insertionIndex - 1, index)
                oldChildren.swapAt(insertionIndex - 1, insertionIndex)
                insertionIndex -= 1
            }
            if let aMove = aMove {
                move.append(aMove)
            }
        }
        
        // Insert children not found in current children while adjusting indices of existing children
        let indexLookup = Dictionary(
            uniqueKeysWithValues: oldChildren.enumerated().lazy.map { ($1.key, $0) }
        )
        var insertionIndex = 0
        for child in newChildren {
            if let index = indexLookup[child] {
                insertionIndex = index + insert.count + 1
            } else {
                oldChildren.insert((key: child, state: .visible), at: insertionIndex)
                insert.append((key: child, at: insertionIndex))
                insertionIndex += 1
            }
        }
        
    }
    
}

