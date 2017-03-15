
extension IndexSet {
    
    fileprivate init(_ indices: [Int]) {
        var set = IndexSet()
        for index in indices {
            set.insert(index)
        }
        self = set
    }
    
}
