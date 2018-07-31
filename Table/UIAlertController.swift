//
//  UIAlertController.swift
//  Table
//
//  Created by Bradley Hilton on 4/5/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIView {
    
    /// https://stackoverflow.com/a/47925120
    fileprivate func findLabel(withText text: String) -> UILabel? {
        if let label = self as? UILabel, label.text == text {
            return label
        }
        for subview in self.subviews {
            if let found = subview.findLabel(withText: text) {
                return found
            }
        }
        return nil
    }
    
}

private func deactivateBottomConstraint(between container: UIView, and label: UILabel) {
    container.constraints.first { constraint in
        let items = Set([
            constraint.firstItem as? NSObject,
            constraint.secondItem as? NSObject
        ].compactMap { $0 })
        let bottomOrBaseline: Set<NSLayoutAttribute> = [.bottom, .lastBaseline]
        return items == Set([label, container])
            && bottomOrBaseline.contains(constraint.firstAttribute)
            && bottomOrBaseline.contains(constraint.secondAttribute)
    }?.isActive = false
}

extension FlexView {
    
    fileprivate convenience init(alertController: UIAlertController) {
        self.init()
        if let message = alertController.message, let label = alertController.view.findLabel(withText: message) {
            insertBelow(label)
        } else if let title = alertController.title, let label = alertController.view.findLabel(withText: title) {
            insertBelow(label)
        } else {
            let title = "TITLE"
            alertController.title = title
            if let label = alertController.view.findLabel(withText: title) {
                insertBelow(label)
            }
        }
    }
    
    func insertBelow(_ label: UILabel) {
        guard let container = label.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        topAnchor.constraint(equalTo: label.lastBaselineAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10).isActive = true
        trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
        deactivateBottomConstraint(between: container, and: label)
    }
    
}

extension UIAlertController {
    
    public var flexView: FlexView {
        return storage[\.flexView, default: FlexView(alertController: self)]
    }
    
}

extension NSObjectProtocol where Self : UIAlertController {
    
    public var actions: [AlertAction] {
        get {
            return storage[\.actions, default: []]
        }
        set {
            storage[\.actions] = newValue
            for (offset, action) in newValue.enumerated() {
                if offset < actions.count {
                    actions[offset].isEnabled = action.isEnabled
                    actions[offset].didSelect = action.didSelect
                } else {
                    addAction(UIAlertAction(action: action))
                }
            }
        }
    }
    
    public var textFields: [(UITextField) -> ()] {
        get {
            return storage[\.textFields, default: []]
        }
        set {
            storage[\.textFields] = newValue
            for (offset, configurationHandler) in newValue.enumerated() {
                let textFields = self.textFields ?? []
                if offset < textFields.count {
                    configurationHandler(textFields[offset])
                } else {
                    addTextField(configurationHandler: configurationHandler)
                }
            }
        }
    }
    
}
