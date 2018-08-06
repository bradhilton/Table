//
//  UIPopoverPresentationController.swift
//  Table
//
//  Created by Bradley Hilton on 8/4/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIPopoverPresentationController {
    
    public var sourceViewKey: AnyHashable? {
        get {
            return storage[\.sourceViewKey]
        }
        set {
            storage[\.sourceViewKey] = newValue
        }
    }
    
    public var sourceRectGetter: ((UIView) -> CGRect)? {
        get {
            return storage[\.sourceRectGetter]
        }
        set {
            storage[\.sourceRectGetter] = newValue
        }
    }
    
}
