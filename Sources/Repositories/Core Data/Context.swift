import Foundation
import CoreData
import PelicanProtocols

public protocol Context {
    func performAndWait<Result>(block: @escaping () throws -> Result) rethrows -> Result
    func perform<Result>(block: @escaping () throws -> Result) async rethrows -> Result
    func save() throws
    func rollback() throws
    func create<Entity: CoreDataEntity>(from: Entity, entityName: String) throws -> NSManagedObject
    func fetch<Result>(_ request: NSFetchRequest<Result>) throws -> [Result]
    func delete(_ object: NSManagedObject) throws
}

public struct CDContext: Context {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func performAndWait<Result>(block: () throws -> Result) rethrows -> Result {
        return try context.performAndWait {
            return try block()
        }
    }
    
    public func create<Entity: CoreDataEntity>(from: Entity, entityName: String) throws -> NSManagedObject {
        do {
            return try from.asManagedObject(entityName: entityName, with: context)
        } catch let error {
            throw RepositoryError.entityInitializationError(innerError: error)
        }
    }
    
    public func delete(_ object: NSManagedObject) throws {
        context.delete(object)
    }
    
    public func fetch<Result>(_ request: NSFetchRequest<Result>) throws -> [Result] where Result : NSFetchRequestResult {
        do {
            return try context.fetch(request)
        } catch let error {
            throw RepositoryError.queryError(innerError: error)
        }
    }
    
    public func perform<Result>(block: @escaping () throws -> Result) async rethrows -> Result {
        return try await context.perform {
            return try block()
        }
    }
    
    public func rollback() throws {
        context.rollback()
    }
    
    public func save() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                throw RepositoryError.unknownError(error: error)
            }
        }
    }
}
