//
//  FlexViewController.swift
//  Example
//
//  Created by Bradley Hilton on 2/14/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import UIKit
import Table

class FlexViewController: UITableViewController {
    
    convenience init() {
        self.init(style: .grouped)
        title = "Flex"
    }
    
    var messages: [[String]] = [[], ["Hi"], ["Hello", "Bonjour"]]
    
    func flex(messages: [[String]]) -> Flex {
        return Flex { column in
            column.direction = .column
            column.children = self.messages.map { messages in
                Flex { row in
                    row.padding = 10
                    row.justifyContent = .spaceBetween
                    row.children = messages.map { message in
                        Flex { flex in
                            flex.view = View { (label: UILabel) in
                                label.text = message
                            }
                        }
                    }
                }
            }
        }
    }
    
    func render() {
        self.tableView.sections = [
            Section { (section: inout Section) in
                section.headerTitle = "Flex"
                section.rows = [
                    Row { row in
                        row.height = .automatic(estimated: 44)
                        row.cell = Cell { (cell: FlexTableViewCell) in
                            cell.child = self.flex(messages: self.messages)
                        }
                        row.didTap = {
                            for i in 0..<3 {
                                random(2) {
                                    self.messages[i].insert("Hello", at: 0)
                                }
                                random(2) {
                                    _ = self.messages[i].popLast()
                                }
                            }
                            self.render()
                        }
                    }
                ]
            }
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }

}
