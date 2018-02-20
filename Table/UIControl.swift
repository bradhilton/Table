//
//  UIControl.swift
//  Table
//
//  Created by Bradley Hilton on 2/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

fileprivate class Target<Control : NSObjectProtocol> : NSObject {
    
    private unowned let control: Control
    var handler: (Control) -> ()
    
    init(control: Control, handler: @escaping (Control) -> ()) {
        self.control = control
        self.handler = handler
    }
    
    @objc func action() {
        handler(control)
    }
    
}

public struct Events<Control : UIControl> {
    
    private unowned let control: Control
    private var targets: [UInt : Target<Control>] = [:]
    
    fileprivate init(_ control: Control) {
        self.control = control
    }
    
    public subscript(events: UIControlEvents) -> ((Control) -> ())? {
        get {
            return targets[events.rawValue]?.handler
        }
        set {
            switch (newValue, targets[events.rawValue]) {
            case let (handler?, target?):
                target.handler = handler
            case let (handler?, nil):
                let target = Target(control: control, handler: handler)
                control.addTarget(target, action: #selector(Target<Control>.action), for: events)
                targets[events.rawValue] = target
            case let (nil, target?):
                control.removeTarget(target, action: #selector(Target<Control>.action), for: events)
                targets.removeValue(forKey: events.rawValue)
            case (nil, nil):
                break
            }
        }
    }
    
}

public protocol ControlProtocol : NSObjectProtocol {}

extension ControlProtocol where Self : UIControl {
    
    public var events: Events<Self> {
        get {
            return storage[\.events, default: Events(self)]
        }
        set {
            storage[\.events] = newValue
        }
    }
    
}

extension UIControl : ControlProtocol {}
