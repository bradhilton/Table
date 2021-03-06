//
//  RefreshControl.swift
//  Table
//
//  Created by Bradley Hilton on 4/24/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

public typealias RefreshControl = Reusable<UIRefreshControl>

extension Reusable where Object == UIRefreshControl {
    
    public init(
        file: String = #file,
        line: Int = #line,
        column: Int = #column,
        create: @escaping Create = { Object() },
        configure: @escaping Configure = { _ in },
        update: @escaping Update = { _ in }
    ) {
        self.init(
            type: UniqueDeclaration(file: file, line: line, column: column),
            create: create,
            configure: configure,
            update: update
        )
    }
    
}

public protocol RefreshControlProtocol : class {
    @available(iOS 10.0, *)
    var refreshControl: UIRefreshControl? { get set }
}

extension UIScrollView : RefreshControlProtocol {}
extension UITableViewController : RefreshControlProtocol {}

extension NSObjectProtocol where Self : RefreshControlProtocol {
    
    public var refreshControl: RefreshControl? {
        get {
            return storage[\.refreshControl]
        }
        set {
            storage[\.refreshControl] = newValue
            if #available(iOS 10.0, *) {
                let newRefreshControl = newValue?.object(reusing: refreshControl)
                if (newRefreshControl != refreshControl) {
                    refreshControl = newRefreshControl
                }
            } else if let viewController = self as? UITableViewController {
                viewController.refreshControl = newValue?.object(reusing: viewController.refreshControl)
            }
        }
    }
    
}
