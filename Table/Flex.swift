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
    public var direction: YGFlexDirection?
    public var layoutDirection: YGDirection?
    public var alignItems: YGAlign?
    public var alignSelf: YGAlign?
    public var alignContent: YGAlign?
    public var justifyContent: YGJustify?
    public var flex: Float?
    public var flexGrow: Float?
    public var flexShrink: Float?
    public var flexBasis: FlexValue?
    public var position: FlexPosition?
    public var margins: FlexEdges = FlexEdges()
    public var padding: FlexEdges = FlexEdges()
    public var width: FlexDimension?
    public var height: FlexDimension?
    public var aspectRatio: Float?
    public var view: View?
    public var children: [Flex] = []
    
    public init(_ build: (inout Flex) -> () = { _ in }) {
        build(&self)
    }
    
    func nodeAndViews(with pool: inout [UIView]) -> (YGNodeRef, [FlexState.View]) {
        let node = YGNodeNew()!
        direction.map { YGNodeStyleSetFlexDirection(node, $0) }
        layoutDirection.map { YGNodeStyleSetDirection(node, $0) }
        alignItems.map { YGNodeStyleSetAlignItems(node, $0) }
        alignSelf.map { YGNodeStyleSetAlignSelf(node, $0) }
        alignContent.map { YGNodeStyleSetAlignContent(node, $0) }
        justifyContent.map { YGNodeStyleSetJustifyContent(node, $0) }
        flex.map { YGNodeStyleSetFlex(node, $0) }
        flexGrow.map { YGNodeStyleSetFlexGrow(node, $0) }
        flexShrink.map { YGNodeStyleSetFlexShrink(node, $0) }
        flexBasis.map { flexBasis in
            flexBasis.updateNode(
                node,
                setValue: YGNodeStyleSetFlexBasis,
                setValuePercent: YGNodeStyleSetFlexBasisPercent
            )
        }
        position.map { position in
            position.updateNode(node)
        }
        margins.updateNode(
            node,
            setEdge: YGNodeStyleSetMargin,
            setEdgePercent: YGNodeStyleSetMarginPercent
        )
        padding.updateNode(
            node,
            setEdge: YGNodeStyleSetPadding,
            setEdgePercent: YGNodeStyleSetPaddingPercent
        )
        width.map { width in
            width.updateNode(
                node,
                setValue: YGNodeStyleSetWidth,
                setValuePercent: YGNodeStyleSetWidthPercent,
                setMin: YGNodeStyleSetMinWidth,
                setMinPercent: YGNodeStyleSetMinWidthPercent,
                setMax: YGNodeStyleSetMaxWidth,
                setMaxPercent: YGNodeStyleSetMaxWidthPercent
            )
        }
        height.map { height in
            height.updateNode(
                node,
                setValue: YGNodeStyleSetHeight,
                setValuePercent: YGNodeStyleSetHeightPercent,
                setMin: YGNodeStyleSetMinHeight,
                setMinPercent: YGNodeStyleSetMinHeightPercent,
                setMax: YGNodeStyleSetMaxHeight,
                setMaxPercent: YGNodeStyleSetMaxHeightPercent
            )
        }
        aspectRatio.map { YGNodeStyleSetAspectRatio(node, $0) }
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
