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

public protocol AsyncInsertableRepository<Element>: Sendable {
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

public protocol AsyncPredicableReadableRepository<PersistibleElement, ResultElement> {
    associatedtype PersistibleElement: Equatable
    associatedtype ResultElement: Equatable, Sendable
    func find(predicate: Predicate<PersistibleElement>, sortBy: SortDescriptor<PersistibleElement>?) async -> [ResultElement]
    func findFirst(predicate: Predicate<PersistibleElement>, sortBy: SortDescriptor<PersistibleElement>?) async -> ResultElement?
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

public protocol ReadableRepository<Element>: AsyncReadableRepository, SyncReadableRepository where Element: Sendable, Element: Equatable  {
}

public protocol AsyncReadableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func find(query: (@Sendable (Element) -> Bool)?) async -> [Element]
    func contains(element: Element) async -> Bool
}

public protocol SyncReadableRepository<Element> {
    associatedtype Element: Equatable, Sendable
    var isEmpty: Bool { get }
    func find(query: (@Sendable (Element) -> Bool)?) -> [Element]
    func contains(element: Element) -> Bool
}

public protocol AsyncCheckRepository<Element> {
    associatedtype Element: Equatable, Sendable
    func isEmpty() async throws -> Bool
    func count() async throws -> Int
}

public extension AsyncReadableRepository {
    func find() async -> [Element] {
        return await find(query: nil)
    }
}

public extension SyncReadableRepository {
    func find() -> [Element] {
        return find(query: nil)
    }
}
