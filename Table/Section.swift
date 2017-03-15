
public struct Section : RowsRepresentable {
    
    public init(_ children: RowsRepresentable?...) {
        self.children = children
    }
    
    public init(_ children: [RowsRepresentable?]) {
        self.children = children
    }
    
    public init(build: (inout Section) -> ()) {
        build(&self)
    }
    
    public var identifier = ""
    var reload = false
    public var headerTitle: String?
    public var footerTitle: String?
    public var indexTitle: String?
    
    public var children: [RowsRepresentable?] {
        get {
            return rows
        }
        set {
            self.rows = newValue.flatMap { $0?.rows ?? [] }
        }
    }
    
    public internal(set) var rows: [Row] = []
    
    public var sections: [Section] {
        return [self]
    }
    
}
