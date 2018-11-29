//
//  Constraints.swift
//  Table
//
//  Created by Bradley Hilton on 6/14/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import UIKit


public protocol Axis {
    var layoutAttribute: NSLayoutConstraint.Attribute { get }
}

public enum XAxis : Axis {
    case left
    case right
    case leading
    case trailing
    case centerX
    
    public var layoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .left: return .left
        case .right: return .right
        case .leading: return .leading
        case .trailing: return .trailing
        case .centerX: return .centerX
        }
    }
    
}

public enum YAxis : Axis {
    case top
    case bottom
    case centerY
    case lastBaseline
    case firstBaseline
    
    public var layoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .centerY: return .centerY
        case .lastBaseline: return .lastBaseline
        case .firstBaseline: return .firstBaseline
        }
    }
}

public enum Dimension {
    case width
    case height
    
    public var layoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .width: return .width
        case .height: return .height
        }
    }
    
}

public enum Target : Equatable {
    case superview
    case superviewSafeArea
    case superviewMargins
    case superviewReadableContent
    case keyboard
    case sibling(key: AnyHashable)
}

extension Target {
    
    func item(superview: UIView, window: UIWindow, siblings: [AnyHashable: AnyObject]) -> AnyObject {
        switch self {
        case .superview: return superview
        case .superviewSafeArea:
            if #available(iOS 11.0, *) {
                return superview.safeAreaLayoutGuide
            } else {
                fatalError("Safe area constraints are only supported in iOS 11 and above")
            }
        case .superviewMargins: return superview.layoutMarginsGuide
        case .superviewReadableContent: return superview.readableContentGuide
        case .keyboard: return window.keyboardLayoutGuide
        case .sibling(let key):
            guard let sibling = siblings[key] else {
                fatalError("Unable to find sibling view or layout guide for key: \(key)")
            }
            return sibling
        }
    }
    
}

public let superview = Target.superview
public let parent = superview
public let safeArea = Target.superviewSafeArea
public let margins = Target.superviewMargins
public let readableContent = Target.superviewReadableContent
public func sibling(key: AnyHashable) -> Target {
    return .sibling(key: key)
}

extension Target {
    
    public var left: TargetAndAttribute<XAxis> {
        return (self, .left)
    }
    
    public var right: TargetAndAttribute<XAxis> {
        return (self, .right)
    }
    
    public var top: TargetAndAttribute<YAxis> {
        return (self, .top)
    }
    
    public var bottom: TargetAndAttribute<YAxis> {
        return (self, .bottom)
    }
    
    public var leading: TargetAndAttribute<XAxis> {
        return (self, .leading)
    }
    
    public var trailing: TargetAndAttribute<XAxis> {
        return (self, .trailing)
    }
    
    public var width: TargetAndAttribute<Dimension> {
        return (self, .width)
    }
    
    public var height: TargetAndAttribute<Dimension> {
        return (self, .height)
    }
    
    public var centerX: TargetAndAttribute<XAxis> {
        return (self, .centerX)
    }
    
    public var centerY: TargetAndAttribute<YAxis> {
        return (self, .centerY)
    }
    
    public var lastBaseline: TargetAndAttribute<YAxis> {
        return (self, .lastBaseline)
    }
    
    public var firstBaseline: TargetAndAttribute<YAxis> {
        return (self, .firstBaseline)
    }
    
}

public typealias TargetAndAttribute<Attribute> = (target: Target, attribute: Attribute)
public typealias TargetAndAttributeAndConstant<Attribute> = (targetAndAttribute: TargetAndAttribute<Attribute>, constant: CGFloat)
public typealias TargetAndAttributeAndConstantAndPriority<Attribute> = (
    targetAndAttribute: TargetAndAttribute<Attribute>,
    constant: CGFloat,
    priority: UILayoutPriority
)
public typealias TargetAndDimensionAndMultiplier = (targetAndDimension: TargetAndAttribute<Dimension>, multiplier: CGFloat)
public typealias TargetAndDimensionAndMultiplierAndConstant = (
    targetAndDimension: TargetAndAttribute<Dimension>,
    multiplier: CGFloat,
    constant: CGFloat
)
public typealias TargetAndDimensionAndMultiplierAndConstantAndPriority = (
    targetAndDimension: TargetAndAttribute<Dimension>,
    multiplier: CGFloat,
    constant: CGFloat,
    priority: UILayoutPriority
)
public typealias DimensionAndMultiplier = (dimension: Dimension, multiplier: CGFloat)
public typealias DimensionAndMultiplierAndConstant = (dimension: Dimension, multiplier: CGFloat, constant: CGFloat)
public typealias DimensionAndMultiplierAndConstantAndPriority = (dimension: Dimension, multiplier: CGFloat, constant: CGFloat, priority: UILayoutPriority)
public typealias ConstantAndPriority = (constant: CGFloat, priority: UILayoutPriority)

