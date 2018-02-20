//
//  Storage.swift
//  Table
//
//  Created by Bradley Hilton on 2/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

class TypedStorage<Owner : AnyObject> {
    
    private var storage: [PartialKeyPath<Owner>: Any] = [:]

    fileprivate init() {}
    
    subscript<Property>(key: KeyPath<Owner, Property>) -> Property? {
        get {
            return storage[key] as? Property
        }
        set {
            storage[key] = newValue
        }
    }
    
    subscript<Property>(key: KeyPath<Owner, Property?>) -> Property? {
        get {
            return storage[key] as? Property
        }
        set {
            storage[key] = newValue
        }
    }
    
    subscript<Property>(key: KeyPath<Owner, Property>, default default: Property) -> Property {
        get {
            return storage[key] as? Property ?? `default`
        }
        set {
            storage[key] = newValue
        }
    }
    
}

private var storageKey = "storageKey"

extension NSObjectProtocol {
    
    var storage: TypedStorage<Self> {
        guard let storage = objc_getAssociatedObject(self, &storageKey) as? TypedStorage<Self> else {
            let storage = TypedStorage<Self>()
            objc_setAssociatedObject(self, &storageKey, storage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return storage
        }
        return storage
    }
    
}
