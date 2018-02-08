

public struct Row {
    
    public enum Height : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
        case constant(CGFloat)
        case automatic(estimated: CGFloat)
        
        public init(integerLiteral value: Int) {
            self = .constant(CGFloat(value))
        }
        
        public init(floatLiteral value: Double) {
            self = .constant(CGFloat(value))
        }
        
    }
    
    public var cell = Cell()
    public var key = AnyHashable.auto
    public var sortKey = AnyHashable.auto
    public var height: Height = .constant(44)
    public var didHighlight: (() -> ())?
    public var didUnhighlight: (() -> ())?
    public var didSelect: (() -> ())?
    public var didDeselect: (() -> ())?
    public var didTap: (() -> ())?
    public var indentation = 0
    public var deleteConfirmationButtonTitle = "Delete"
    public var commitDelete: (() -> ())?
    public var commitInsert: (() -> ())?
    
    /// WARNING: Advanced usage only.
    /// `commitMove` will be called when attempting to move the row.
    /// You must update the table by moving this row to any location of your choice.
    /// Do not update any other part of the table or the table's integrity will be compromised.
    public var commitMove: ((_ section: AnyHashable, _ row: Int) -> ())?
    
    public init(build: (_ row: inout Row) -> () = { _ in }) {
        build(&self)
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
