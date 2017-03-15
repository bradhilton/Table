//
//  Account.swift
//  Table
//
//  Created by Bradley Hilton on 2/25/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

import UIKit
import Table

struct Account {
    let name: String
    let email: String
    let phoneNumber: String
    var babies: [Baby]
    struct Baby {
        let name: String
        let age: Int
    }
}

var babiesList: [Account.Baby] = [
    .init(name: "Brad", age: 8),
    .init(name: "Lorraine", age: 6),
    .init(name: "Evan", age: 10),
    .init(name: "Jesse", age: 2),
    .init(name: "Kendra", age: 14)
]

class AccountViewController : UITableViewController {
    
    init() {
        super.init(style: .grouped)
        title = "Account"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        tableView.estimatedRowHeight = 44
        isEditing = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBaby))
        render()
    }
    
    func addBaby() {
        if let baby = babiesList.popLast() {
            account.babies.append(baby)
        }
    }
    
    var account: Account = Account(name: "John", email: "john@gmail.com", phoneNumber: "801-203-8744", babies: []) {
        didSet {
            render()
        }
    }
    
    func render() {
        tableView.table = Table(
            Section { section in
                section.headerTitle = "Info"
                section.children = [
                    row(text: self.account.name),
                    row(text: self.account.email),
                    row(text: self.account.phoneNumber)
                ]
            },
            Section { section in
                section.headerTitle = "Babies"
                guard self.account.babies.count > 0 else {
                    return section.children = [
                        row(text: "No babies here...")
                    ]
                }
                section.children = self.account.babies.map { baby in
                    return Row { row in
                        row.identifier = baby.name
                        row.cell = Cell { $0.textLabel?.text = "\(baby.name) - \(baby.age) months old" }
                        row.commitDelete = {
                            if let index = self.account.babies.index(where: { $0.name == baby.name }) {
                                self.account.babies.remove(at: index)
                            }
                        }
                    }
                }
            }
        )
    }
    
    func row(text: String) -> Row {
        return Row { row in
            row.identifier = text
            row.cell = Cell { $0.textLabel?.text = text }
        }
    }
    
}
