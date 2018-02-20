
extension UITableView {
    
    public var sections: [Section] {
        get {
            return source?.data.sections ?? []
        }
        set {
            let data = Data(sections: newValue)
            if let source = source {
                source.setData(data, tableView: self, animated: true)
            } else {
                self.source = Source(tableView: self, data: data)
            }
        }
    }
    
    var source: Source? {
        get {
            return storage[\.source]
        }
        set {
            storage[\.source] = newValue
        }
    }
    
    var reuseIdentifiers: Set<String> {
        get {
            return storage[\.reuseIdentifiers, default: []]
        }
        set {
            storage[\.reuseIdentifiers] = newValue
        }
    }
    
}

