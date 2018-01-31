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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"
        let viewControllers = [
            ScheduleController(),
            TodoListController(),
            AccountViewController(),
            FormViewController()
        ]
        tableView.sections = [
            Section { (section: inout Section) in
                section.rows = viewControllers.map { controller in
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

