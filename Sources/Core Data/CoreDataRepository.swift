import Foundation
import CoreData

public struct CDRepository<PersistibleElement: PersistibleEntity>: Repository {
    public typealias Element = PersistibleElement
    private let entityName: String
    private let persistenceContainer: NSPersistentContainer
    
    public init(entityName: String, persistenceContainer: NSPersistentContainer) {
        self.entityName = entityName
        self.persistenceContainer = persistenceContainer
    }
    
    private func saveContext () throws {
        let context = persistenceContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
    
    public func save(element: PersistibleElement) throws -> PersistibleElement {
        guard !contains(element: element) else { throw RepositoryError.duplicatedData }
        _ = try element.asManagedObject(entityName: entityName, with: persistenceContainer.viewContext)
        try saveContext()
        return element
    }
    
    public func update(element: PersistibleElement) throws -> PersistibleElement {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value.description)
        let results = try persistenceContainer.viewContext.fetch(fetchRequest)
        guard let first = results.first else { throw RepositoryError.nonExistingData }
        element.merge(into: first)
        try saveContext()
        guard let elementSaved = self.first else { throw RepositoryError.transactionError }
        return elementSaved
    }
    
    public func delete(element: PersistibleElement) {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value.description)
            let results = try persistenceContainer.viewContext.fetch(fetchRequest)
            guard let first = results.first else { return }
            persistenceContainer.viewContext.delete(first)
            try saveContext()
        } catch {
            print(error)
        }
    }
    
    public var getAll: [PersistibleElement] {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            let results = try persistenceContainer.viewContext.fetch(fetchRequest)
            return try results.map { try PersistibleElement(fromManagedObject: $0) }
        } catch {
            return []
        }
    }
    
    public func filter(query: (PersistibleElement) -> Bool) -> [PersistibleElement] {
        return getAll.filter(query)
    }
    
    public func first(where: (PersistibleElement) -> Bool) -> PersistibleElement? {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            let result = try persistenceContainer.viewContext.fetch(fetchRequest)
                .map { try PersistibleElement(fromManagedObject: $0) }
                .first(where: `where`)
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    public var first: PersistibleElement? {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            let results = try persistenceContainer.viewContext.fetch(fetchRequest)
            guard let firstResult = results.first else { return nil }
            return try PersistibleElement(fromManagedObject: firstResult)
        } catch {
            print(error)
            return nil
        }
    }
    
    public func contains(condition: (PersistibleElement) -> Bool) -> Bool {
        return first(where: condition) != nil
    }
    
    public func contains(element: PersistibleElement) -> Bool {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value.description)
            let results = try persistenceContainer.viewContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    public var isEmpty: Bool { first == nil }
    
    public func empty() {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            let results = try persistenceContainer.viewContext.fetch(fetchRequest)
            results.forEach { persistenceContainer.viewContext.delete($0) }
            try saveContext()
        } catch {
            print(error)
        }
    }
}
