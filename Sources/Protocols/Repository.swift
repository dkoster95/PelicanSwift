import Foundation

public protocol BatchRepository<Element> {
    associatedtype Element: Equatable
    func add(elements: [Element]) throws
    func add(elements: [Element]) async throws
}

public typealias CRUDRepository<Element> = InsertableRepository<Element> & UpdatableRepository<Element> & DeleteableRepository<Element> & ReadableRepository<Element>

public typealias Repository<Element> = CRUDRepository<Element> & PredicateReadableRepository<Element> & BatchRepository<Element>

public protocol InsertableRepository<Element> {
    associatedtype Element: Equatable
    func add(element: Element) throws -> Element
    func add(element: Element) async throws -> Element
}

public protocol UpdatableRepository<Element> {
    associatedtype Element: Equatable
    func update(element: Element) throws -> Element
    func update(element: Element) async throws -> Element
}

public protocol DeleteableRepository<Element> {
    associatedtype Element: Equatable
    func delete(element: Element) throws
    func delete(element: Element) async throws
    func deleteAll() throws
    func deleteAll() async throws
}

public protocol PredicateReadableRepository<Element> {
    associatedtype Element: Equatable
    func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) async -> [Element]
    func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) -> [Element]
}

extension PredicateReadableRepository {
    func contain(predicate: NSPredicate) async -> Bool {
        return await find(predicate: predicate, limit: nil, sortDescriptor: nil).count > 0
    }
    
    func first(predicate: NSPredicate) async -> Element? {
        return await find(predicate: predicate, limit: 1, sortDescriptor: nil).first
    }
    
    func contain(predicate: NSPredicate) -> Bool {
        return find(predicate: predicate, limit: nil, sortDescriptor: nil).count > 0
    }
    
    func first(predicate: NSPredicate) -> Element? {
        return find(predicate: predicate, limit: 1, sortDescriptor: nil).first
    }
}

public protocol ReadableRepository<Element> {
    associatedtype Element: Equatable
    var isEmpty: Bool { get }
    func find(query: ((Element) -> Bool)?) -> [Element]
    func find(query: ((Element) -> Bool)?) async -> [Element]
    func contains(element: Element) -> Bool
    func contains(element: Element) async -> Bool
}

public extension ReadableRepository {
    func find() -> [Element] {
        return find(query: nil)
    }
    
    func find() async -> [Element] {
        return await find(query: nil)
    }
}
