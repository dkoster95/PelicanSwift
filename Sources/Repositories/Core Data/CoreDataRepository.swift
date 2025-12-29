import Foundation
import CoreData
import PelicanProtocols

public struct CoreDataRepository<PersistibleElement: CoreDataEntity>: InsertableRepository {
    public typealias Element = PersistibleElement
    private let context: Context
    
    public init(context: Context) {
        self.context = context
    }
    
    private func unsafeAdd(element: PersistibleElement) throws -> PersistibleElement {
        guard !contains(element: element) else { throw RepositoryError.duplicatedData }
        _ = try context.create(from: element, entityName: PersistibleElement.entityName)
        try context.save()
        return element
    }
    
    public func add(element: PersistibleElement) throws -> PersistibleElement {
        return try context.performAndWait {
            return try unsafeAdd(element: element)
        }
    }
    
    public func add(element: PersistibleElement) async throws -> PersistibleElement {
        return try await context.perform {
            return try unsafeAdd(element: element)
        }
    }
}

/// Update operations implemented
extension CoreDataRepository: UpdatableRepository {
    private func unsafeUpdate(element: PersistibleElement) throws -> PersistibleElement {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
        fetchRequest.predicate = NSPredicate(format: "%K = %@", element.identifier.key, element.identifier.value)
        fetchRequest.fetchLimit = 1
        let results = try context.fetch(fetchRequest)
        guard let first = results.first else { throw RepositoryError.nonExistingData }
        element.merge(into: first)
        try context.save()
        return element
    }
    public func update(element: PersistibleElement) throws -> PersistibleElement {
        return try context.performAndWait {
            return try unsafeUpdate(element: element)
        }
    }
    public func update(element: PersistibleElement) async throws -> PersistibleElement {
        return try context.performAndWait {
            return try unsafeUpdate(element: element)
        }
    }
}

/// Delete operations implemented
extension CoreDataRepository: DeleteableRepository {
    
    private func unsafeDelete(element: PersistibleElement) throws {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "%K = %@", element.identifier.key, element.identifier.value)
        let results = try context.fetch(fetchRequest)
        guard let first = results.first else { return }
        try context.delete(first)
        try context.save()
    }
    
    public func delete(element: PersistibleElement) throws {
        try context.performAndWait {
            try unsafeDelete(element: element)
        }
    }
    
    public func delete(element: PersistibleElement) async throws {
        try await context.perform {
            try unsafeDelete(element: element)
        }
    }
    
    private func unsafeDeleteAll() throws {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
        let results = try context.fetch(fetchRequest)
        try results.forEach { try context.delete($0) }
        try context.save()
    }
    
    public func deleteAll() throws {
        try context.performAndWait {
            try unsafeDeleteAll()
        }
    }
    
    public func deleteAll() async throws {
        try await context.perform {
            try unsafeDeleteAll()
        }
    }
}

/// Read Operations for CDRepository
extension CoreDataRepository: ReadableRepository {
    public var isEmpty: Bool {
        return find().count == 0
    }
    
    private func unsafeFind(query:  ((PersistibleElement) -> Bool)?) -> [PersistibleElement] {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
            let results = try context.fetch(fetchRequest)
            let resultsMapped = try results.map { try PersistibleElement(fromManagedObject: $0) }
            if let query = query {
                return resultsMapped.filter(query)
            }
            return resultsMapped
        } catch {
            return []
        }
    }
    
    public func find(query: ((PersistibleElement) -> Bool)?) -> [PersistibleElement] {
        return context.performAndWait {
            return unsafeFind(query: query)
        }
    }
    
    public func find(query: ((PersistibleElement) -> Bool)?) async -> [PersistibleElement] {
        return await context.perform {
            return unsafeFind(query: query)
        }
    }
    
    private func unsafeContains(element: PersistibleElement) -> Bool {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", element.identifier.key, element.identifier.value)
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    public func contains(element: PersistibleElement) -> Bool {
        return context.performAndWait {
            return unsafeContains(element: element)
        }
    }
    
    public func contains(element: PersistibleElement) async -> Bool {
        return await context.perform {
            return unsafeContains(element: element)
        }
    }
    

}

extension CoreDataRepository: PredicateReadableRepository {
    private func unsafeFind(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) -> [PersistibleElement] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
        fetchRequest.predicate = predicate
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        do {
            let results = try context.fetch(fetchRequest)
            return try results.map { try PersistibleElement(fromManagedObject: $0) }
        } catch _ {
            return []
        }
    }
    
    public func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) -> [PersistibleElement] {
        return context.performAndWait {
            return unsafeFind(predicate: predicate, limit: limit, sortDescriptor: sortDescriptor)
        }
    }
    
    public func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) async -> [Element] {
        return await context.perform {
            return unsafeFind(predicate: predicate, limit: limit, sortDescriptor: sortDescriptor)
        }
    }
        
}

extension CoreDataRepository: BatchRepository {
    
    private func unsafeAdd(elements: [PersistibleElement]) throws {
        var elementsCopy = elements
        let batchRequest = NSBatchInsertRequest(entityName: PersistibleElement.entityName) { (object: NSManagedObject) in
            if let element = elementsCopy.popLast() {
                element.merge(into: object)
                return false
            }
            return true
        }
        batchRequest.resultType = .statusOnly
        do {
            _ = try context.execute(batchRequest) as? NSBatchInsertResult
        } catch let error {
            throw RepositoryError.unknownError(error: error)
        }
    }
    
    public func add(elements: [PersistibleElement]) throws {
        return try context.performAndWait {
            try unsafeAdd(elements: elements)
        }
    }
    
    public func add(elements: [PersistibleElement]) async throws {
        return try await context.perform {
            try unsafeAdd(elements: elements)
        }
    }
}
