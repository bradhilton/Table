//
//  ProfileViewController.swift
//  Example
//
//  Created by Bradley Hilton on 2/19/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import UIKit
import Table

class ProfileViewController : UITableViewController {
    
    convenience init() {
        self.init(style: .grouped)
        title = "Profile"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    func render() {
        tableView.sections = [
            Section { section in
                section.headerTitle = "ACCOUNT"
                section.rows = [
                    Row { row in
                        row.cell = Cell { (cell: FlexTableViewCell) in
                            cell.child = Flex { flex in
                                flex.direction = .row
                                flex.children = [
                                    Flex { $0.width = 16 },
                                    Flex { flex in
                                        flex.view = View { (label: UILabel) in
                                            label.font = UIFont.systemFont(ofSize: 18)
                                            label.text = "Brad "
                                        }
                                    },
                                    Flex { flex in
                                        flex.view = View { (label: UILabel) in
                                            label.font = UIFont.boldSystemFont(ofSize: 18)
                                            label.text = "Hilton"
                                        }
                                    }
                                ]
                            }
                        }
                    },
                    Row { row in
                        row.height = .automatic(estimated: 44)
                        row.cell = Cell { (cell: FlexTableViewCell) in
                            cell.child = Flex { flex in
                                flex.direction = .row
                                flex.justifyContent = .spaceBetween
                                flex.padding.start = 16
                                flex.padding.end = 16
                                flex.height = 44...
                                flex.children = [
                                    Flex { flex in
                                        flex.width = 90
                                        flex.view = View { (label: UILabel) in
                                            label.numberOfLines = 0
                                            label.contentMode = .top
                                            label.text = "A\nB\nC\nD"
                                        }
                                    },
                                    Flex { flex in
                                        flex.alignSelf = .center
                                        flex.view = View { (toggle: UISwitch) in
                                            toggle.isOn = true
                                            toggle.events[.valueChanged] = { toggle in
                                                print("toggle.isOn: \(toggle.isOn)")
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    },
                    Row { row in
                        row.cell = Cell { (cell: FlexTableViewCell) in
                            cell.child = Flex { flex in
                                flex.direction = .row
                                flex.children = [
                                    Flex { (flex: inout Flex) in
                                        flex.flexGrow = 1
                                        flex.view = View { (field: UITextField) in
                                            field.text = "Hello"
                                            field.events[.editingChanged] = { field in
                                                print(field.text as Any)
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    }
                ]
                section.footerTitle = "Hello there"
            }
        ]
    }
    
//    @objc func injected() {
//        self.render()
//    }
    
}
