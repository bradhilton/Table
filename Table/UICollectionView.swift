//
//  UICollectionView.swift
//  Table
//
//  Created by Bradley Hilton on 4/24/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import yoga

extension CGPoint {
    
    fileprivate func distance(to other: CGPoint) -> CGFloat {
        return hypot(x - other.x, y - other.y)
    }
    
}

public enum HorizontalSnapPosition {
    case left, center, right
}

public enum VerticalSnapPostion {
    case top, center, bottom
}

public typealias SnapPosition = (vertical: VerticalSnapPostion, horizontal: HorizontalSnapPosition)

extension CGRect {
    
    func point(for snapPosition: SnapPosition) -> CGPoint {
        switch snapPosition {
        case (.top, .left): return origin
        case (.top, .center): return CGPoint(x: midX, y: minY)
        case (.top, .right): return CGPoint(x: maxX, y: minY)
        case (.center, .left): return CGPoint(x: minX, y: midY)
        case (.center, .center): return CGPoint(x: midX, y: midY)
        case (.center, .right): return CGPoint(x: maxX, y: midY)
        case (.bottom, .left): return CGPoint(x: minX, y: maxY)
        case (.bottom, .center): return CGPoint(x: midX, y: maxY)
        case (.bottom, .right): return CGPoint(x: maxX, y: maxY)
        }
    }
    
}

extension UICollectionViewLayoutAttributes {
    
    func distance(to point: CGPoint, for snapPosition: SnapPosition) -> CGFloat {
        return frame.point(for: snapPosition).distance(to: point)
    }
    
}

public class FlexCollectionViewLayout : UICollectionViewLayout {
    
    private var snapPosition: SnapPosition?
    private var contentSize: CGSize = .zero
    private var attributes: [UICollectionViewLayoutAttributes] = []
    
    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let layout = collectionView.flexLayout
        let node = layout.node
        let safeBounds: CGRect
        if #available(iOS 11.0, *) {
            safeBounds = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.safeAreaInsets)
        } else {
            safeBounds = collectionView.bounds
        }
        let viewWidth = Float(safeBounds.width)
        let viewHeight = Float(safeBounds.height)
//        let viewWidth = Float(collectionView.frame.size.width)
//        let viewHeight = Float(collectionView.frame.size.height)
        YGNodeStyleSetMinWidth(node, viewWidth)
        YGNodeStyleSetMinHeight(node, viewHeight)
        YGNodeCalculateLayout(
            node,
            viewWidth,
            viewHeight,
            collectionView.direction
        )
        snapPosition = layout.snapPosition
        contentSize = CGSize(
            width: CGFloat(
                layout.items.enumerated().map { (index, item) in
                    YGNodeLayoutGetLeft(YGNodeGetChild(node, UInt32(index))!) + YGNodeLayoutGetWidth(YGNodeGetChild(node, UInt32(index))!)
                }.max() ?? viewWidth
            ),
            height: CGFloat(
                layout.items.enumerated().map { (index, item) in
                    YGNodeLayoutGetTop(YGNodeGetChild(node, UInt32(index))!) + YGNodeLayoutGetHeight(YGNodeGetChild(node, UInt32(index))!)
                }.max() ?? viewHeight
            )
        )
        attributes = layout.items.filter { $0.cell != nil }.enumerated().map { (index, item) in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attributes.frame = YGNodeGetChild(node, UInt32(index))!.frame(withOffset: .zero)
            return attributes
        }
    }
    
    override public var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { $0.frame.intersects(rect) }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView?.frame.size != newBounds.size
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, let position = snapPosition else { return proposedContentOffset }
        let offset = CGRect(origin: proposedContentOffset, size: collectionView.frame.size).point(for: position)
        let compare = { (lhs: UICollectionViewLayoutAttributes, rhs: UICollectionViewLayoutAttributes) in
            return lhs.distance(to: offset, for: position) < rhs.distance(to: offset, for: position)
        }
        guard let attribute = attributes.min(by: compare) else { return proposedContentOffset }
        guard proposedContentOffset.distance(to: collectionView.firstOffset) > attribute.distance(to: offset, for: position) else {
            return collectionView.firstOffset
        }
        guard proposedContentOffset.distance(to: collectionView.lastOffset) > attribute.distance(to: offset, for: position) else {
            return collectionView.lastOffset
        }
        return CGPoint(
            x: proposedContentOffset.x + attribute.frame.point(for: position).x - offset.x,
            y: proposedContentOffset.y + attribute.frame.point(for: position).y - offset.y
        )
    }
    
}

