//
//  UIControl.swift
//  Table
//
//  Created by Bradley Hilton on 2/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

fileprivate class EventTarget<Control : NSObjectProtocol> : NSObject {
    
    var handler: (Control) -> ()
    
    init(_ handler: @escaping (Control) -> ()) {
        self.handler = handler
    }
    
    @objc func action(control: UIControl) {
        guard let control = control as? Control else { return }
        handler(control)
    }
    
}

public struct Events<Control : UIControl> {
    
    private weak var control: Control?
    
    fileprivate init(_ control: Control) {
        self.control = control
    }
    
    public subscript(events: UIControl.Event) -> ((Control) -> ())? {
        get {
            return control?.targets[events.rawValue]?.handler
        }
        set {
            control?.setHandler(newValue, for: events)
        }
    }
    
}

public protocol Control : NSObjectProtocol {}

extension Control where Self : UIControl {
    
    public var events: Events<Self> {
        get {
            return Events(self)
        }
        set {}
    }

    func setHandler(_ handler: ((Self) -> ())?, for events: UIControl.Event) {
        switch (handler, targets[events.rawValue]) {
        case let (handler?, target?):
            target.handler = handler
        case let (handler?, nil):
            let target = EventTarget(handler)
            addTarget(target, action: #selector(EventTarget<Self>.action), for: events)
            targets[events.rawValue] = target
        case let (nil, target?):
            removeTarget(target, action: #selector(EventTarget<Self>.action), for: events)
            targets.removeValue(forKey: events.rawValue)
        case (nil, nil):
            break
        }
    }
    
    fileprivate var targets: [UInt : EventTarget<Self>] {
        get {
            return storage[\.targets, default: [:]]
        }
        set {
            storage[\.targets] = newValue
        }
    }
    
}

extension UIControl : Control {}

public protocol ValueControl : class {}

extension ValueControl where Self : UIControl {
    
    public var valueChanged: ((Self) -> ())? {
        get {
            return events[.valueChanged]
        }
        set {
            events[.valueChanged] = newValue
        }
    }
    
}

#if os(iOS)
    extension UIDatePicker : ValueControl {}
    extension UISlider : ValueControl {}
    extension UIStepper : ValueControl {}
    extension UISwitch : ValueControl {}
#endif

extension UIPageControl : ValueControl {}
extension UISegmentedControl : ValueControl {}

