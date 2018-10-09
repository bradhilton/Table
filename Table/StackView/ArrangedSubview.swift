//
//  ArrangedSubview.swift
//  Table
//
//  Created by Bradley Hilton on 10/4/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public struct ArrangedSubview {
    let key: AnyHashable
    let constraints: [Constraint]
    let spacingAfterView: CGFloat
    let view: View
    
    public init(
        key: AnyHashable = .auto,
        constraints: [Constraint] = [],
        spacingAfterView: CGFloat = .defaultSpacing,
        view: View
    ) {
        self.key = key
        self.constraints = constraints
        self.spacingAfterView = spacingAfterView
        self.view = view
    }
    
}

extension CGFloat {
    
    public static var defaultSpacing: CGFloat {
        if #available(iOS 11.0, *) {
            return UIStackView.spacingUseDefault
        } else {
            return 0
        }
    }
    
    public static var systemSpacing: CGFloat {
        if #available(iOS 11.0, *) {
            return UIStackView.spacingUseSystem
        } else {
            return 8
        }
    }
    
}
