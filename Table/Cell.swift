//
//  Cell.swift
//  Table
//
//  Created by Bradley Hilton on 3/15/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

public struct Cell {
    
    let reuseIdentifier: String
    let cellClass: UITableViewCell.Type
    let configure: (UITableViewCell) -> ()
    
    public init<Cell : UITableViewCell>(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        class: Cell.Type = Cell.self,
        configure: @escaping (Cell) -> () = { _ in }
    ) {
        self.reuseIdentifier = "\(Cell.self):\(file):\(function):\(line):\(column)"
        self.cellClass = `class`
        self.configure = { cell in
            guard let cell = cell as? Cell else { return }
            configure(cell)
        }
    }
    
    func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        registerCellIfNeeded(for: tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        UIView.performWithoutAnimation { configure(cell) }
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


