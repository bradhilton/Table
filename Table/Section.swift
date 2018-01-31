
public struct Section {
    
    public var key = AnyHashable.auto
    public var sortKey = AnyHashable.auto
    public var headerTitle: String?
    public var footerTitle: String?
    public var indexTitle: String?
    public var rows: [Row] = []
    
    public init(build: (inout Section) -> ()) {
        build(&self)
    }
    
}
