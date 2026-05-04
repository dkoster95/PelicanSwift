import Foundation
import PelicanProtocols

public final class InMemoryRepository<PersistibleObject: Equatable & Sendable>: SyncInsertableRepository, AsyncInsertableRepository, DeleteableRepository, UpdatableRepository, ReadableRepository, @unchecked Sendable {
    public typealias Element = PersistibleObject
    
    private var elements: [PersistibleObject] = []
    
    public init() {}
    
    public func add(element: PersistibleObject) throws -> PersistibleObject {
        guard !contains(element: element) else { throw RepositoryError.duplicatedData }
        elements.append(element)
        return element
    }
    
    public func update(element: PersistibleObject) throws -> PersistibleObject {
        guard let index = elements.firstIndex(of: element) else { return try add(element: element) }
        elements[index] = element
        return elements[index]
    }
    
    public func delete(element: PersistibleObject) throws {
        guard let index = elements.firstIndex(of: element) else { return }
        elements.remove(at: index)
    }
    
    public func find(query: ((PersistibleObject) -> Bool)?) -> [PersistibleObject] {
        guard let query = query else { return elements }
        return elements.filter(query)
    }
    
    public func first(where: (PersistibleObject) -> Bool) -> PersistibleObject? {
        elements.first(where: `where`)
    }
    
    public func contains(condition: (PersistibleObject) -> Bool) -> Bool {
        return elements.contains(where: condition)
    }
    
    public func contains(element: PersistibleObject) -> Bool {
        return elements.contains(element)
    }
    
    public func deleteAll() throws {
        elements.removeAll()
    }
    
    public var isEmpty: Bool { elements.isEmpty }
    
}
