//
//  Flex.swift
//  Table
//
//  Created by Bradley Hilton on 2/14/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

public struct Flex {
    
    public var key: AnyHashable = .auto
    public var direction: YGFlexDirection?
    public var layoutDirection: YGDirection?
    public var wrap: YGWrap?
    public var alignItems: YGAlign?
    public var alignSelf: YGAlign?
    public var alignContent: YGAlign?
    public var justifyContent: YGJustify?
    public var flex: Float?
    public var flexGrow: Float?
    public var flexShrink: Float?
    public var flexBasis: FlexValue?
    public var positionType: YGPositionType?
    public var position: FlexEdges = FlexEdges()
    public var margins: FlexEdges = FlexEdges()
    public var padding: FlexEdges = FlexEdges()
    public var width: FlexValue?
    public var minWidth: FlexValue?
    public var maxWidth: FlexValue?
    public var height: FlexValue?
    public var minHeight: FlexValue?
    public var maxHeight: FlexValue?
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
        wrap.map { YGNodeStyleSetFlexWrap(node, $0) }
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
        positionType.map { positionType in
            YGNodeStyleSetPositionType(node, positionType)
        }
        position.updateNode(
            node,
            setEdge: YGNodeStyleSetPosition,
            setEdgePercent: YGNodeStyleSetPositionPercent
        )
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
            width.updateNode(node, setValue: YGNodeStyleSetWidth, setValuePercent: YGNodeStyleSetWidthPercent)
        }
        minWidth.map { minWidth in
            minWidth.updateNode(node, setValue: YGNodeStyleSetMinWidth, setValuePercent: YGNodeStyleSetMinWidthPercent)
        }
        maxWidth.map { maxWidth in
            maxWidth.updateNode(node, setValue: YGNodeStyleSetMaxWidth, setValuePercent: YGNodeStyleSetMaxWidthPercent)
        }
        height.map { height in
            height.updateNode(node, setValue: YGNodeStyleSetHeight, setValuePercent: YGNodeStyleSetHeightPercent)
        }
        minHeight.map { minHeight in
            minHeight.updateNode(node, setValue: YGNodeStyleSetMinHeight, setValuePercent: YGNodeStyleSetMinHeightPercent)
        }
        maxHeight.map { maxHeight in
            maxHeight.updateNode(node, setValue: YGNodeStyleSetMaxHeight, setValuePercent: YGNodeStyleSetMaxHeightPercent)
        }
        aspectRatio.map { YGNodeStyleSetAspectRatio(node, $0) }
        return (
            node,
            [view.map { view -> FlexState.View in
                let uiview = view.view(from: &pool, with: key)
                if children.isEmpty {
                    let context = UnsafeMutablePointer<UIView>.allocate(capacity: 1)
                    context.initialize(to: uiview)
                    YGNodeSetContext(node, context)
                    YGNodeSetMeasureFunc(node) { node, width, widthMode, height, heightMode in
                        let view = YGNodeGetContext(node)!.assumingMemoryBound(to: UIView.self).pointee
                        let constrainedSize = CGSize(
                            width: widthMode == .undefined ? .greatestFiniteMagnitude : CGFloat(width),
                            height: heightMode == .undefined ? .greatestFiniteMagnitude : CGFloat(height)
                        )
                        let size = view.sizeThatFits(constrainedSize)
                        return YGSize(width: Float(size.width), height: Float(size.height))
                    }
//                    YGNodeSetBaselineFunc(node) { node, width, height in
//                        let view = YGNodeGetContext(node)!.assumingMemoryBound(to: UIView.self).pointee
//                        let frame = CGRect(origin: .zero, size: CGSize(width: CGFloat(width), height: CGFloat(height)))
//                        let alignmentRect = view.alignmentRect(forFrame: frame)
//                        return Float(alignmentRect.size.height)
//                    }
                    return FlexState.View(view: uiview, node: node, context: context)
                } else {
                    return FlexState.View(view: uiview, node: node)
                }
            }].compactMap { $0 } + children.enumerated().flatMap { (index, child) -> [FlexState.View] in
                let (childNode, views) = child.nodeAndViews(with: &pool)
                YGNodeInsertChild(node, childNode, UInt32(index))
                return views
            }
        )
    }
    
}
