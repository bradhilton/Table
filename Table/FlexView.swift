//
//  FlexView.swift
//  Table
//
//  Created by Bradley Hilton on 2/14/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

extension YGNodeRef {
    
    var origin: CGPoint {
        guard let parent = YGNodeGetParent(self) else { return CGPoint() }
        return CGPoint(
            x: parent.origin.x + CGFloat(YGNodeLayoutGetLeft(self)),
            y: parent.origin.y + CGFloat(YGNodeLayoutGetTop(self))
        )
    }
    
    var frame: CGRect {
        return CGRect(
            x: origin.x,
            y: origin.y,
            width: CGFloat(YGNodeLayoutGetWidth(self)),
            height: CGFloat(YGNodeLayoutGetHeight(self))
        )
    }
    
}

struct FlexKey : Hashable {
    let parent: AnyHashable
    let index: Int
    
    var hashValue: Int {
        return parent.hashValue ^ index
    }
    
    static func ==(lhs: FlexKey, rhs: FlexKey) -> Bool {
        return lhs.index == rhs.index && lhs.parent == rhs.parent
    }
    
}

class FlexState {
    
    class View {
        let view: UIView
        let node: YGNodeRef
        let context: UnsafeMutablePointer<UIView>?
        var update: ((UIView) -> ())?
        
        init(view: UIView, node: YGNodeRef, context: UnsafeMutablePointer<UIView>? = nil, update: ((UIView) -> ())? = nil) {
            self.view = view
            self.node = node
            self.context = context
            self.update = update
        }
        
        func updateView(with superview: UIView) {
            if view.superview == nil {
                let alpha = view.alpha
                UIView.performWithoutAnimation {
                    view.frame = node.frame
                    view.alpha = 0
                    superview.addSubview(view)
                }
                view.alpha = alpha
            } else {
                view.frame = node.frame
            }
            if let update = self.update {
                update(view)
                self.update = nil
            }
            view.setNeedsLayout()
        }
        
        deinit {
            context?.deinitialize()
            context?.deallocate(capacity: 1)
        }
        
    }
    
    var subviewsToRemove: [UIView]?
    var previousFrame: CGRect
    let node: YGNodeRef
    let views: [View]
    lazy var intrinsicContentSize: CGSize = {
        YGNodeCalculateLayout(node, .nan, .nan, .inherit)
        return CGSize(
            width: CGFloat(YGNodeLayoutGetWidth(node)),
            height: CGFloat(YGNodeLayoutGetHeight(node))
        )
    }()
    
    init(view: FlexView) {
        var pool = view.subviews
        (self.node, self.views) = view.child.nodeAndViews(with: &pool)
        self.subviewsToRemove = pool
        self.previousFrame = view.frame
    }
    
    func update(flexView: FlexView) {
        if let views = subviewsToRemove {
            subviewsToRemove = nil
            UIView.animate(
                withDuration: UIView.inheritedAnimationDuration,
                animations: {
                    views.forEach { view in
                        view.alpha = 0
                    }
                }, completion: { _ in
                    views.forEach { view in
                        view.removeFromSuperview()
                    }
                }
            )
        }
        YGNodeCalculateLayout(node, Float(flexView.frame.width), Float(flexView.frame.height), flexView.direction)
        UIView.animate(withDuration: UIView.inheritedAnimationDuration) {
            for child in self.views {
                child.updateView(with: flexView)
            }
        }
    }
    
    deinit {
        YGNodeFreeRecursive(node)
    }
    
}

public class FlexView : UIView {
    
    public var child = Flex(build: { _ in }) {
        didSet {
            stateOrNil = nil
            invalidateIntrinsicContentSize()
            UIView.animate(withDuration: 0.25) {
                self.state.update(flexView: self)
            }
        }
    }
    
    var stateOrNil: FlexState?
    
    var state: FlexState {
        guard let state = stateOrNil else {
            let state = FlexState(view: self)
            self.stateOrNil = state
            return state
        }
        return state
    }
    
    var direction: YGDirection {
        if #available(iOS 10.0, tvOS 10.0, *) {
            switch effectiveUserInterfaceLayoutDirection {
            case .leftToRight: return .LTR
            case .rightToLeft: return .RTL
            }
        } else {
            return .inherit
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return state.intrinsicContentSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        UIView.animate(withDuration: 1) {
            self.state.update(flexView: self)
        }
    }
    
}