public struct Constraint : Equatable {
    let attribute: NSLayoutConstraint.Attribute
    let relation: NSLayoutConstraint.Relation
    let target: Target?
    let targetAttribute: NSLayoutConstraint.Attribute
    let multiplier: CGFloat
    let constant: CGFloat
    let priority: UILayoutPriority
    
    fileprivate init(
        attribute: NSLayoutConstraint.Attribute,
        relation: NSLayoutConstraint.Relation,
        target: Target?,
        targetAttribute: NSLayoutConstraint.Attribute,
        multiplier: CGFloat,
        constant: CGFloat,
        priority: UILayoutPriority
    ) {
        self.attribute = attribute
        self.relation = relation
        self.target = target
        self.targetAttribute = targetAttribute
        self.multiplier = multiplier
        self.constant = constant
        self.priority = priority
    }
    
}

extension Constraint {
    
    // attribute [= | ≥ | ≤] target.attribute + constant
    private init<Attribute : Axis>(
        _ attribute: Attribute,
        _ relation: NSLayoutConstraint.Relation,
        _ targetAndAttribute: TargetAndAttribute<Attribute>,
        _ constant: CGFloat,
        _ priority: UILayoutPriority
    ) {
        self.init(
            attribute: attribute.layoutAttribute,
            relation: relation,
            target: targetAndAttribute.target,
            targetAttribute: targetAndAttribute.attribute.layoutAttribute,
            multiplier: 1,
            constant: constant,
            priority: priority
        )
    }
    
    public init<Attribute : Axis>(
        _ attribute: Attribute,
        equalTo targetAndAttribute: TargetAndAttribute<Attribute>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .equal, targetAndAttribute, constant, priority)
    }
    
    public init<Attribute : Axis>(
        _ attribute: Attribute,
        greaterThanOrEqualTo targetAndAttribute: TargetAndAttribute<Attribute>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .greaterThanOrEqual, targetAndAttribute, constant, priority)
    }
    
    public init<Attribute : Axis>(
        _ attribute: Attribute,
        lessThanOrEqualTo targetAndAttribute: TargetAndAttribute<Attribute>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .lessThanOrEqual, targetAndAttribute, constant, priority)
    }
    
}

public func == <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttribute<Attribute>) -> Constraint {
    return Constraint(lhs, equalTo: rhs)
}

public func == <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttributeAndConstant<Attribute>) -> Constraint {
    return Constraint(lhs, equalTo: rhs.targetAndAttribute, constant: rhs.constant)
}

public func == <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttributeAndConstantAndPriority<Attribute>) -> Constraint {
    return Constraint(lhs, equalTo: rhs.targetAndAttribute, constant: rhs.constant, priority: rhs.priority)
}

public func >= <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttribute<Attribute>) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs)
}

public func >= <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttributeAndConstant<Attribute>) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.targetAndAttribute, constant: rhs.constant)
}

public func >= <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttributeAndConstantAndPriority<Attribute>) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.targetAndAttribute, constant: rhs.constant, priority: rhs.priority)
}

public func <= <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttribute<Attribute>) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs)
}

public func <= <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttributeAndConstant<Attribute>) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.targetAndAttribute, constant: rhs.constant)
}

public func <= <Attribute : Axis>(lhs: Attribute, rhs: TargetAndAttributeAndConstantAndPriority<Attribute>) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.targetAndAttribute, constant: rhs.constant, priority: rhs.priority)
}

public func + <Attribute : Axis>(lhs: TargetAndAttribute<Attribute>, rhs: CGFloat) -> TargetAndAttributeAndConstant<Attribute> {
    return TargetAndAttributeAndConstant(lhs, rhs)
}

public func - <Attribute : Axis>(lhs: TargetAndAttribute<Attribute>, rhs: CGFloat) -> TargetAndAttributeAndConstant<Attribute> {
    return TargetAndAttributeAndConstant(lhs, -rhs)
}

