//
//  Flex.swift
//  Table
//
//  Created by Bradley Hilton on 2/14/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

var flexTypeKey = "flexType"
var flexKeyKey = "flexKey"

extension UIView {
    
    var flexType: AnyHashable {
        get {
            return (objc_getAssociatedObject(self, &flexTypeKey) as? AnyHashable) ?? .auto
        }
        set {
            objc_setAssociatedObject(self, &flexTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var flexKey: AnyHashable {
        get {
            return (objc_getAssociatedObject(self, &flexKeyKey) as? AnyHashable) ?? .auto
        }
        set {
            objc_setAssociatedObject(self, &flexKeyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

public struct Flex {
    
    public var key: AnyHashable = .auto
    public var direction: YGFlexDirection = .row
    public var alignItems: YGAlign = .stretch
    public var alignSelf: YGAlign? = nil
    public var alignContent: YGAlign = .flexStart
    public var justifyContent: YGJustify = .flexStart
    public var width: Float = .nan
    public var padding: Float = .nan
    public var view: View?
    public var children: [Flex] = []
    
    public init(build: (inout Flex) -> ()) {
        build(&self)
    }
    
    func nodeAndViews(with pool: inout [UIView]) -> (YGNodeRef, [FlexState.View]) {
        let node = YGNodeNew()!
        YGNodeStyleSetFlexDirection(node, direction)
        YGNodeStyleSetAlignItems(node, alignItems)
        alignSelf.map { YGNodeStyleSetAlignSelf(node, $0) }
        YGNodeStyleSetAlignContent(node, alignContent)
        YGNodeStyleSetJustifyContent(node, justifyContent)
        YGNodeStyleSetWidth(node, width)
        YGNodeStyleSetPadding(node, .all, padding)
        return (
            node,
            [view.map { view -> FlexState.View in
                let uiview = view.view(from: &pool, with: key)
                if children.isEmpty {
                    view.configure(uiview)
                    let context = UnsafeMutablePointer<UIView>.allocate(capacity: 1)
                    context.initialize(to: uiview)
                    YGNodeSetContext(node, context)
                    YGNodeSetMeasureFunc(node) { node, width, widthMode, height, heightMode in
                        let view = YGNodeGetContext(node)!.assumingMemoryBound(to: UIView.self).pointee
                        let size = view.intrinsicContentSize
                        return YGSize(width: Float(size.width), height: Float(size.height))
                    }
                    return FlexState.View(view: uiview, node: node, context: context)
                } else {
                    return FlexState.View(view: uiview, node: node, update: view.configure)
                }
            }].flatMap { $0 } + children.enumerated().flatMap { (index, child) -> [FlexState.View] in
                let (childNode, views) = child.nodeAndViews(with: &pool)
                YGNodeInsertChild(node, childNode, UInt32(index))
                return views
            }
        )
    }
    
//    func updateChildKeys(parent: AnyHashable) {
//        var index = 0
//        for child in children {
//            if child.key == .auto {
//                child.key = FlexKey(parent: parent, index: index)
//                index += 1
//            }
//            child.updateChildKeys(parent: key)
//        }
//    }
    
}


public struct View {
    
    let type: AnyHashable
    let factory: () -> UIView
    let configure: (UIView) -> ()
    
    public init<View : UIView>(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        class: View.Type = View.self,
        configure: @escaping (View) -> () = { _ in }
    ) {
        self.type = "\(View.self):\(file):\(function):\(line):\(column)"
        self.factory = { View() }
        self.configure = { view in
            guard let view = view as? View else { return }
            configure(view)
        }
    }
    
    func view(from pool: inout [UIView], with key: AnyHashable) -> UIView {
        if let index = pool.index(where: { view in view.flexType == type && view.flexKey == key }) {
            let view = pool.remove(at: index)
            return view
        } else {
            let view = factory()
            view.flexType = type
            view.flexKey = key
            return view
        }
    }
    
}
