import Foundation
import CoreData
import PelicanProtocols

public struct CoreDataRepository<PersistibleElement: CoreDataEntity>: Repository {
    public typealias Element = PersistibleElement
    private let context: Context
    
    public init(context: Context) {
        self.context = context
    }
    
    public func add(element: PersistibleElement) throws -> PersistibleElement {
        return try context.performAndWait {
            guard !contains(element: element) else { throw RepositoryError.duplicatedData }
            _ = try context.create(from: element, entityName: PersistibleElement.entityName)
            try context.save()
            return element
        }
    }
    
    public func update(element: PersistibleElement) throws -> PersistibleElement {
        return try context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
            fetchRequest.predicate = NSPredicate(format: "%K = %@", element.identifier.key, element.identifier.value)
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
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", element.identifier.key, element.identifier.value)
            let results = try context.fetch(fetchRequest)
            guard let first = results.first else { return }
            try context.delete(first)
            try context.save()
        }
    }
    
    public func find(query: ((PersistibleElement) -> Bool)?) -> [PersistibleElement] {
        return context.performAndWait {
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
    }
    
    public func first(where: @escaping (PersistibleElement) -> Bool) -> PersistibleElement? {
        return context.performAndWait {
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
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
        return find().contains(where: condition)
    }
    
    public func contains(element: PersistibleElement) -> Bool {
        return context.performAndWait {
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
    }
    
    public var isEmpty: Bool { find().isEmpty }
    
    public func deleteAll() throws {
        try context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistibleElement.entityName)
            let results = try context.fetch(fetchRequest)
            try results.forEach { try context.delete($0) }
            try context.save()
        }
        
    }
}

extension CoreDataRepository: ExpressionFilterableRepository {
    public func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) -> [PersistibleElement] {
        return context.performAndWait {
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
    }
}

extension CoreDataRepository: BatchRepository {
    public func add(elements: [PersistibleElement]) throws {
        return try context.performAndWait {
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
                let result = try context.execute(batchRequest) as? NSBatchInsertResult
            } catch let error {
                print(error)
                print(error)
                throw RepositoryError.unknownError(error: error)
            }
        }
    }
}
