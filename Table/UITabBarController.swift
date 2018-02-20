//
//  UITabBarController.swift
//  Table
//
//  Created by Bradley Hilton on 2/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UITabBarController {
    
    public var controllers: [Controller] {
        get {
            return storage[\.controllers, default: []]
        }
        set {
            setViewControllers(newValue.viewControllers(using: viewControllers ?? []), animated: viewIsVisible)
            storage[\.controllers] = newValue
        }
    }
    
}
