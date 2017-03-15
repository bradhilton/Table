
struct TableAnimations {
    
    let sectionDeletes: IndexSet
    let sectionInserts: IndexSet
    let sectionMoves: [(Int, Int)]
    let rowDeletes: [IndexPath]
    let rowInserts: [IndexPath]
    let rowMoves: [(IndexPath, IndexPath)]
    
    init(old: Table, new: Table) {
        var sectionAnimations = animations(
            old: old.sections.map { Animatable(identifier: $0.identifier, reload: $0.reload) },
            new: new.sections.map { Animatable(identifier: $0.identifier, reload: $0.reload) }
        )
        let oldSectionRowsLookup = Dictionary(old.sections.lazy.map { ($0.identifier, $0.rows) })
        var rowAnimations = Animations(deletes: [], inserts: [], moves: [], others: [])
        for section in new.sections {
            let animatable = Animatable(identifier: section.identifier, reload: section.reload)
            if sectionAnimations.moves.contains(animatable) {
                let oldRows = oldSectionRowsLookup[section.identifier]!
                let rows = section.rows
                if oldRows.count != rows.count || zip(oldRows, rows).first(where: { $0.identifier != $1.identifier || $1.reload }) != nil {
                    sectionAnimations.removeMove(animatable)
                }
            }
            if sectionAnimations.others.contains(animatable) {
                rowAnimations = rowAnimations.union(animations(
                    old: oldSectionRowsLookup[section.identifier]!.map { Animatable(identifier: $0.identifier, reload: $0.reload) },
                    new: section.rows.map { Animatable(identifier: $0.identifier, reload: $0.reload) }
                ))
            }
        }
        var oldSectionsLookup = [String: Int]()
        var oldSectionsReverseLookup = [String]()
        var newSectionsLookup = [String: Int]()
        var newSectionsReverseLookup = [String]()
        var oldRowsLookup = [String: IndexPath]()
        var newRowsLookup = [String: IndexPath]()
        for (s, section) in old.sections.enumerated() {
            oldSectionsLookup[section.identifier] = s
            oldSectionsReverseLookup.append(section.identifier)
            for (r, row) in section.rows.enumerated() {
                oldRowsLookup[row.identifier] = IndexPath(row: r, section: s)
            }
        }
        for (s, section) in new.sections.enumerated() {
            newSectionsLookup[section.identifier] = s
            newSectionsReverseLookup.append(section.identifier)
            for (r, row) in section.rows.enumerated() {
                newRowsLookup[row.identifier] = IndexPath(row: r, section: s)
            }
        }
        sectionMoves = sectionAnimations.moves.map { (oldSectionsLookup[$0.identifier]!, newSectionsLookup[$0.identifier]!) }
        sectionDeletes = IndexSet(sectionAnimations.deletes.map { oldSectionsLookup[$0.identifier]! })
        sectionInserts = IndexSet(sectionAnimations.inserts.map { newSectionsLookup[$0.identifier]! })
        rowMoves = rowAnimations.moves.flatMap {
            let from = oldRowsLookup[$0.identifier]!
            let to = newRowsLookup[$0.identifier]!
            guard !(from.section == to.section && oldSectionsReverseLookup[from.section] != newSectionsReverseLookup[to.section]) else {
                rowAnimations.deletes.insert($0)
                rowAnimations.inserts.insert($0)
                return nil
            }
            return (from, to)
        }
        rowDeletes = rowAnimations.deletes.map { oldRowsLookup[$0.identifier]! }
        rowInserts = rowAnimations.inserts.map { newRowsLookup[$0.identifier]! }
    }
    
}

private struct Animations {
    var deletes: Set<Animatable>
    var inserts: Set<Animatable>
    var moves: Set<Animatable>
    var others: Set<Animatable>
    
    func union(_ other: Animations) -> Animations {
        var deletes = self.deletes.union(other.deletes)
        var inserts = self.inserts.union(other.inserts)
        var moves = self.moves.union(other.moves)
        for animatable in other.inserts {
            if !animatable.reload, self.deletes.contains(animatable) {
                inserts.remove(animatable)
                deletes.remove(animatable)
                moves.insert(animatable)
            }
        }
        for animatable in self.inserts {
            if !animatable.reload, other.deletes.contains(animatable) {
                inserts.remove(animatable)
                deletes.remove(animatable)
                moves.insert(animatable)
            }
        }
        return Animations(deletes: deletes, inserts: inserts, moves: moves, others: [])
    }
    
    mutating func removeMove(_ animatable: Animatable) {
        deletes.insert(animatable)
        inserts.insert(animatable)
        moves.remove(animatable)
    }
    
}

private func animations(old: [Animatable], new: [Animatable]) -> Animations {
    let oldSet = Set(old)
    let newSet = Set(new)
    var others = oldSet.intersection(newSet)
    var deletes = oldSet.subtracting(newSet)
    var inserts = newSet.subtracting(oldSet)
    let oldCommonArrangement = old.filter { newSet.contains($0) }
    let newCommonArrangement = new.filter { oldSet.contains($0) }
    var moves = move(old: oldCommonArrangement, new: newCommonArrangement)
    for animatable in newCommonArrangement {
        if animatable.reload {
            moves.remove(animatable)
            deletes.insert(animatable)
            inserts.insert(animatable)
        }
    }
    others = others.subtracting(deletes).subtracting(inserts).subtracting(moves)
    return Animations(deletes: deletes, inserts: inserts, moves: moves, others: others)
}

private func move(old: [Animatable], new: [Animatable]) -> Set<Animatable> {
    let indexLookup: [Animatable : Int] = new.enumerated().reduce([:]) { (lookup, pair: (index: Int, animatable: Animatable)) in
        var lookup = lookup
        lookup[pair.animatable] = pair.index
        return lookup
    }
    return Set(malformedIndices(old.map { indexLookup[$0]! }).map { new[$0] })
}

private struct Animatable : Hashable {
    let identifier: String
    let reload: Bool
    var hashValue: Int {
        return identifier.hashValue
    }
    static func ==(lhs: Animatable, rhs: Animatable) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

private func malformedIndices(_ indices: [Int]) -> Set<Int> {
    var indices = indices
    var moves: Set<Int> = []
    while true {
        var maxValue = 0
        var max: (offset: Int, element: Int)?
        for (offset, element) in indices.enumerated() {
            let difference = abs(offset - element)
            if difference >= maxValue {
                maxValue = difference
                max = (offset, element)
            }
        }
        if let (offset, element) = max, maxValue != 0 {
            indices.insert(indices.remove(at: offset), at: element)
            moves.insert(element)
            maxValue = 0
            max = nil
        } else {
            return moves
        }
    }
}
