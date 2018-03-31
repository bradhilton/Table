//
//  ActionSheet.swift
//  Table
//
//  Created by Bradley Hilton on 3/23/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct AlertAction {
    public let title: String
    public let style: UIAlertActionStyle
    public let image: UIImage?
    public let isEnabled: Bool
    public let didSelect: () -> ()
    public init(
        title: String,
        style: UIAlertActionStyle = .default,
        image: UIImage? = nil,
        isEnabled: Bool = true,
        didSelect: @escaping () -> () = {}
    ) {
        self.title = title
        self.style = style
        self.image = image
        self.isEnabled = isEnabled
        self.didSelect = didSelect
    }
}

extension UIAlertAction {
    
    convenience init(action: AlertAction) {
        self.init(title: action.title, style: action.style) { _ in action.didSelect() }
        setValue(action.image, forKey: "image")
        isEnabled = action.isEnabled
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
