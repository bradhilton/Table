//
//  Reusable.swift
//  XTable
//
//  Created by Bradley Hilton on 3/17/18.
//

public struct Reusable<Object : NSObject> : ReuseProtocol {
    public typealias Create = () -> Object
    public typealias Configure = (Object) -> ()
    public typealias Update = (Object) -> ()
    let type: AnyHashable
    let key: AnyHashable
    let create: Create
    let configure: Configure
    let update: Update
    
    init(
        type: AnyHashable,
        key: AnyHashable = .auto,
        create: @escaping Create = Object.init,
        configure: @escaping Configure = { _ in },
        update: @escaping Update = { _ in }
    ) {
        self.type = type
        self.key = key
        self.create = create
        self.configure = configure
        self.update = update
    }
    

    
    func object<C : RangeReplaceableCollection>(reusing pool: inout C) -> Object where C.Element == Object {
        guard let index = pool.firstIndex(where: { $0.type == self.type && $0.key == self.key }) else {
            return newObject()
        }
        let object = pool.remove(at: index)
        update(object)
        return object
    }
    
    func object(reusing object: Object?) -> Object {
        if let object = object, type == object.type {
            update(object)
            return object
        } else {
            return newObject()
        }
    }
    
    func newObject() -> Object {
        let object = create()
        object.type = type
        object.key = key
        configure(object)
        update(object)
        return object
    }
    
}

protocol ReuseProtocol {
    associatedtype Object
    func object(reusing pool: inout [Object]) -> Object
}

let editButtonItemType = "editButtonItemType"
let editButtonItemKey = "editButtonItemKey"

extension Reusable where Object == UIBarButtonItem {
    
    public init(
        file: String = #file,
        line: Int = #line,
        column: Int = #column,
        key: AnyHashable = .auto,
        create: @escaping Create = { Object() },
        configure: @escaping Configure = { _ in },
        update: @escaping Update = { _ in }
    ) {
        self.init(
            type: UniqueDeclaration(file: file, line: line, column: column),
            key: key,
            create: create,
            configure: configure,
            update: update
        )
    }
    
    public static var editButtonItem: Reusable<UIBarButtonItem> {
        return Reusable(
            type: editButtonItemType,
            key: editButtonItemKey,
            create: { UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil) }
        )
    }
    
}

extension Reusable where Object == UISearchController {
    
    public init(
        file: String = #file,
        line: Int = #line,
        column: Int = #column,
        searchResultsController: Controller? = nil,
        configure: @escaping Configure = { _ in },
        update: @escaping Update = { _ in }
    ) {
        self.init(
            type: UniqueDeclaration(file: file, line: line, column: column),
            create: { UISearchController(searchResultsController: searchResultsController?.newViewController()) },
            configure: configure,
            update: { searchController in
                update(searchController)
                searchResultsController.map { searchController.searchResultsController?.update(with: $0) }
            }
        )
    }
    
}

extension Array where Element : ReuseProtocol {

    func objects(reusing pool: inout [Element.Object]) -> [Element.Object] {
        return map { $0.object(reusing: &pool) }
    }
    
    func objects(reusing objects: [Element.Object]) -> [Element.Object] {
        var pool = objects
        return self.objects(reusing: &pool)
    }
    
}

public typealias BarButtonItem = Reusable<UIBarButtonItem>

public typealias SearchController = Reusable<UISearchController>
