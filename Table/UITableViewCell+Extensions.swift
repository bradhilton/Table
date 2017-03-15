
import UIKit

extension UITableViewCell : RowsRepresentable {
    
    public var rows: [Row] {
        return [Row { row in
            row.identifier = "<\(type(of: self)): \(hashValue)>"
            row.cell = self
        }]
    }
    
}

extension UITableViewCell : CellProtocol {
    
    public var reloadKey: String {
        return "<\(type(of: self)): 0x\(String(hashValue, radix: 16))>"
    }
    
    public func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        return self
    }
    
}