public func | <Attribute : Axis>(lhs: TargetAndAttribute<Attribute>, rhs: UILayoutPriority) -> TargetAndAttributeAndConstantAndPriority<Attribute> {
    return TargetAndAttributeAndConstantAndPriority(lhs, 0, rhs)
}

public func | <Attribute : Axis>(lhs: TargetAndAttributeAndConstant<Attribute>, rhs: UILayoutPriority) -> TargetAndAttributeAndConstantAndPriority<Attribute> {
    return TargetAndAttributeAndConstantAndPriority(lhs.targetAndAttribute, lhs.constant, rhs)
}

extension Constraint {
    
    // dimension [= | ≥ | ≤] target.dimension * multiplier + constant
    private init(
        _ attribute: Dimension,
        _ relation: NSLayoutConstraint.Relation,
        _ targetAndAttribute: TargetAndAttribute<Dimension>,
        _ multiplier: CGFloat,
        _ constant: CGFloat,
        _ priority: UILayoutPriority
    ) {
        self.init(
            attribute: attribute.layoutAttribute,
            relation: relation,
            target: targetAndAttribute.target,
            targetAttribute: targetAndAttribute.attribute.layoutAttribute,
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }
    
    public init(
        _ attribute: Dimension,
        equalTo targetAndAttribute: TargetAndAttribute<Dimension>,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .equal, targetAndAttribute, multiplier, constant, priority)
    }
    
    public init(
        _ attribute: Dimension,
        greaterThanOrEqualTo targetAndAttribute: TargetAndAttribute<Dimension>,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .greaterThanOrEqual, targetAndAttribute, multiplier, constant, priority)
    }
    
    public init(
        _ attribute: Dimension,
        lessThanOrEqualTo targetAndAttribute: TargetAndAttribute<Dimension>,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .lessThanOrEqual, targetAndAttribute, multiplier, constant, priority)
    }
    
}

public func == (lhs: Dimension, rhs: TargetAndAttribute<Dimension>) -> Constraint {
    return Constraint(lhs, equalTo: rhs)
}

public func == (lhs: Dimension, rhs: TargetAndDimensionAndMultiplier) -> Constraint {
    return Constraint(lhs, equalTo: rhs.targetAndDimension, multiplier: rhs.multiplier)
}

public func == (lhs: Dimension, rhs: TargetAndDimensionAndMultiplierAndConstant) -> Constraint {
    return Constraint(lhs, equalTo: rhs.targetAndDimension, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func == (lhs: Dimension, rhs: TargetAndDimensionAndMultiplierAndConstantAndPriority) -> Constraint {
    return Constraint(lhs, equalTo: rhs.targetAndDimension, multiplier: rhs.multiplier, constant: rhs.constant, priority: rhs.priority)
}

public func >= (lhs: Dimension, rhs: TargetAndAttribute<Dimension>) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs)
}

public func >= (lhs: Dimension, rhs: TargetAndDimensionAndMultiplier) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.targetAndDimension, multiplier: rhs.multiplier)
}

public func >= (lhs: Dimension, rhs: TargetAndDimensionAndMultiplierAndConstant) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.targetAndDimension, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func >= (lhs: Dimension, rhs: TargetAndDimensionAndMultiplierAndConstantAndPriority) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.targetAndDimension, multiplier: rhs.multiplier, constant: rhs.constant, priority: rhs.priority)
}

public func <= (lhs: Dimension, rhs: TargetAndAttribute<Dimension>) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs)
}

public func <= (lhs: Dimension, rhs: TargetAndDimensionAndMultiplier) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.targetAndDimension, multiplier: rhs.multiplier)
}

public func <= (lhs: Dimension, rhs: TargetAndDimensionAndMultiplierAndConstant) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.targetAndDimension, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func <= (lhs: Dimension, rhs: TargetAndDimensionAndMultiplierAndConstantAndPriority) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.targetAndDimension, multiplier: rhs.multiplier, constant: rhs.constant, priority: rhs.priority)
}

public func * (lhs: TargetAndAttribute<Dimension>, rhs: CGFloat) -> TargetAndDimensionAndMultiplier {
    return TargetAndDimensionAndMultiplier(lhs, rhs)
}

public func / (lhs: TargetAndAttribute<Dimension>, rhs: CGFloat) -> TargetAndDimensionAndMultiplier {
    return TargetAndDimensionAndMultiplier(lhs, 1/rhs)
}

public func + (lhs: TargetAndAttribute<Dimension>, rhs: CGFloat) -> TargetAndDimensionAndMultiplierAndConstant {
    return TargetAndDimensionAndMultiplierAndConstant(lhs, 1, rhs)
}