public struct FlexLayout {
    public var snapPosition: SnapPosition?
    public var direction: YGFlexDirection = .row
    public var wrap: YGWrap = .wrap
    public var layoutDirection: YGDirection?
    public var alignItems: YGAlign?
    public var alignContent: YGAlign?
    public var justifyContent: YGJustify?
    public var items: [FlexItem] = []
    var cells: [CollectionCell] { return items.compactMap { $0.cell } }
    
    public init(build: (inout FlexLayout) -> () = { _ in }) {
        build(&self)
    }
    
    var node: YGNodeRef {
        let node = YGNodeNew()!
        YGNodeStyleSetFlexDirection(node, direction)
        YGNodeStyleSetFlexWrap(node, wrap)
        layoutDirection.map { YGNodeStyleSetDirection(node, $0) }
        alignItems.map { YGNodeStyleSetAlignItems(node, $0) }
        alignContent.map { YGNodeStyleSetAlignContent(node, $0) }
        justifyContent.map { YGNodeStyleSetJustifyContent(node, $0) }
        for (index, item) in items.enumerated() {
            YGNodeInsertChild(node, item.node, UInt32(index))
        }
        return node
    }
    
}

public struct FlexItem {
    public var key: AnyHashable = .auto
    public var alignSelf: YGAlign?
    public var flex: Float?
    public var flexGrow: Float?
    public var flexShrink: Float?
    public var flexBasis: FlexValue?
    public var margins = FlexEdges()
    public var padding = FlexEdges()
    public var width: FlexValue?
    public var minWidth: FlexValue?
    public var maxWidth: FlexValue?
    public var height: FlexValue?
    public var minHeight: FlexValue?
    public var maxHeight: FlexValue?
    public var aspectRatio: Float?
    public var cell: CollectionCell?
    
    public init(build: (inout FlexItem) -> ()) {
        build(&self)
    }
    
    var node: YGNodeRef {
        let node = YGNodeNew()!
        alignSelf.map { YGNodeStyleSetAlignSelf(node, $0) }
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
        return node
    }
    
}


private class FlexCollectionDelegate : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.flexLayout.cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.flexLayout.cells[indexPath.row].cell(for: indexPath, in: collectionView)
    }
    
}

private class Delegate : NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate private(set) var items = [Item]() {
        didSet {
            hasCustomItemSizes = items.first { $0.size != nil } != nil
        }
    }
    
    private var hasCustomItemSizes = false
    
    func setItems(_ items: [Item], with collectionView: UICollectionView) {
        guard UIView.inheritedAnimationDuration > 0 else {
            self.items = items
            return collectionView.reloadData()
        }
        let delta = ItemsDelta(from: self.items, to: items)
        let indexPaths = collectionView.indexPathsForVisibleItems
        let newItems: [AnyHashable: Item] = Dictionary(uniqueKeysWithValues: items.map { ($0.key, $0) })
        let itemReloads: [IndexPath] = indexPaths
            .map { indexPath in
                (indexPath, self.items[indexPath.row])
            }.compactMap { indexPath, item in
                newItems[item.key].map { (indexPath, item, $0) }
            }.compactMap { indexPath, oldItem, newItem in
                if (oldItem.cell.reuseIdentifier == newItem.cell.reuseIdentifier) {
                    collectionView.cellForItem(at: indexPath).map { newItem.cell.update($0) }
                    return nil
                } else {
                    self.items[indexPath.row] = newItem
                    return indexPath
                }
            }
        collectionView.reloadItems(at: itemReloads)
        self.items = items
        guard !delta.noChanges else { return }
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: delta.deletes.map { IndexPath(item: $0, section: 0) })
            collectionView.insertItems(at: delta.inserts.map { IndexPath(item: $0, section: 0) })
            delta.moves.forEach { collectionView.moveItem(at: IndexPath(item: $0.0, section: 0), to: IndexPath(item: $0.1, section: 0)) }
        })
    }
    
    init(_ collectionView: UICollectionView) {
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return items[indexPath.row].cell.cell(for: indexPath, in: collectionView)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        let implementedMethods = [
            #selector(collectionView(_:numberOfItemsInSection:)),
            #selector(collectionView(_:cellForItemAt:))
        ]
        if implementedMethods.contains(aSelector) {
            return true
        } else if aSelector == #selector(collectionView(_:layout:sizeForItemAt:)), hasCustomItemSizes {
            return true
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return items[indexPath.row].size ?? collectionView.flowLayout.itemSize
    }
    
}

