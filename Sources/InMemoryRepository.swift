

import Foundation

public class InMemoryRepository<PersistibleObject: Equatable>: Repository {
    public typealias Element = PersistibleObject
    
    private var elements: [PersistibleObject] = []
    
    public init() {}
    
    public var getAll: [PersistibleObject] {
        return elements
    }
    
    public func save(element: PersistibleObject) throws -> PersistibleObject {
        guard !contains(element: element) else { throw RepositoryError.duplicatedData }
        elements.append(element)
        return element
    }
    
    public func update(element: PersistibleObject) throws -> PersistibleObject {
        guard let index = elements.firstIndex(of: element) else { return try save(element: element) }
        elements[index] = element
        return elements[index]
    }
    
    public func delete(element: PersistibleObject) {
        guard let index = elements.firstIndex(of: element) else { return }
        elements.remove(at: index)
    }
    
    public func filter(query: (PersistibleObject) -> Bool) -> [PersistibleObject] {
        elements.filter(query)
    }
    
    public func first(where: (PersistibleObject) -> Bool) -> PersistibleObject? {
        elements.first(where: `where`)
    }
    
    public var first: PersistibleObject? { elements.first }
    
    public func contains(condition: (PersistibleObject) -> Bool) -> Bool {
        return elements.contains(where: condition)
    }
    
    public func contains(element: PersistibleObject) -> Bool {
        return elements.contains(element)
    }
    
    public func empty() {
        elements.removeAll()
    }
    
    public var isEmpty: Bool { elements.isEmpty }
    
}
