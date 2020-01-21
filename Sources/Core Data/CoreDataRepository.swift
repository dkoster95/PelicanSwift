//
//  CoreDataPersistenceLayer.swift
//  Watch
//
//  Created by fordpass on 04/02/2019.
//  Copyright © 2019 Ford Motor Company. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataRepository<ManagedObject: NSManagedObject>: PelicanRepository<ManagedObject> {
    
    private var entityName: String
    private var context: CoreDataContext
    
    public init(entityName: String, context: CoreDataContext) {
        self.entityName = entityName
        self.context = context
    }
    
    public override func save(object: ManagedObject) -> Bool {
        do {
            try context.saveContext()
            log.debug("💾CoreDataPersistenceLayer💾 - object saved")
            return true
        } catch let error {
            log.error("💾CoreDataPersistenceLayer💾 - failed to save object \(error.localizedDescription)")
            return false
        }
    }
    
    public override func save() -> Bool {
        do {
            try context.saveContext()
            log.debug("💾CoreDataPersistenceLayer💾 - object saved")
            return true
        } catch let error {
            log.error("💾CoreDataPersistenceLayer💾 - failed to save object \(error.localizedDescription)")
            return false
        }
    }
    
    public override func delete(object: ManagedObject) -> Bool {
        do {
            context.persistentContainer.viewContext.delete(object)
            try context.saveContext()
            log.debug("💾CoreDataPersistenceLayer💾 - object deleted")
            return true
        } catch {
            log.error("💾CoreDataPersistenceLayer💾 - failed to delete object")
            return false
        }
    }
    
    public override func retrieve(query: ((ManagedObject) -> Bool)?, completionHandler: (Result<[ManagedObject], Error>) -> Void) {
        let fetchRequest = NSFetchRequest<ManagedObject>(entityName: entityName)
        do {
            let results = try context.persistentContainer.viewContext.fetch(fetchRequest)
            if let queryForList = query {
                var resultsFiltered: [ManagedObject] = []
                for result in results {
                    if queryForList(result) {
                        resultsFiltered.append(result)
                    }
                }
                completionHandler(.success(resultsFiltered))
                return
            }
            completionHandler(.success(results))
        } catch {
            log.error("💾CoreDataPersistenceLayer💾 - No Error fetching")
            completionHandler(Result.failure(PelicanRepositoryError.serializationError))
        }
    }
    
    override public var fetchAll: [ManagedObject] {
        let fetchRequest = NSFetchRequest<ManagedObject>(entityName: entityName)
        do {
            let results = try context.persistentContainer.viewContext.fetch(fetchRequest)
            return results
        } catch let error {
            log.debug("💾CoreDataPersistenceLayer💾 - No results \(error.localizedDescription)")
            return []
        }
    }
    
    public override func empty() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                context.persistentContainer.viewContext.delete(objectData)
            }
            try context.saveContext()
        } catch let error {
            log.error("💾CoreDataPersistenceLayer💾 - Error loading: \(error)")
        }
    }
}
