//
//  ViewController.swift
//  Example
//
//  Created by Bradley Hilton on 11/22/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

import UIKit
import Table

class ViewController: UITableViewController {
    
    let viewControllers = [
        ScheduleController(),
        TodoListController(),
        AccountViewController(),
        FormViewController(),
        FlexViewController(),
        PresentingViewController(),
        ProfileViewController()
    ]
    
    convenience init() {
        self.init(style: .plain)
        title = "Menu"
        render()
    }
    
    func render() {
        view = View { (tableView: UITableView) in
            tableView.sections = [
                Section { (section: inout Section) in
                    section.rows = self.viewControllers.map { controller in
                        Row { row in
                            row.cell = Cell { cell in
                                cell.textLabel?.text = controller.title
                                cell.accessoryType = .disclosureIndicator
                            }
                            row.didSelect = { [unowned self] in
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    }
                }
            ]
        }
    }
    
    @objc func injected() {
        render()
    }
    
}

