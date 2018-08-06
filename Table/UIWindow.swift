//
//  UIWindow.swift
//  Table
//
//  Created by Bradley Hilton on 7/31/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIWindow {
    
    public var keyboardLayoutGuide: UILayoutGuide {
        return storage[\.keyboardLayoutGuide, default: KeyboardLayoutGuide(self)]
    }
    
}

private class KeyboardLayoutGuide : UILayoutGuide {
    
    init(_ window: UIWindow) {
        super.init()
        window.addLayoutGuide(self)
        leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true
        let heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillChangeFrame,
            object: nil,
            queue: .main
        ) { [weak window] notification in
            guard
                let window = window,
                let userInfo = notification.userInfo,
                let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
                let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int)
                    .flatMap(UIViewAnimationCurve.init)
                else { return }
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [UIViewAnimationOptions(animationCurve: animationCurve)],
                animations: {
                    heightConstraint.constant = window.frame.height - frame.minY
                    window.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIViewAnimationOptions {
    
    fileprivate init(animationCurve: UIViewAnimationCurve) {
        switch animationCurve {
        case .easeInOut:
            self = .curveEaseInOut
        case .easeIn:
            self = .curveEaseIn
        case .easeOut:
            self = .curveEaseOut
        case .linear:
            self = .curveLinear
        }
    }
    
}

