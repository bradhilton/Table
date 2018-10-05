//
//  ActionSheet.swift
//  Table
//
//  Created by Bradley Hilton on 3/23/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct AlertAction {
    public let title: String
    public let style: UIAlertAction.Style
    public let image: UIImage?
    public let didSelect: (() -> ())?
    
    public init(
        title: String,
        style: UIAlertAction.Style = .default,
        image: UIImage? = nil,
        didSelect: (() -> ())? = nil
    ) {
        self.title = title
        self.style = style
        self.image = image
        self.didSelect = didSelect
    }
    
    public var isEnabled: Bool {
        return style == .cancel || didSelect != nil
    }
    
}

extension UIAlertAction {
    
    convenience init(action: AlertAction) {
        self.init(title: action.title, style: action.style) { action in action.didSelect?() }
        setValue(action.image, forKey: "image")
        didSelect = action.didSelect
        isEnabled = action.isEnabled
    }
    
    var didSelect: (() -> ())? {
        get {
            return storage[\.didSelect]
        }
        set {
            storage[\.didSelect] = newValue
        }
    }
    
}

public struct ActionSheet {
    public let title: String?
    public let message: String?
    public let actions: [AlertAction]
    public init(title: String? = nil, message: String? = nil, actions: [AlertAction] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}
