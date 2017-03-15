//
//  Cell.swift
//  Table
//
//  Created by Bradley Hilton on 3/15/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

public protocol CellProtocol {
    var reloadKey: String { get }
    func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
}

public protocol ModelCell {
    associatedtype Model
    static func reloadKey(for model: Model) -> String
    func configure(with model: Model)
}

extension ModelCell {
    
    public static func reloadKey(for model: Model) -> String {
        return String(describing: model)
    }
    
}

public struct Cell<Cell : UITableViewCell> : CellProtocol {
    
    public let reloadKey: String
    let reuseIdentifier: String
    let configure: (Cell) -> ()
    
    public init(reloadKey: String = "", reuseIdentifier: String? = nil, configure: @escaping (Cell) -> () = { _ in }) {
        self.reloadKey = reloadKey
        self.reuseIdentifier = reuseIdentifier ?? String(describing: Cell.self)
        self.configure = configure
    }
    
    public func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        if !tableView._registeredReuseIdentifiers.contains(reuseIdentifier) {
            let nibName = String(describing: Cell.self)
            if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
                tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
            } else {
                tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
            }
            tableView._registeredReuseIdentifiers.insert(reuseIdentifier)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? Cell {
            configure(cell)
        }
        return cell
    }
    
}

extension Cell where Cell : ModelCell {
    
    public init(model: Cell.Model) {
        self.reloadKey = Cell.reloadKey(for: model)
        self.reuseIdentifier = String(describing: Cell.self)
        self.configure = { cell in
            cell.configure(with: model)
        }
    }
    
}


