//
//  FlexView.swift
//  Table
//
//  Created by Bradley Hilton on 2/14/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

extension YGNodeRef {
    
    private func origin(withOffset offset: CGPoint) -> CGPoint {
        guard let parentOrigin = YGNodeGetParent(self)?.origin(withOffset: offset) else { return offset }
        return CGPoint(
            x: parentOrigin.x + CGFloat(YGNodeLayoutGetLeft(self)),
            y: parentOrigin.y + CGFloat(YGNodeLayoutGetTop(self))
        )
    }
    
    func frame(withOffset offset: CGPoint) -> CGRect {
        let origin = self.origin(withOffset: offset)
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
}

class FlexState {
    
    class View {
        let view: UIView
        let node: YGNodeRef
        let context: UnsafeMutablePointer<UIView>?
        
        init(view: UIView, node: YGNodeRef, context: UnsafeMutablePointer<UIView>? = nil) {
            self.view = view
            self.node = node
            self.context = context
        }
        
        func updateView(with superview: UIView, offset: CGPoint) {
            if view.superview == nil {
                let alpha = view.alpha
                UIView.performWithoutAnimation {
                    view.frame = node.frame(withOffset: offset)
                    view.alpha = 0
                    superview.addSubview(view)
                }
                view.alpha = alpha
                view.setNeedsLayout()
            } else {
                view.alpha = 1
                let frame = node.frame(withOffset: offset)
                if (frame != view.frame) {
                    view.frame = frame
                }
            }
        }
        
        func updateFrame(withOffset offset: CGPoint) {
            view.frame = node.frame(withOffset: offset)
        }
        
        deinit {
            context?.deinitialize(count: 1)
            context?.deallocate()
        }
        
    }
    
    private var subviewsToBeRemoved: [UIView]?
    private let node: YGNodeRef
    private let views: [View]
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        YGNodeCalculateLayout(node, Float(size.width), Float(size.height), .inherit)
        return CGSize(
            width: CGFloat(YGNodeLayoutGetWidth(self.node)),
            height: CGFloat(YGNodeLayoutGetHeight(self.node))
        )
    }
    
    init(view: FlexView) {
        var pool = view.subviews
        (node, views) = view.child.nodeAndViews(with: &pool)
        subviewsToBeRemoved = pool
    }
    
    private func calculateLayout(with view: FlexView) -> CGPoint {
        YGNodeCalculateLayout(node, Float(view.bounds.width), Float(view.bounds.height), view.direction)
        return view.bounds.origin
    }
    
    func updateViews(flexView: FlexView) {
        if let subviews = subviewsToBeRemoved.pop() {
            UIView.animate(
                withDuration: UIView.inheritedAnimationDuration,
                animations: {
                    subviews.forEach { view in
                        view.alpha = 0
                    }
                }
            )
        }
        let offset = calculateLayout(with: flexView)
        UIView.animate(withDuration: UIView.inheritedAnimationDuration) {
            for child in self.views {
                child.updateView(with: flexView, offset: offset)
            }
        }
    }
    
    func updateFrames(flexView: FlexView) {
        let offset = calculateLayout(with: flexView)
        UIView.animate(withDuration: UIView.inheritedAnimationDuration) {
            for child in self.views {
                child.updateFrame(withOffset: offset)
            }
        }
    }
    
    deinit {
        YGNodeFreeRecursive(node)
    }
    
}

extension UIView {
    
    var direction: YGDirection {
        if #available(iOS 10.0, tvOS 10.0, *) {
            switch effectiveUserInterfaceLayoutDirection {
            case .leftToRight: return .LTR
            case .rightToLeft: return .RTL
            @unknown default:
                fatalError("Unexpected interface layout direction: \(effectiveUserInterfaceLayoutDirection)")
            }
        } else {
            return .inherit
        }
    }
    
}

open class FlexView : UIView {
    
    public var child = Flex() {
        didSet {
            stateOrNil = nil
            state.updateViews(flexView: self)
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
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return state.sizeThatFits(size)
    }
    
    open override var intrinsicContentSize: CGSize {
        return state.sizeThatFits(CGSize(width: CGFloat.nan, height: .nan))
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.state.updateFrames(flexView: self)
    }
    
}
