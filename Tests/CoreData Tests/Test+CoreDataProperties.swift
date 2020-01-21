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


extension Test {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Test> {
//        return NSFetchRequest<Test>(entityName: "Test")
//    }

    @NSManaged public var name: String?
    @NSManaged public var age: Double
    
    convenience init(name: String, age: Double, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.age = age
    }

}
