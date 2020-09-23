
## CoreData Repository

Pelican provides a CoreData repository, a layer written on top of CoreData Framework.
CoreData is The Object relational mappper framework of Swift to manage your SQLite DB.

Remember that in order to use CoreData properly you need a PersistenceContainer, you need a context to your Entity class.
That Context is the class in charge of setting the configuration for your model, initializing your database adn your entities.
Pelican provides a class for that: **CoreDataContext**
```swift
public class CoreDataContext {

    public init(modelName: String, managedObjectModel: NSManagedObjectModel? = nil)
    
    lazy var persistentContainer: NSPersistentContainer = {}()
    
    func saveContext () throws
}
```

As you can see you just need to initialize the Context with the model name and thats it!

Lets check out the CoreDataRepository implementation

```swift
public class CoreDataRepository<ManagedObject: NSManagedObject>: PelicanRepository<ManagedObject> {
    public init(entityName: String, context: CoreDataContext)

    public override func save(object: ManagedObject) -> Bool
    public override func empty()
    override public var fetchAll: [ManagedObject]
    public override func update(object: ManagedObject) -> Bool
    public override func delete(object: ManagedObject) -> Bool
}
```
CoreData Doc (https://developer.apple.com/documentation/coredata)
In order to use this repository you need a class that conforms to Codable protocol.  
You can also inject the JSONDecoder and Encoder, the class uses the default ones.  
Also the Repository uses the context to load the model configuration and save the data.


