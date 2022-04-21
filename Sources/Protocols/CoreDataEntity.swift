import Foundation
import CoreData

public protocol CDEntityIdentifiable {
    var id: (key: String, value: CustomStringConvertible) { get }
}

public protocol CoreDataEntity: Equatable, CDEntityIdentifiable {
    init(fromManagedObject: NSManagedObject) throws
    func asManagedObject(entityName: String,
                         with context: NSManagedObjectContext) throws -> NSManagedObject
    func merge(into: NSManagedObject)
}
