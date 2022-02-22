import Foundation

public protocol Repository {
    associatedtype Element: Equatable
    func save(element: Element) throws -> Element
    func update(element: Element) throws -> Element
    func delete(element: Element)
    func filter(query: (Element) -> Bool) -> [Element]
    func first(where: (Element) -> Bool) -> Element?
    var first: Element? { get }
    func contains(condition: (Element) -> Bool) -> Bool
    func contains(element: Element) -> Bool
    var isEmpty: Bool { get }
    var getAll: [Element] { get }
    func empty()
}

public struct AnyRepository<AnyStorage: Repository,
                            Element>: Repository where AnyStorage.Element == Element {
    private let storage: AnyStorage
    public typealias Element = Element
    
    public init(storage: AnyStorage) {
        self.storage = storage
    }
    
    public var getAll: [Element] { storage.getAll }
    
    public func save(element: Element) throws -> Element {
        return try storage.save(element: element)
    }
    
    public func update(element: Element) throws -> Element {
        return try storage.update(element: element)
    }
    
    public func delete(element: Element) {
        return storage.delete(element: element)
    }
    
    public func filter(query: (Element) -> Bool) -> [Element] {
        return storage.filter(query: query)
    }
    
    public func first(where: (Element) -> Bool) -> Element? {
        return storage.first(where: `where`)
    }
    
    public var first: Element? {
        storage.first
    }
    
    public func contains(condition: (Element) -> Bool) -> Bool {
        return storage.contains(condition: condition)
    }
    
    public func contains(element: Element) -> Bool {
        return storage.contains(element: element)
    }
    
    public var isEmpty: Bool {
        storage.isEmpty
    }
    
    public func empty() {
        storage.empty()
    }
}