public func - (lhs: TargetAndAttribute<Dimension>, rhs: CGFloat) -> TargetAndDimensionAndMultiplierAndConstant {
    return TargetAndDimensionAndMultiplierAndConstant(lhs, 1, -rhs)
}

public func + (lhs: TargetAndDimensionAndMultiplier, rhs: CGFloat) -> TargetAndDimensionAndMultiplierAndConstant {
    return TargetAndDimensionAndMultiplierAndConstant(lhs.targetAndDimension, lhs.multiplier, rhs)
}

public func - (lhs: TargetAndDimensionAndMultiplier, rhs: CGFloat) -> TargetAndDimensionAndMultiplierAndConstant {
    return TargetAndDimensionAndMultiplierAndConstant(lhs.targetAndDimension, lhs.multiplier, -rhs)
}

public func | (lhs: TargetAndAttribute<Dimension>, rhs: UILayoutPriority) -> TargetAndDimensionAndMultiplierAndConstantAndPriority {
    return TargetAndDimensionAndMultiplierAndConstantAndPriority(lhs, 1, 0, rhs)
}

public func | (lhs: TargetAndDimensionAndMultiplier, rhs: UILayoutPriority) -> TargetAndDimensionAndMultiplierAndConstantAndPriority {
    return TargetAndDimensionAndMultiplierAndConstantAndPriority(lhs.targetAndDimension, lhs.multiplier, 0, rhs)
}

public func | (lhs: TargetAndDimensionAndMultiplierAndConstant, rhs: UILayoutPriority) -> TargetAndDimensionAndMultiplierAndConstantAndPriority {
    return TargetAndDimensionAndMultiplierAndConstantAndPriority(lhs.targetAndDimension, lhs.multiplier, lhs.constant, rhs)
}

extension Constraint {
    
    // dimension [= | ≥ | ≤] dimension * multiplier + constant
    private init(
        _ attribute: Dimension,
        _ relation: NSLayoutConstraint.Relation,
        _ targetAttribute: Dimension,
        _ multiplier: CGFloat,
        _ constant: CGFloat,
        _ priority: UILayoutPriority
    ) {
        self.init(
            attribute: attribute.layoutAttribute,
            relation: relation,
            target: nil,
            targetAttribute: targetAttribute.layoutAttribute,
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }
    
    public init(
        _ attribute: Dimension,
        equalTo targetAttribute: Dimension,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .equal, targetAttribute, multiplier, constant, priority)
    }
    
    public init(
        _ attribute: Dimension,
        greaterThanOrEqualTo targetAttribute: Dimension,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .greaterThanOrEqual, targetAttribute, multiplier, constant, priority)
    }
    
    public init(
        _ attribute: Dimension,
        lessThanOrEqualTo targetAttribute: Dimension,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .lessThanOrEqual, targetAttribute, multiplier, constant, priority)
    }
    
}

public func == (lhs: Dimension, rhs: Dimension) -> Constraint {
    return Constraint(lhs, equalTo: rhs)
}

public func == (lhs: Dimension, rhs: DimensionAndMultiplier) -> Constraint {
    return Constraint(lhs, equalTo: rhs.dimension, multiplier: rhs.multiplier)
}

public func == (lhs: Dimension, rhs: DimensionAndMultiplierAndConstant) -> Constraint {
    return Constraint(lhs, equalTo: rhs.dimension, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func == (lhs: Dimension, rhs: DimensionAndMultiplierAndConstantAndPriority) -> Constraint {
    return Constraint(lhs, equalTo: rhs.dimension, multiplier: rhs.multiplier, constant: rhs.constant, priority: rhs.priority)
}

public func >= (lhs: Dimension, rhs: Dimension) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs)
}

public func >= (lhs: Dimension, rhs: DimensionAndMultiplier) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.dimension, multiplier: rhs.multiplier)
}

public func >= (lhs: Dimension, rhs: DimensionAndMultiplierAndConstant) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.dimension, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func >= (lhs: Dimension, rhs: DimensionAndMultiplierAndConstantAndPriority) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.dimension, multiplier: rhs.multiplier, constant: rhs.constant, priority: rhs.priority)
}

public func <= (lhs: Dimension, rhs: Dimension) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs)
}

public func <= (lhs: Dimension, rhs: DimensionAndMultiplier) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.dimension, multiplier: rhs.multiplier)
}

