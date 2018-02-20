
var sourceKey = "source"
var registeredReuseIdentifiersKey = "registeredReuseIdentifiers"

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
            return objc_getAssociatedObject(self, &sourceKey) as? Source
        }
        set {
            objc_setAssociatedObject(self, &sourceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var registeredReuseIdentifiers: Set<String> {
        get {
            if let set = objc_getAssociatedObject(self, &registeredReuseIdentifiersKey) as? Set<String> {
                return set
            }
            self.registeredReuseIdentifiers = Set<String>()
            return self.registeredReuseIdentifiers
        }
        set {
            objc_setAssociatedObject(self, &registeredReuseIdentifiersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

