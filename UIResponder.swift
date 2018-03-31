//
//  UIResponder.swift
//  XTable
//
//  Created by Bradley Hilton on 3/19/18.
//

extension UIResponder {
    
    var viewController: UIViewController? {
        return (self as? UIViewController) ?? next?.viewController
    }
    
}
