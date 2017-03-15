//
//  Dictionary+Extensions.swift
//  Table
//
//  Created by Bradley Hilton on 1/20/17.
//  Copyright © 2017 Brad Hilton. All rights reserved.
//

extension Dictionary {
    
    init<C : Collection>(_ collection: C) where C.Iterator.Element == (Key, Value), C.IndexDistance == Int {
        var dictionary = Dictionary(minimumCapacity: collection.count)
        for (key, value) in collection {
            dictionary[key] = value
        }
        self = dictionary
    }
    
}
