
public protocol TableRepresentable {
    var table: Table { get }
}

public protocol SectionsRepresentable : TableRepresentable {
    var sections: [Section] { get }
}

extension SectionsRepresentable {
    
    public var table: Table {
        return Table(self)
    }
    
}

public protocol RowsRepresentable : SectionsRepresentable {
    var rows: [Row] { get }
}

extension RowsRepresentable {
    
    public var sections: [Section] {
        return [Section(self)]
    }
    
}
