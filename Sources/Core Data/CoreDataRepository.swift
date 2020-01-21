//
//  CoreDataPersistenceLayer.swift
//  Watch
//
//  Created by fordpass on 04/02/2019.
//  Copyright © 2019 Ford Motor Company. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataRepository<T: NSManagedObject>: PelicanRepository<T> {
    
    private var entityName: String
    private var context: CoreDataContext
    
    public init(entityName: String, context: CoreDataContext) {
        self.entityName = entityName
        self.context = context
    }
    
    public override func save(object: T) -> Bool {
        do {
            try context.saveContext()
            log.debug("💾CoreDataPersistenceLayer💾 - object saved")
            return true
        } catch {
            log.error("💾CoreDataPersistenceLayer💾 - failed to save object")
            return false
        }
    }
    
    public override func save() -> Bool {
        do {
            try context.saveContext()
            log.debug("💾CoreDataPersistenceLayer💾 - object saved")
            return true
        } catch {
            log.error("💾CoreDataPersistenceLayer💾 - failed to save object")
            return false
        }
    }
    
    public override func delete(object: T) -> Bool {
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
    
    public override func retrieve(query: ((T) -> Bool)?, completionHandler: (Result<[T], Error>) -> Void) {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        do {
            let results = try context.persistentContainer.viewContext.fetch(fetchRequest)
            if let queryForList = query {
                var resultsFiltered: [T] = []
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
    
    override public var fetchAll: [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        do {
            let results = try context.persistentContainer.viewContext.fetch(fetchRequest)
            return results
        } catch {
            log.debug("💾CoreDataPersistenceLayer💾 - No results")
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
