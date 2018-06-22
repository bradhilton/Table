//
//  Keys.swift
//  Table
//
//  Created by Bradley Hilton on 3/31/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

struct TypeAndKey : Hashable {
    let type: AnyHashable
    let key: AnyHashable
}

extension NSObject {
    
    var type: AnyHashable? {
        get {
            return storage[\.type]
        }
        set {
            storage[\.type] = newValue
        }
    }
    
    var key: AnyHashable? {
        get {
            return storage[\.key]
        }
        set {
            storage[\.key] = newValue
        }
    }
    
    var typeAndKey: TypeAndKey? {
        guard let type = type, let key = key else { return nil }
        return TypeAndKey(type: type, key: key)
    }
    
}
