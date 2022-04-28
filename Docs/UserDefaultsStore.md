
## UserDefaults Store

Pelican provides a UserDefaults Store to handle your UserDefaults data flow.
Keep in mind what the purpose of User Defaults is, store user preferences (dummy preferences) dont store important data of your app in user Defaults.

And now Lets check out the UserDefaultsStore implementation

```swift
public struct UserDefaultsStore: KeyValueStore {
    private let userDefaults: UserDefaults
    private let logger: Logger?
    
    public init(userDefaults: UserDefaults, logger: Logger? = nil) {
        self.userDefaults = userDefaults
        self.logger = logger
    }
    
    public func save(data: Data, key: String) -> Bool {
        logger?.debug("📱UserDefaultsLayer📱 - saving data for key: \(key)")
        userDefaults.set(data, forKey: key)
        return userDefaults.synchronize()
    }
    
    public func update(data: Data, key: String) -> Bool {
        logger?.debug("📱UserDefaultsLayer📱 - updating data for key: \(key)")
        return save(data: data, key: key)
    }
    
    public func delete(key: String) -> Bool {
        logger?.debug("📱UserDefaultsLayer📱 - deleting data for key: \(key)")
        userDefaults.removeObject(forKey: key)
        return userDefaults.object(forKey: key) == nil
    }
    
    public func fetch(key: String) -> Data? {
        logger?.debug("📱UserDefaultsLayer📱 - fetching data for key: \(key)")
        return userDefaults.data(forKey: key)
    }
}
```
The repository uses the UserDefaults Swift class. Doc (https://developer.apple.com/documentation/foundation/userdefaults)

As you can see its simple, just implementing the KeyValueStore protocol that provides CRUD operations for a KeyValue model.
Codable not included in this version of the Store.

But you can use Pelican's ObjectKeyValueStore that is bound to Codable to map your objects easier

```swift

// you configure your own UserDefaults, its independent from configuration
let userDefaultsStore = UserDefaultsStore(userDefaults: .standard)

let someData: Data = ......

let didSaveValue = userDefaultsStore(data: someData, key: "test")

// you can also use the subscript

userDefaultsStore["test"] = someData

// or you can use the ObjectKeyStore

let store = ObjectKeyStore(encoder: JSONEncoder(), decoder: JSONDecoder(), store: userDefaultsStore)

let encodableEntity = CodableEntity(name: "name")

let didSave = try store.save(element: encodableEntity, key: "element1")

let savedEntity = try store.fetch(key: "element1", type: CodableEntity.self)

```




