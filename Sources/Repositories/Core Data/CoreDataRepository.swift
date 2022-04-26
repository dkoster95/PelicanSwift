import Foundation
import CoreData
import PelicanProtocols

public struct CoreDataRepository<PersistibleElement: CoreDataEntity>: Repository {
    public typealias Element = PersistibleElement
    private let entityName: String
    private let context: Context
    
    public init(entityName: String, context: Context) {
        self.entityName = entityName
        self.context = context
    }
    
    //    private func saveContext () throws {
    //        if context.hasChanges {
    //            do {
    //                try context.save()
    //            } catch {
    //                throw error
    //            }
    //        }
    //    }
    
    public func add(element: PersistibleElement) throws -> PersistibleElement {
        return try context.performAndWait {
            guard !contains(element: element) else { throw RepositoryError.duplicatedData }
            _ = try context.create(from: element, entityName: entityName)
            try context.save()
            return element
        }
    }
    
    public func update(element: PersistibleElement) throws -> PersistibleElement {
        return try context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value)
            fetchRequest.fetchLimit = 1
            let results = try context.fetch(fetchRequest)
            guard let first = results.first else { throw RepositoryError.nonExistingData }
            element.merge(into: first)
            try context.save()
            return element
        }
    }
    
    public func delete(element: PersistibleElement) throws {
        try context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "\(element.id.key) = %@", element.id.value)
            let results = try context.fetch(fetchRequest)
            guard let first = results.first else { return }
            try context.delete(first)
            try context.save()
        }
    }
    
    public var getAll: [PersistibleElement] {
        return context.performAndWait {
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
                let results = try context.fetch(fetchRequest)
                return try results.map { try PersistibleElement(fromManagedObject: $0) }
            } catch {
                return []
            }
        }
    }
    
    public func filter(query: (PersistibleElement) -> Bool) -> [PersistibleElement] {
        return getAll.filter(query)
    }
    
    public func first(where: @escaping (PersistibleElement) -> Bool) -> PersistibleElement? {
        return context.performAndWait {
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
                let result = try context.fetch(fetchRequest)
                    .map { try PersistibleElement(fromManagedObject: $0) }
                    .first(where: `where`)
                return result
            } catch {
                print(error)
                return nil
            }
        }
    }
    
    public func contains(condition: (PersistibleElement) -> Bool) -> Bool {
        return getAll.contains(where: condition) 
    }
    
    public func contains(element: PersistibleElement) -> Bool {
        return context.performAndWait {
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
    }
    
    public var isEmpty: Bool { getAll.isEmpty }
    
    public func deleteAll() throws {
        try context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            let results = try context.fetch(fetchRequest)
            try results.forEach { try context.delete($0) }
            try context.save()
        }
        
    }
}
