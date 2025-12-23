import Foundation
import CoreData

public protocol CDEntityIdentifiable {
    var identifier: (key: String, value: NSObject) { get }
}

public protocol CoreDataEntity: Equatable, CDEntityIdentifiable, Sendable {
    init(fromManagedObject: NSManagedObject) throws
    func asManagedObject(entityName: String,
                         with context: NSManagedObjectContext) throws -> NSManagedObject
    func merge(into: NSManagedObject)
    static var entityName: String { get }
}
