import Foundation
import CoreData

protocol Context {
    func performAndWait<Result>(block: @escaping () throws -> Result) rethrows -> Result
    func perform<Result>(block: @escaping () throws -> Result) async rethrows -> Result
    func save() throws
    func rollback() throws
}

@available(macOS 12.0, *)
struct CDContext: Context {
    func perform<Result>(block: @escaping () throws -> Result) async rethrows -> Result {
        return try await context.perform {
            return try block()
        }
    }
    
    func rollback() throws {
        context.rollback()
    }
    


    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }

    private let context: NSManagedObjectContext
    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    func performAndWait<Result>(block: () throws -> Result) rethrows -> Result {
        return try context.performAndWait {
            return try block()
        }
    }


}
