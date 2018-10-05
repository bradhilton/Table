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
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak window] notification in
            guard
                let window = window,
                let userInfo = notification.userInfo,
                let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int)
                    .flatMap(UIView.AnimationCurve.init)
                else { return }
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [UIView.AnimationOptions(animationCurve: animationCurve)],
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

extension UIView.AnimationOptions {
    
    fileprivate init(animationCurve: UIView.AnimationCurve) {
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

