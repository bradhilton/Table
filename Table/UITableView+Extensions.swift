
var _delegateKey = "_delegate"
var _registeredReuseIdentifiersKey = "_registeredReuseIdentifiers"

extension UITableView {
    
    public var table: TableRepresentable? {
        get {
            return _delegate?.table
        }
        set {
            guard let table = newValue else {
                _delegate = nil
                return reloadData()
            }
            if let _delegate = _delegate {
                return _delegate.table = table.table
            }
            _delegate = Delegate(tableView: self, table: table.table)
        }
    }
    
    public var sections: [SectionsRepresentable?]? {
        get {
            return nil
        }
        set {
            table = newValue.map { Table($0) }
        }
    }
    
    public var rows: [RowsRepresentable?]? {
        get {
            return nil
        }
        set {
            table = newValue.map { Section($0) }
        }
    }
    
    var _delegate: Delegate? {
        get {
            return objc_getAssociatedObject(self, &_delegateKey) as? Delegate
        }
        set {
            objc_setAssociatedObject(self, &_delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var _registeredReuseIdentifiers: Set<String> {
        get {
            if let set = objc_getAssociatedObject(self, &_registeredReuseIdentifiersKey) as? Set<String> {
                return set
            }
            self._registeredReuseIdentifiers = Set<String>()
            return self._registeredReuseIdentifiers
        }
        set {
            objc_setAssociatedObject(self, &_registeredReuseIdentifiersKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

