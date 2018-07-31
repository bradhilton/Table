//
//  UIButton.swift
//  Table
//
//  Created by Bradley Hilton on 7/18/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIButton {
    
    public var presentedActionSheetWhenTapped: ActionSheet? {
        get {
            return storage[\.presentedActionSheetWhenTapped]
        }
        set {
            storage[\.presentedActionSheetWhenTapped] = newValue
            addTarget(self, action: #selector(presentActionSheet), for: .touchUpInside)
        }
    }
    
    @objc private func presentActionSheet() {
        guard let viewController = viewController, let actionSheet = presentedActionSheetWhenTapped else { return }
        let alertController = UIAlertController(title: actionSheet.title, message: actionSheet.message, preferredStyle: .actionSheet)
        alertController.actions = actionSheet.actions
        alertController.popoverPresentationController?.sourceView = superview
        alertController.popoverPresentationController?.sourceRect = frame
        viewController.present(alertController, animated: true)
    }
    
    
}
