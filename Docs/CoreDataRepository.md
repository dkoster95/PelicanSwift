
## CoreData Repository

Pelican provides a CoreData repository, a layer written on top of CoreData Framework.
CoreData is The Object relational mappper framework of Swift to manage your DB.
The Core Data Repository Interface presents CRUD operations and its implementation.

###But what problems do we face when using Core Data ?
- Our Business entities tied to NSManagedObject...
Usually to make our entities "persistibles" we gotta make them classes and subclass NSManagedObject to be able to perform DB operations on them.
However this means that we couple our entities to NSManagedObject and also to being classes.
What are we breaking here ? DIP principle. High level module should not depend on low level module and in our case business entities are depending on NSManagedObject, CoreData framework. If CoreData somehow vanishes our entities will require changes to work.
how to fix this ?
Lets see an example with Pelican:
```swift
public protocol CDEntityIdentifiable {
    var identifier: (key: String, value: NSObject) { get }
}

public protocol CoreDataEntity: Equatable, CDEntityIdentifiable {
    init(fromManagedObject: NSManagedObject) throws
    func asManagedObject(entityName: String,
                         with context: NSManagedObjectContext) throws -> NSManagedObject
    func merge(into: NSManagedObject)
}
```

here we have 2 protocols exposed by the framework that act as adapter between entities and NSManagedObject but doesnt tie our Entities to NSManagedObject.
Lets see them in action:
We have an entity person with some basic attributes name, age and address.

```swift
struct Person {
    let name: String
    let age: Int
    let address: String
}
```
Simple right, this is how a business entity should be, no attachments.
Now lets configure it to make it persistible in CoreData.
We have 2 options here, we can create a new class implementing the CoreDataEntity protocol or we can create an extension Independent from the Person file and conform to CoreDataEntity
Option 1:

```swift
struct PersistiblePerson: CoreDataEntity {
    let person: Person
    public var identifier: (key: String, value: NSObject) { (key: "name", value: name as NSObject) }
    
    init(person: Person) {
        self.person = person
    }
    
    init(from: NSManagedObject) throws {
        init(person: Person(name: fromManagedObject.value(forKey: "name") as? String ?? ""
                            age: fromManagedObject.value(forKey: "age") as? Int ?? -1
                            address: fromManagedObject.value(forKey: "address") as? String ?? "")
    }
    
    public func asManagedObject(entityName: String, with context: NSManagedObjectContext) throws -> NSManagedObject {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        managedObject.setValue(person.name, forKey: "name")
        managedObject.setValue(person.age, forKey: "age")
        managedObject.setValue(person.address, forKey: "address")
        return managedObject
    }
    
    public func merge(into: NSManagedObject) {
        into.setValue(person.name, forKey: "name")
        into.setValue(person.age, forKey: "age")
        into.setValue(person.address, forKey: "address")
    }
    
    public static func == (lhs: PersistiblePerson, rhs: PersistiblePerson) -> Bool {
        return lhs.person.name == rhs.person.name
    }
}
```

and this is it!

lets go part by part, Why the init with NSManagedObject, this is to parse from a NSManagedObject stored to the entity you want to handle, its throwable so you can throw an error instead of using default values like I did, very similar to what Decodable does.
why the asManagedObject ? parsing the business entity to NSManagedObject, the encoding part.
why the merge ?
when we update properties in our db we usually dont override all attributes, some attributes are not updatable like primary keys or creation timestamps so here you define which properties are updatable and which ones are not.

Enough of configuring the entity now to the repository part.
What do we need to create a PersonRepository ?



```swift
public struct CoreDataRepository<PersistibleElement: CoreDataEntity>: Repository {
    public typealias Element = PersistibleElement
    private let entityName: String
    private let context: Context
    
    public init(entityName: String, context: Context) {
        self.entityName = entityName
        self.context = context
    }
    
    public func add(element: PersistibleElement) throws -> PersistibleElement {
        return try context.performAndWait {
            guard !contains(element: element) else { throw RepositoryError.duplicatedData }
            _ = try context.create(from: element, entityName: entityName)
            try context.save()
            return element
        }
    }
    ....
    ....
    ...
```

this is an example on how its implemented, you receibe the entity name and the Context (protocol defined by Pelican) and you perform operations there
CoreData Doc (https://developer.apple.com/documentation/coredata)
  
No rocket science, right ? But there is one thing that probably draws your attention and thats the Context protocol, why not have NSManagedObjectContext directly ?
Well, handling concurrency with CoreData can be painful you may have some tricky logic to save or perform updates to the context, you may have child contexts, background contexts that push to parents and your logic may change so The point of the protocol is to be free from however you save to your context or how you materialize transactions   

```swift
public protocol Context {
    func performAndWait<Result>(block: @escaping () throws -> Result) rethrows -> Result
    func perform<Result>(block: @escaping () throws -> Result) async rethrows -> Result
    func save() throws
    func rollback() throws
    func create<Entity: CoreDataEntity>(from: Entity, entityName: String) throws -> NSManagedObject
    func fetch<Result>(_ request: NSFetchRequest<Result>) throws -> [Result]
    func delete(_ object: NSManagedObject) throws
}
```

Here The Context protocol, as you see, nothing weird about it, and Pelican provides an Implementation CDContext which is indeed bound to a NSManagedContext but you can easily right hour own.

```swift
public struct CDContext: Context {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func performAndWait<Result>(block: () throws -> Result) rethrows -> Result {
        return try context.performAndWait {
            return try block()
        }
    }
    
    public func create<Entity: CoreDataEntity>(from: Entity, entityName: String) throws -> NSManagedObject {
        do {
            return try from.asManagedObject(entityName: entityName, with: context)
        } catch let error {
            throw RepositoryError.entityInitializationError(innerError: error)
        }
    }
    
    public func delete(_ object: NSManagedObject) throws {
        context.delete(object)
    }
    
    public func fetch<Result>(_ request: NSFetchRequest<Result>) throws -> [Result] where Result : NSFetchRequestResult {
        do {
            return try context.fetch(request)
        } catch let error {
            throw RepositoryError.queryError(innerError: error)
        }
    }
    
    public func perform<Result>(block: @escaping () throws -> Result) async rethrows -> Result {
        return try await context.perform {
            return try block()
        }
    }
    
    public func rollback() throws {
        context.rollback()
    }
    
    public func save() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                throw RepositoryError.unknownError(error: error)
            }
        }
    }
}
```


So lets continue with our example using CDContext, we have our PersistiblePerson Entity configured, we have our context and now we gotta instantiate the repository


```swift
let persistenceContainer = NSPersistenceContainer(........)
// Configuration of Persistence Container or PersistenceCoordinator is your responsibility

let context = CDContext(context: persistenceContainer.viewContext)
// For this example I will use viewContext but thats also your choice

let repository = CDRepository<PersistiblePerson>(entityName: "PersonEntity",
                                                 context: context)

// Add new Person
let person = Person(name: "Pelican Rocks", age: 21, address: "Pelican Cave")
let persistiblePerson = PersistiblePerson(person: person)
let addedPerson = try repository.add(element: persistiblePerson)

// Remove Person
try repository.delete(element: persistiblePerson)

// Update Person
let updatedPerson = try repository.update(element: persistiblePerson)

// filter
let notOldEnoughToDrinkBeer = repository.filter { $0.age < 21 }

// get all persons
let allPersons = repository.getAll
```
