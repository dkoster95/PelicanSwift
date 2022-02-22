

import Foundation
import CoreData

public protocol Identifiable {
    var id: (key: String, value: CustomStringConvertible) { get }
}

public protocol PersistibleEntity: Equatable, Identifiable {
    init(fromManagedObject: NSManagedObject) throws
    func asManagedObject(entityName: String,
                         with context: NSManagedObjectContext) throws -> NSManagedObject
    func merge(into: NSManagedObject)
}
