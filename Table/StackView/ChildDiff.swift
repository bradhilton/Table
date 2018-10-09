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

protocol ChildAndStateProtocol {
    associatedtype Child : Hashable
    var child: Child { get }
    var state: ChildState { get set }
    init(child: Child, state: ChildState)
}

struct ChildAndState<Child : Hashable> : ChildAndStateProtocol {
    let child: Child
    var state: ChildState
}

extension UIView {
    
    var childState: ChildState {
        return isVisible
            ? isHidden || alpha == 0
            ? .hiding
            : .visible
            : .hidden
    }
    
}

/*
 First remove listed children
 Then insert new children
 Finally move existing children
 */
struct ChildDiff<Child : Hashable> {
    let removeChildren: [Child]
    let insertNewChildren: [(child: Child, at: Int)]
    let moveVisibleChildren: [(child: Child, at: Int)]
    
    func map<T : Hashable>(_ transform: (Child) -> T) -> ChildDiff<T> {
        return ChildDiff<T>(
            removeChildren: removeChildren.map(transform),
            insertNewChildren: insertNewChildren.map { (child: transform($0.child), at: $0.at) },
            moveVisibleChildren: moveVisibleChildren.map { (child: transform($0.child), at: $0.at) }
        )
    }
    
}

extension ChildDiff {
    
    init(newChildren: [Child], oldChildren: [ChildAndState<Child>]) {
        var oldChildren = oldChildren
        
        let newChildrenSet = Set(newChildren)
        let newRanks = Dictionary(uniqueKeysWithValues: zip(newChildren, newChildren.indices))
        
        removeChildren = oldChildren.removeToBeInsertedElements(newChildrenSet)
        insertNewChildren = oldChildren.insert(newChildren)
        moveVisibleChildren = oldChildren.sort(with: newRanks)
    }
    
}

extension Array where Element : ChildAndStateProtocol {
    
    fileprivate mutating func removeToBeInsertedElements(_ newChildren: Set<Element.Child>) -> [Element.Child] {
        return enumerated().reversed().compactMap { (index, element) in
            if newChildren.contains(element.child) && element.state == .hidden {
                remove(at: index)
                return element.child
            } else {
                return nil
            }
        }
    }
    
    /// Inserts new children and returns a list of insertions
    fileprivate mutating func insert(_ newChildren: [Element.Child]) -> [(child: Element.Child, at: Int)] {
        let indices = Dictionary(uniqueKeysWithValues: enumerated().lazy.map { ($1.child, $0) })
        var insertions: [(child: Element.Child, at: Int)] = []
        var insertionIndex = 0
        for child in newChildren {
            if let index = indices[child] {
                insertionIndex = index + insertions.count + 1
            } else {
                insert(Element(child: child, state: .visible), at: insertionIndex)
                insertions.append((child: child, at: insertionIndex))
                insertionIndex += 1
            }
        }
        return insertions
    }
    
    /// Sorts an array of children and returns a list of insertions
    fileprivate mutating func sort(
        with newRanks: [Element.Child: Int]
        ) -> [(child: Element.Child, at: Int)] {
        var insertions: [(child: Element.Child, at: Int)] = []
        for (index, element) in enumerated() {
            guard let rank = newRanks[element.child] else { continue }
            var insertionIndex = index - 1
            var insertion: (child: Element.Child, at: Int)?
            var previousRank: Int?
            while insertionIndex >= 0 {
                previousRank = newRanks[self[insertionIndex].child]
                if let previousRank = previousRank {
                    if rank < previousRank {
                        insertion = (element.child, insertionIndex)
                    } else {
                        break
                    }
                }
                insertionIndex -= 1
            }
            if let insertion = insertion {
                remove(at: index)
                insert(Element(child: insertion.child, state: .visible), at: insertion.at)
                insertions.append(insertion)
            }
        }
        return insertions
    }
    
}
