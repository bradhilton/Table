//
//  UITableViewCell.swift
//  Table
//
//  Created by Bradley Hilton on 5/21/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UITableViewCell {
    
    var didEndDisplaying: (UITableViewCell) -> () {
        get {
            return storage[\.didEndDisplaying, default: { _ in }]
        }
        set {
            storage[\.didEndDisplaying] = newValue
        }
    }
    
}
