
extension MutableCollection {
    
    mutating func mutatingEach(_ body: (inout Self.Iterator.Element) throws -> Void) rethrows {
        var index = startIndex
        while index != endIndex {
            try body(&self[index])
            index = self.index(after: index)
        }
    }
    
}

