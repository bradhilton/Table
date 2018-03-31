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
        
        func updateView(with superview: UIView, offset: CGPoint) {
            if view.superview == nil {
                let alpha = view.alpha
                UIView.performWithoutAnimation {
                    view.frame = node.frame(withOffset: offset)
                    view.alpha = 0
                    superview.addSubview(view)
                }
                view.alpha = alpha
            } else {
                view.alpha = 1
                view.frame = node.frame(withOffset: offset)
            }
            update.pop()?(view)
            view.setNeedsLayout()
        }
        
        func updateFrame(withOffset offset: CGPoint) {
            view.frame = node.frame(withOffset: offset)
        }
        
        deinit {
            (context?.pointee as? UITextField)?.text = ""
            context?.deinitialize()
            context?.deallocate(capacity: 1)
        }
        
    }
    
    private var subviewsToBeRemoved: [UIView]?
    private let node: YGNodeRef
    private let views: [View]
    lazy var intrinsicContentSize: CGSize = {
        YGNodeCalculateLayout(self.node, .nan, .nan, .inherit)
        return CGSize(
            width: CGFloat(YGNodeLayoutGetWidth(self.node)),
            height: CGFloat(YGNodeLayoutGetHeight(self.node))
        )
    }()
    
    init(view: FlexView) {
        var pool = view.subviews
        (node, views) = view.child.nodeAndViews(with: &pool)
        subviewsToBeRemoved = pool
    }
    
    private func calculateLayout(with flexView: FlexView) -> CGPoint {
        let frame: CGRect
        if #available(iOS 11.0, *) {
            frame = UIEdgeInsetsInsetRect(flexView.frame, flexView.safeAreaInsets)
        } else {
            frame = flexView.frame
        }
        YGNodeCalculateLayout(node, Float(frame.width), Float(frame.height), flexView.direction)
        return frame.origin
    }
    
    func updateViews(flexView: FlexView) {
        if let subviews = subviewsToBeRemoved.pop() {
            UIView.animate(
                withDuration: UIView.inheritedAnimationDuration,
                animations: {
                    subviews.forEach { view in
                        view.alpha = 0
                    }
                },
                completion: nil
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

open class FlexView : UIView {
    
    public var child = Flex() {
        didSet {
            stateOrNil = nil
            invalidateIntrinsicContentSize()
            if self.window != nil {
                UIView.animate(withDuration: 0.25) {
                    self.state.updateViews(flexView: self)
                }
            } else {
                UIView.performWithoutAnimation {
                    self.state.updateViews(flexView: self)
                }
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
    
    open override var intrinsicContentSize: CGSize {
        return state.intrinsicContentSize
    }
    
    var previousSafeAreaInsets: UIEdgeInsets?
    
    @available(iOS 11.0, *)
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        self.state.updateFrames(flexView: self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.state.updateFrames(flexView: self)
    }
    
}