public func <= (lhs: Dimension, rhs: DimensionAndMultiplierAndConstant) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.dimension, multiplier: rhs.multiplier, constant: rhs.constant)
}

public func <= (lhs: Dimension, rhs: DimensionAndMultiplierAndConstantAndPriority) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.dimension, multiplier: rhs.multiplier, constant: rhs.constant, priority: rhs.priority)
}

public func * (lhs: Dimension, rhs: CGFloat) -> DimensionAndMultiplier {
    return DimensionAndMultiplier(lhs, rhs)
}

public func / (lhs: Dimension, rhs: CGFloat) -> DimensionAndMultiplier {
    return DimensionAndMultiplier(lhs, 1/rhs)
}

public func + (lhs: Dimension, rhs: CGFloat) -> DimensionAndMultiplierAndConstant {
    return DimensionAndMultiplierAndConstant(lhs, 1, rhs)
}

public func - (lhs: Dimension, rhs: CGFloat) -> DimensionAndMultiplierAndConstant {
    return DimensionAndMultiplierAndConstant(lhs, 1, -rhs)
}

public func + (lhs: DimensionAndMultiplier, rhs: CGFloat) -> DimensionAndMultiplierAndConstant {
    return DimensionAndMultiplierAndConstant(lhs.dimension, lhs.multiplier, rhs)
}

public func - (lhs: DimensionAndMultiplier, rhs: CGFloat) -> DimensionAndMultiplierAndConstant {
    return DimensionAndMultiplierAndConstant(lhs.dimension, lhs.multiplier, -rhs)
}

public func | (lhs: Dimension, rhs: UILayoutPriority) -> DimensionAndMultiplierAndConstantAndPriority {
    return DimensionAndMultiplierAndConstantAndPriority(lhs, 1, 0, rhs)
}

public func | (lhs: DimensionAndMultiplier, rhs: UILayoutPriority) -> DimensionAndMultiplierAndConstantAndPriority {
    return DimensionAndMultiplierAndConstantAndPriority(lhs.dimension, lhs.multiplier, 0, rhs)
}

public func | (lhs: DimensionAndMultiplierAndConstant, rhs: UILayoutPriority) -> DimensionAndMultiplierAndConstantAndPriority {
    return DimensionAndMultiplierAndConstantAndPriority(lhs.dimension, lhs.multiplier, lhs.constant, rhs)
}

extension Constraint {
    
    // dimension [= | ≥ | ≤] constant
    private init(
        _ attribute: Dimension,
        _ relation: NSLayoutConstraint.Relation,
        _ constant: CGFloat,
        _ priority: UILayoutPriority
    ) {
        self.init(
            attribute: attribute.layoutAttribute,
            relation: relation,
            target: nil,
            targetAttribute: .notAnAttribute,
            multiplier: 1,
            constant: constant,
            priority: priority
        )
    }
    
    /**
     - Returns: A dimension constraint equal to a constant
    */
    public init(
        _ attribute: Dimension,
        equalTo constant: CGFloat,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .equal, constant, priority)
    }
    
    public init(
        _ attribute: Dimension,
        greaterThanOrEqualTo constant: CGFloat,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .greaterThanOrEqual, constant, priority)
    }
    
    public init(
        _ attribute: Dimension,
        lessThanOrEqualTo constant: CGFloat,
        priority: UILayoutPriority = .required
    ) {
        self.init(attribute, .lessThanOrEqual, constant, priority)
    }
    
}

public func ==(lhs: Dimension, rhs: CGFloat) -> Constraint {
    return Constraint(lhs, equalTo: rhs)
}

public func ==(lhs: Dimension, rhs: ConstantAndPriority) -> Constraint {
    return Constraint(lhs, equalTo: rhs.constant, priority: rhs.priority)
}

public func >=(lhs: Dimension, rhs: CGFloat) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs)
}

public func >=(lhs: Dimension, rhs: ConstantAndPriority) -> Constraint {
    return Constraint(lhs, greaterThanOrEqualTo: rhs.constant, priority: rhs.priority)
}

public func <=(lhs: Dimension, rhs: CGFloat) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs)
}

public func <=(lhs: Dimension, rhs: ConstantAndPriority) -> Constraint {
    return Constraint(lhs, lessThanOrEqualTo: rhs.constant, priority: rhs.priority)
}

public func | (lhs: CGFloat, rhs: UILayoutPriority) -> ConstantAndPriority {
    return ConstantAndPriority(lhs, rhs)
}
