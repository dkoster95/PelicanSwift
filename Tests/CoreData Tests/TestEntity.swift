//
//  Test+CoreDataProperties.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//
//

import Foundation
import CoreData
import Pelican

public struct TestEntity: PersistibleEntity {
    public func merge(into: NSManagedObject) {
        into.setValue(name, forKey: "name")
        into.setValue(age, forKey: "age")
    }
    
    public init(name: String, age: Double) {
        self.name = name
        self.age = age
    }
    
    public var id: (key: String, value: CustomStringConvertible) { (key: "name", value: name) }
    
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
    public static func == (lhs: TestEntity, rhs: TestEntity) -> Bool {
        return lhs.name == rhs.name
    }
}
