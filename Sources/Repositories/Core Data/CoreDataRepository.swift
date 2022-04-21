import Foundation
import CoreData
import PelicanProtocols

public struct CoreDataRepository<PersistibleElement: CoreDataEntity>: Repository {
    public typealias Element = PersistibleElement
    private let entityName: String
    private let context: NSManagedObjectContext
    
    public init(entityName: String, context: NSManagedObjectContext) {
        self.entityName = entityName
        self.context = context
    }
    
    private func saveContext () throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
    
    public func add(element: PersistibleElement) throws -> PersistibleElement {
        guard !contains(element: element) else { throw RepositoryError.duplicatedData }
        _ = try element.asManagedObject(entityName: entityName, with: context)
        try saveContext()
        return element
    }
    
    public func update(element: PersistibleElement) throws -> PersistibleElement {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value.description)
        fetchRequest.fetchLimit = 1
        let results = try context.fetch(fetchRequest)
        guard let first = results.first else { throw RepositoryError.nonExistingData }
        element.merge(into: first)
        try saveContext()
        return element
    }
    
    public func delete(element: PersistibleElement) {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value.description)
            let results = try context.fetch(fetchRequest)
            guard let first = results.first else { return }
            context.delete(first)
            try saveContext()
        } catch {
            print(error)
        }
    }
    
    public var getAll: [PersistibleElement] {
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            let results = try context.fetch(fetchRequest)
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
            fetchRequest.fetchLimit = 1
            let result = try context.fetch(fetchRequest)
                .map { try PersistibleElement(fromManagedObject: $0) }
                .first(where: `where`)
            return result
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
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value.description)
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    public var isEmpty: Bool { getAll.isEmpty }
    
    public func deleteAll() throws {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0) }
        try saveContext()
        
    }
}
