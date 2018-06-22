//
//  Array.swift
//  Table
//
//  Created by Bradley Hilton on 6/2/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension Array {
    
    mutating func popFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try index(where: predicate) else {
            return nil
        }
        return remove(at: index)
    }
    
}
