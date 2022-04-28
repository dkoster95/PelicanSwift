import Foundation
import CoreData
import PelicanProtocols

public struct TestModelEntity: CoreDataEntity {
    public func merge(into: NSManagedObject) {
        into.setValue(name, forKey: "name")
        into.setValue(age, forKey: "age")
    }
    
    public init(name: String, age: Double) {
        self.name = name
        self.age = age
    }
    
    public var identifier: (key: String, value: NSObject) { (key: "name", value: name as NSObject) }
    
    let name: String
    let age: Double
    
    public func asManagedObject(entityName: String,
                                with context: NSManagedObjectContext) throws -> NSManagedObject {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        managedObject.setValue(name, forKey: "name")
        managedObject.setValue(age, forKey: "age")
        return managedObject
    }
    
    public init(fromManagedObject: NSManagedObject) throws {
        name = fromManagedObject.value(forKey: "name") as? String ?? ""
        age = fromManagedObject.value(forKey: "age") as? Double ?? -1
    }
    
    public static func == (lhs: TestModelEntity, rhs: TestModelEntity) -> Bool {
        return lhs.name == rhs.name
    }
}
