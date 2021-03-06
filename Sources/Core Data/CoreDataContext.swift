//
//  CoreDataContext.swift
//  Watch
//
//  Created by fordpass on 04/02/2019.
//  Copyright © 2019 Ford Motor Company. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataContext {
    
    private var modelName: String
    private var managedObjectModel: NSManagedObjectModel?
    
    public init(modelName: String, managedObjectModel: NSManagedObjectModel? = nil) {
        self.modelName = modelName
        self.managedObjectModel = managedObjectModel
    }
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container: NSPersistentContainer
        if let managedObjectModel = self.managedObjectModel {
            container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        } else {
          container = NSPersistentContainer(name: modelName)
        }
//        let description = NSPersistentStoreDescription()
//        description.type = NSInMemoryStoreType
//        description.shouldAddStoreAsynchronously = false
//        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
               log.error("Error with the persistent container: \(error)")
            }
        })
        return container
    }()
    
    public func saveContext () throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                log.error("Error while saving context: \(nserror.localizedDescription)")
                throw nserror
            }
        }
    }
    
}