private let swizzleFlowLayoutMethods: () -> () = {
    method_exchangeImplementations(
        class_getInstanceMethod(
            UICollectionViewFlowLayout.self,
            #selector(UICollectionViewFlowLayout.swizzledTargetContentOffset)
        )!,
        class_getInstanceMethod(
            UICollectionViewFlowLayout.self,
            #selector(UICollectionViewFlowLayout.targetContentOffset(forProposedContentOffset:withScrollingVelocity:))
        )!
    )
    return {}
}()

extension UICollectionViewFlowLayout {
    
    public var snapPosition: SnapPosition? {
        get {
            return storage[\.snapPosition]
        }
        set {
            storage[\.snapPosition] = newValue
            swizzleFlowLayoutMethods()
        }
    }
    
    @objc
    func swizzledTargetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, let position = snapPosition else {
            return proposedContentOffset
        }
        let offset = CGRect(origin: proposedContentOffset, size: collectionView.frame.size).point(for: position)
        let compare = { (lhs: UICollectionViewLayoutAttributes, rhs: UICollectionViewLayoutAttributes) in
            return lhs.distance(to: offset, for: position) < rhs.distance(to: offset, for: position)
        }
        guard let attributes = layoutAttributesForElements(in: CGRect(origin: proposedContentOffset, size: collectionView.contentSize)) else {
            return proposedContentOffset
        }
        guard let attribute = attributes.min(by: compare) else { return proposedContentOffset }
        guard proposedContentOffset.distance(to: collectionView.firstOffset) > attribute.distance(to: offset, for: position) else {
            return collectionView.firstOffset
        }
        guard proposedContentOffset.distance(to: collectionView.lastOffset) > attribute.distance(to: offset, for: position) else {
            return collectionView.lastOffset
        }
        return CGPoint(
            x: proposedContentOffset.x + attribute.frame.point(for: position).x - offset.x,
            y: proposedContentOffset.y + attribute.frame.point(for: position).y - offset.y
        )
    }
    
    
}

extension UICollectionView {
    
    public var flexLayout: FlexLayout {
        get {
            return storage[\.flexLayout, default: FlexLayout()]
        }
        set {
            storage[\.flexLayout] = newValue
            delegate = flexCollectionDelegate
            dataSource = flexCollectionDelegate
            reloadData()
        }
    }
    
    public var items: [Item] {
        get {
            return defaultDelegate.items
        }
        set {
            defaultDelegate.setItems(newValue, with: self)
        }
    }
    
    public var flowLayout: UICollectionViewFlowLayout {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout
        } else {
            let flowLayout = UICollectionViewFlowLayout()
            collectionViewLayout = flowLayout
            return flowLayout
        }
    }
    
    private var defaultDelegate: Delegate {
        return storage[\.defaultDelegate, default: Delegate(self)]
    }
    
    fileprivate var hasCustomItemSizes: Bool {
        get {
            return storage[\.hasCustomItemSizes, default: false]
        }
        set {
            storage[\.hasCustomItemSizes] = newValue
        }
    }
    
    fileprivate var flexCollectionDelegate: FlexCollectionDelegate {
        return storage[\.flexCollectionDelegate, default: FlexCollectionDelegate()]
    }
    
    fileprivate var flexCollectionViewLayout: FlexCollectionViewLayout {
        return storage[\.flexCollectionViewLayout, default: FlexCollectionViewLayout()]
    }
    
    var reuseIdentifiers: Set<String> {
        get {
            return storage[\.reuseIdentifiers, default: []]
        }
        set {
            storage[\.reuseIdentifiers] = newValue
        }
    }
    
    fileprivate var possiblyAdjustedContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return adjustedContentInset
        } else {
            return contentInset
        }
    }
    
    fileprivate var firstOffset: CGPoint {
        return CGPoint(x: -possiblyAdjustedContentInset.left, y: -possiblyAdjustedContentInset.top)
    }
    
    fileprivate var lastOffset: CGPoint {
        return CGPoint(
            x: contentSize.width - frame.width + possiblyAdjustedContentInset.right,
            y: contentSize.height - frame.height + possiblyAdjustedContentInset.bottom
        )
    }
    
}
