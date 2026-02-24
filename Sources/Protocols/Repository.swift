import Foundation

public protocol BatchRepository<Element>: AsyncBatchRepository, SyncBatchRepository where Element: Equatable, Element: Sendable {
}

public protocol AsyncBatchRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func add(elements: [Element]) async throws
}

public protocol SyncBatchRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func add(elements: [Element]) throws
}

public protocol InsertableRepository<Element>: SyncInsertableRepository, AsyncInsertableRepository where Element: Equatable, Element: Sendable {
}


public protocol SyncInsertableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func add(element: Element) throws -> Element
}

public protocol AsyncInsertableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func add(element: Element) async throws -> Element
}

public protocol AsyncUpdatableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func update(element: Element) async throws -> Element
}

public protocol SyncUpdatableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func update(element: Element) throws -> Element
}

public protocol UpdatableRepository<Element>: AsyncUpdatableRepository, SyncUpdatableRepository where Element: Equatable, Element: Sendable {
}

public protocol AsyncDeleteableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func delete(element: Element) async throws
    func deleteAll() async throws
}

public protocol SyncDeleteableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func delete(element: Element) throws
    func deleteAll() throws
}

public protocol DeleteableRepository<Element>: AsyncDeleteableRepository, SyncDeleteableRepository where Element: Equatable, Element: Sendable {
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

public protocol AsyncReadableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func find(query: (@Sendable (Element) -> Bool)?) async -> [Element]
    func contains(element: Element) async -> Bool
}

public extension AsyncReadableRepository {
    func find() async -> [Element] {
        return await find(query: nil)
    }
}

public extension ReadableRepository {
    func find() -> [Element] {
        return find(query: nil)
    }
    
    func find() async -> [Element] {
        return await find(query: nil)
    }
}
