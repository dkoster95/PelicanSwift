
## UserDefaults Repository
---
Pelican provides a UserDefaults repository to handle your UserDefaults data flow.
Keep in mind what the purpose of User Defaults is, store user preferences (dummy preferences) dont store important data of your app in user Defaults.

And now Lets check out the UserDefaultsRepository implementation

```swift
public class UserDefaultsRepository<CodableObject: Codable>: PelicanRepository<CodableObject> {
    public init(key: String, userDefaultsSession: UserDefaults, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder())

    public override func save(object: CodableObject) -> Bool
    public override func empty()
    public override func retrieve(query: ((CodableObject) -> Bool)?, completionHandler: (Result<[CodableObject],Error>) -> Void)
    override public var fetchAll: [CodableObject]
    public override func retrieveFirst(query: ((CodableObject) -> Bool)?, completionHandler: (Result<CodableObject, Error>) -> Void)
    public override func delete(object: CodableObject) -> Bool
}
```
The repository uses the UserDefaults Swift class. Doc (https://developer.apple.com/documentation/foundation/userdefaults)
In order to use this repository you need a class that conforms to Codable protocol.  
You can also inject the JSONDecoder and Encoder, the class uses the default ones.

