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
    
    func object(reusing pool: inout [Object]) -> Object {
        guard let index = pool.index(where: { $0.type == self.type && $0.key == self.key }) else {
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

func Type(_ items: Any...) -> String {
    return items.map(String.init(describing:)).joined(separator: ":")
}

protocol ReuseProtocol {
    associatedtype Object
    func object(reusing pool: inout [Object]) -> Object
}

extension Reusable where Object == UIBarButtonItem {
    
    public init(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        key: AnyHashable = .auto,
        create: @escaping Create = { Object() },
        configure: @escaping Configure = { _ in },
        update: @escaping Update = { _ in }
    ) {
        self.init(
            type: Type(file, function, line, column),
            key: key,
            create: create,
            configure: configure,
            update: update
        )
    }
    
}

extension Reusable where Object == UISearchController {
    
    public init(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column,
        searchResultsController: Controller? = nil,
        configure: @escaping Configure = { _ in },
        update: @escaping Update = { _ in }
    ) {
        self.init(
            type: Type(file, function, line, column, searchResultsController?.type as Any),
            create: { UISearchController(searchResultsController: searchResultsController?.newViewController()) },
            configure: configure,
            update: { searchController in
                update(searchController)
                searchController.searchResultsController?.update = searchResultsController?.update
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
