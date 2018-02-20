//
//  UIResponder.swift
//  Table
//
//  Created by Bradley Hilton on 2/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIResponder {
    
    var type: AnyHashable {
        get {
            return storage[\.type, default: .auto]
        }
        set {
            storage[\.type] = newValue
        }
    }
    
    var key: AnyHashable {
        get {
            return storage[\.key, default: .auto]
        }
        set {
            storage[\.key] = newValue
        }
    }
    
}
