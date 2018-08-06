//
//  Cell.swift
//  Table
//
//  Created by Bradley Hilton on 3/15/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

public struct Cell {
    
    let file: String
    let function: String
    let line: Int
    let column: Int
    let cellClass: UITableViewCell.Type
    var reuseIdentifier: String {
        return "\(cellClass):\(file):\(function):\(line):\(column)"
    }
    let willDisplay: (UITableViewCell) -> ()
    let didEndDisplaying: (UITableViewCell) -> ()
    let update: (UITableViewCell) -> ()
    
    public init<Cell : UITableViewCell>(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        class: Cell.Type = Cell.self,
        willDisplay: @escaping (Cell) -> () = { _ in },
        didEndDisplaying: @escaping (Cell) -> () = { _ in },
        update: @escaping (Cell) -> () = { _ in }
    ) {
        self.file = file
        self.function = function
        self.line = line
        self.column = column
        self.cellClass = `class`
        self.willDisplay = { ($0 as? Cell).map(willDisplay) }
        self.didEndDisplaying = { ($0 as? Cell).map(didEndDisplaying) }
        self.update = { ($0 as? Cell).map(update) }
    }
    
    func cell(for indexPath: IndexPath, in tableView: UITableView, with key: AnyHashable) -> UITableViewCell {
        registerCellIfNeeded(for: tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.key = key
        UIView.performWithoutAnimation { update(cell) }
        return cell
    }
    
    func registerCellIfNeeded(for tableView: UITableView) {
        if !tableView.reuseIdentifiers.contains(reuseIdentifier) {
            let nibName = String(describing: cellClass)
            if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
                tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
            } else {
                tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
            }
            tableView.reuseIdentifiers.insert(reuseIdentifier)
        }
    }
    
}


