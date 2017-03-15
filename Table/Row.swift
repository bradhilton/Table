
public struct Row : RowsRepresentable {
    
    public var cell: CellProtocol = Cell(reuseIdentifier: "Table.Row.emptyReuseIdentifier")
    public var identifier = ""
    internal var reload = false
    public var height: CGFloat?
    public var estimatedHeight: CGFloat?
    public var didHighlight: (() -> ())?
    public var didUnhighlight: (() -> ())?
    public var didSelect: (() -> ())?
    public var didDeselect: (() -> ())?
    public var didTap: (() -> ())?
    public var indentation = 0
    public var deleteConfirmationButtonTitle = "Delete"
    public var commitDelete: (() -> ())?
    public var commitInsert: (() -> ())?
    private var _section = Section()
    public var section: Section {
        get {
            var section = _section
            section.rows = [self]
            return section
        }
        set {
            _section = newValue
        }
    }
    
    /// WARNING: Advanced usage only.
    /// `commitMove` will be called when attempting to move the row.
    /// You must update the table by moving this row to any location of your choice.
    /// Do not update any other part of the table or the table's integrity will be compromised.
    public var commitMove: ((_ section: String, _ row: Int) -> ())?
    
    public init(build: (_ row: inout Row) -> () = { _ in }) {
        build(&self)
    }
    
    public var rows: [Row] {
        return [self]
    }
    
    public var sections: [Section] {
        return [section]
    }
    
    var shouldSelect: Bool {
        return didSelect != nil || didDeselect != nil || didTap != nil
    }
    
    var shouldHighlight: Bool {
        return shouldSelect || didHighlight != nil || didUnhighlight != nil
    }
    
    var canEdit: Bool {
        return commitDelete != nil || commitInsert != nil || commitMove != nil
    }
    
    var editingStyle: UITableViewCellEditingStyle {
        switch (commitDelete, commitInsert, commitMove) {
        case (_?, _, _): return .delete
        case (_, _?, _): return .insert
        default: return .none
        }
    }
    
}
