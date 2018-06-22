//
//  ConstraintsViewController.swift
//  Example
//
//  Created by Bradley Hilton on 6/2/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import UIKit
import Table

func Square(color: UIColor, alpha: CGFloat = 1) -> View {
    return View { view in
        view.backgroundColor = color
        view.alpha = alpha
    }
}

class MyField : UITextField {
    
    override var bounds: CGRect {
        willSet {
            
        }
    }
    
}

class ConstraintsViewController : UIViewController {
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        title = "Constraints"
    }
    
    var index = 0
    
    let states = [
        [
            Subview(
                constraints: [
                    .centerX == superview.centerX,
                    .centerY == superview.centerY
                ],
                view: View { (label: UILabel) in
                    label.text = "Hello, world"
                    label.alpha = 0.5
                }
            )
        ],
        []
    ]
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            self.view.subviews = self.states[self.index]
        }
    }
    
    @objc func nextButtonTapped() {
        if index + 1 < states.endIndex {
            index += 1
        } else {
            index = 0
        }
        UIView.animate(
            withDuration: 1,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.view.subviews = self.states[self.index]
            }
        )
    }
    
}
