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
        ProfileViewController(),
        ConstraintsViewController()
    ]
    
    convenience init() {
        self.init(style: .plain)
        title = "Menu"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    func render() {
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
    
    @objc func injected() {
        render()
    }
    
}

extension ViewController : UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        return viewControllers[indexPath.row]
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(UIViewController(), animated: true)
    }
    
}

