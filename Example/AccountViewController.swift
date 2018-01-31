//
//  Account.swift
//  Table
//
//  Created by Bradley Hilton on 2/25/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

import UIKit
import Table

class SwitchCell : UITableViewCell {
    
    let `switch` = UISwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(self.switch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct Account {
    let name: String
    let email: String
    let phoneNumber: String
    var babies: [Baby]
}

struct Baby {
    let name: String
    let age: Int
}

var babiesList = [
    Baby(name: "Brad", age: 8),
    Baby(name: "Lorraine", age: 6),
    Baby(name: "Evan", age: 10),
    Baby(name: "Jesse", age: 2),
    Baby(name: "Kendra", age: 14)
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
    
    @objc func addBaby() {
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
        tableView.sections = [
            Section { section in
                section.headerTitle = "Info"
                section.rows = [
                    row(text: self.account.name),
                    row(text: self.account.email),
                    row(text: self.account.phoneNumber)
                ]
            },
            Section { section in
                section.headerTitle = "Babies"
                section.rows = self.account.babies.isEmpty ? [
                    row(text: "No babies here...")
                ] : self.account.babies.map { baby in
                    return Row { row in
                        row.key = baby.name
                        row.cell = Cell { $0.textLabel?.text = "\(baby.name) - \(baby.age) months old" }
                        row.commitDelete = {
                            if let index = self.account.babies.index(where: { $0.name == baby.name }) {
                                self.account.babies.remove(at: index)
                            }
                        }
                    }
                }
            }
        ]
    }
    
    func row(text: String) -> Row {
        return Row { row in
            row.key = text
            row.cell = Cell { $0.textLabel?.text = text }
        }
    }
    
}
