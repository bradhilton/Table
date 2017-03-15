//
//  TodoListController.swift
//  Table
//
//  Created by Bradley Hilton on 1/24/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

import Table
import UIKit

var idCounter: Int = 0
var nextId: Int {
    defer { idCounter += 1 }
    return idCounter
}

struct Todo : Equatable {
    let id = nextId
    var description = ""
    static func ==(lhs: Todo, rhs: Todo) -> Bool {
        return lhs.id == rhs.id
    }
}

class TextFieldCell : UITableViewCell {
    
    let textField = UITextField()
    var editingDidEnd: (String) -> () = { _ in }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        textField.addTarget(self, action: #selector(editingDidEnd(textField:)), for: .editingDidEnd)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func editingDidEnd(textField: UITextField) {
        editingDidEnd(textField.text ?? "")
    }
    
}

class TodoListController : UITableViewController {
    
    init() {
        super.init(style: .plain)
        title = "Todos"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var todos: [Todo] = [] {
        didSet {
            render()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        tableView.estimatedRowHeight = 44
        tableView.allowsSelectionDuringEditing = true
        navigationItem.rightBarButtonItem = editButtonItem
        todos = []
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        render()
    }
    
    func render() {
        tableView.table = Table(
            Section { section in
                section.identifier = "todos"
                section.children = todos.map { todo in
                    Row { row in
                        row.identifier = "\(todo.id)"
                        let reloadKey = "\(todo.description, isEditing)"
                        if isEditing {
                            row.cell = Cell(reloadKey: reloadKey) { (cell: TextFieldCell) in
                                cell.textField.text = todo.description
                                cell.textField.placeholder = "Describe Todo Here..."
                                cell.editingDidEnd = { [unowned self] text in
                                    if let index = self.todos.index(of: todo) {
                                        self.todos[index].description = text
                                    }
                                }
                            }
                        } else {
                            row.cell = Cell(reloadKey: reloadKey) { cell in
                                cell.textLabel?.text = todo.description
                            }
                        }
                        row.commitDelete = { [unowned self] in
                            self.todos.remove(at: self.todos.index(of: todo)!)
                        }
                        row.commitMove = { [unowned self, section = section] (sectionIdentifier, index) in
                            guard sectionIdentifier == section.identifier else { return }
                            self.todos.remove(at: self.todos.index(of: todo)!)
                            self.todos.insert(todo, at: index)
                        }
                    }
                }
            },
            isEditing ? Row { row in
                row.cell = Cell { cell in
                    cell.textLabel?.text = "Add Todo"
                }
                row.didTap = { [unowned self] in
                    self.todos.append(Todo())
                }
                row.commitInsert = row.didTap
            } : nil
        )
    }
    
}
