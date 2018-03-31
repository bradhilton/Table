//
//  Storage.swift
//  Table
//
//  Created by Bradley Hilton on 2/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

fileprivate class UntypedStorage {
    fileprivate var storage: [AnyKeyPath: Any] = [:]
}

public struct TypedStorage<Owner : AnyObject> {
    
    private let untyped: UntypedStorage
    
    fileprivate init(_ untyped: UntypedStorage) {
        self.untyped = untyped
    }
    
    public subscript<Property>(key: KeyPath<Owner, Property>) -> Property? {
        get {
            return untyped.storage[key] as? Property
        }
        nonmutating set {
            untyped.storage[key] = newValue
        }
    }
    
    public subscript<Property>(key: KeyPath<Owner, Property?>) -> Property? {
        get {
            return untyped.storage[key] as? Property
        }
        nonmutating set {
            untyped.storage[key] = newValue
        }
    }
    
    public subscript<Property>(key: KeyPath<Owner, Property>, default defaultValue: @autoclosure () -> Property) -> Property {
        guard let property = untyped.storage[key] as? Property else {
            let property = defaultValue()
            untyped.storage[key] = property
            return property
        }
        return property
    }
    
}

private var storageKey = "storageKey"

extension NSObjectProtocol {
    
    public var storage: TypedStorage<Self> {
        guard let storage = objc_getAssociatedObject(self, &storageKey) as? UntypedStorage else {
            let storage = UntypedStorage()
            objc_setAssociatedObject(self, &storageKey, storage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return TypedStorage(storage)
        }
        return TypedStorage(storage)
    }
    
}
