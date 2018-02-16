//
//  PresentingViewController.swift
//  Example
//
//  Created by Bradley Hilton on 2/16/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import UIKit
import Table

class PresentingViewController : UITableViewController {
    
    convenience init() {
        self.init(style: .grouped)
        self.title = "Presentation"
        self.presentedController = Controller { (controller: UINavigationController) in
            controller.controllers = [
                Controller { controller in
                    controller.view = View { view in
                        view.backgroundColor = .blue
                    }
                },
                Controller { controller in
                    controller.view = View { view in
                        view.backgroundColor = .white
                    }
                }
            ]
        }
    }
    
}
