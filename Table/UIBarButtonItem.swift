//
//  UIBarButtonItem.swift
//  Table
//
//  Created by Bradley Hilton on 3/19/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIBarButtonItem {
    
    public var didTap: (() -> ())? {
        get {
            return storage[\.didTap]
        }
        set {
            storage[\.didTap] = newValue
            if newValue != nil {
                target = self
                action = #selector(didTapSelector)
            }
        }
    }
    
    @objc private func didTapSelector() {
        didTap?()
    }
    
    public var presentedActionSheetWhenTapped: ActionSheet? {
        get {
            return storage[\.presentedActionSheetWhenTapped]
        }
        set {
            storage[\.presentedActionSheetWhenTapped] = newValue
            if newValue != nil {
                target = self
                action = #selector(presentActionSheet)
            }
        }
    }
    
    @objc private func presentActionSheet() {
        guard let viewController = viewController, let actionSheet = presentedActionSheetWhenTapped else { return }
        let alertController = UIAlertController(title: actionSheet.title, message: actionSheet.message, preferredStyle: .actionSheet)
        actionSheet.actions.map(UIAlertAction.init).forEach(alertController.addAction)
        alertController.popoverPresentationController?.barButtonItem = self
        viewController.present(alertController, animated: true)
    }
    
    /// Weakly stored reference to a UIViewController
    public var viewController: UIViewController? {
        get {
            return weakViewController?.reference
        }
        set {
            weakViewController = newValue.map(Weak.init)
        }
    }
    
    private var weakViewController: Weak<UIViewController>? {
        get {
            return storage[\.weakViewController]
        }
        set {
            storage[\.weakViewController] = newValue
        }
    }
    
}
