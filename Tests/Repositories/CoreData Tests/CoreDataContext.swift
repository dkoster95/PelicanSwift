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
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        //        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                //log.error("Error with the persistent container: \(error)")
            }
        })
        return container
    }()
}
