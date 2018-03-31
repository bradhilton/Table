//
//  Weak.swift
//  Table
//
//  Created by Bradley Hilton on 3/23/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

struct Weak<T : AnyObject> {
    weak var reference: T?
}
