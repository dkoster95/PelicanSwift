
## Keychain Repository

Pelican provides a Keychain repository to handle your keychain data flow and also a **Keychain Wrapper** to handle Keychain direct interaction.

First of all you have to set the accesibility to Keychain.
```swift
public enum KeychainAccesibility {
    case whenUnlocked
    case afterFirstUnlock
    case always
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case alwaysThisDeviceOnly
}
```

those are all the posible alternatives, the one recommended and set by default is **afterFirstUnlock**
Here Apple Doc: (https://developer.apple.com/documentation/security/keychain_services/keychain_items/restricting_keychain_item_accessibility)
OWASP TOP 10 DOC: https://owasp.org/www-project-mobile-top-10/2016-risks/m1-improper-platform-usage

KeychainWrapper is easy to understand you initialize it with the accesibility shown before and in case you use an app group you use the appGroup ID.  
You can also use the default value which is the one initialized with afterFirstUnlock as Accesibility.
```swift
open class KeychainWrapper {

    public static let `default` = KeychainWrapper()
    public init(service: String? = Bundle.main.bundleIdentifier, groupId: String? = nil, accesibility: KeychainAccesibility)
    //Keychain Operations
    public func save(data: Data, key: String) -> Bool
    public func update(data: Data, key: String) -> Bool
    public func delete(key: String) -> Bool
    public func fetch(key: String) -> Data?
}
```

And now Lets check out the KeychainRepository implementation

```swift
public class KeychainRepository<CodableObject: Codable>: PelicanRepository<CodableObject> {
    public init(keychainWrapper: KeychainWrapper, key: String, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) 

    public override func save(object: CodableObject) -> Bool
    public override func empty()
    public override func retrieve(query: ((CodableObject) -> Bool)?, completionHandler: (Result<[CodableObject],Error>) -> Void)
    override public var fetchAll: [CodableObject]
    public override func retrieveFirst(query: ((CodableObject) -> Bool)?, completionHandler: (Result<CodableObject, Error>) -> Void)
    public override func delete(object: CodableObject) -> Bool
}
```

As you can see the repository uses internally a **KeychainWrapper** as you would expect and the other important thing is that in order to use this repository you need a class that conforms to Codable protocol.  
You can also inject the JSONDecoder and Encoder, the class uses the default ones.

