
public struct Table : TableRepresentable {
    
    public init(_ children: SectionsRepresentable?...) {
        self.children = children
    }
    
    public init(_ children: [SectionsRepresentable?]) {
        self.children = children
    }
    
    public init(build: (inout Table) -> ()) {
        build(&self)
    }
    
    public var indexTitles: [String]? {
        didSet {
            updateIndexTitles()
        }
    }
    
    public var dynamicIndexTitles = false {
        didSet {
            updateIndexTitles()
        }
    }
    
    mutating func updateIndexTitles() {
        _indexTitles = indexTitles ?? (dynamicIndexTitles ? { $0.count > 0 ? $0 : nil }(sections.flatMap { $0.indexTitle }) : nil)
    }
    
    var _indexTitles: [String]?
    
    public var children: [SectionsRepresentable?] {
        get {
            return sections
        }
        set {
            sections = newValue.flatMap { $0?.sections ?? [] }
            updateIndexTitles()
        }
    }
    
    public internal(set) var sections: [Section] = []
    
    public var table: Table {
        return self
    }
    
    subscript(section: Int) -> Section {
        return sections[section]
    }
    
    subscript(indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
}
