
## Keychain Store

Pelican provides a Keychain store to handle your keychain data flow.

we have the accesibility and class enums to set configuration properties to Keychain
```swift
public enum KeychainAccesibility {
    case whenUnlocked
    case afterFirstUnlock
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
}
```

```swift
public enum KeychainSecurityClass {
    case internetPassword
    case genericPassword
    case certificate
    case key
    case identity
}
```

those are all the posible alternatives, the one recommended and set by default is **afterFirstUnlock**
Here Apple Doc: (https://developer.apple.com/documentation/security/keychain_services/keychain_items/restricting_keychain_item_accessibility)
OWASP TOP 10 DOC: https://owasp.org/www-project-mobile-top-10/2016-risks/m1-improper-platform-usage
---

The KeychainStore is a conformance of KeyValueStore to have basic CRUD operations and it is really easy to inicialize.
```swift
public struct KeychainStore: KeyValueStore {
    private let service: String
    private let groupId: String?
    private let accesibility: KeychainAccesibility
    private let securityClass: KeychainSecurityClass
    private let logger: Logger?
    
    public init(logger: Logger? = nil) {
        self.init(service: Bundle.main.bundleIdentifier ?? "",
                  groupId: nil,
                  accesibility: .afterFirstUnlock,
                  securityClass: .genericPassword,
                  logger: logger)
    }
    
    public init(service: String? = Bundle.main.bundleIdentifier,
                groupId: String? = nil,
                accesibility: KeychainAccesibility,
                securityClass: KeychainSecurityClass,
                logger: Logger?) {
        self.service = service ?? ""
        self.groupId = groupId
        self.accesibility = accesibility
        self.securityClass = securityClass
        self.logger = logger
    }
```

Given its a KeyValueStore, this Keychain is also compatible with ObjectKeyValueStore to use Codable types.
Sample of use

```swift
    var keychain = KeychainStore(service: "", groupId: nil, accesibility: .afterFirstUnlock, securityClass: .genericPassword, logger: Log())
    let dataToBeSaved: Data = .....
    _ = keychain.save(data: dataToBeSaved, key: "yourKey")
    
    // To Delete
    _ = keychain.delete(key: "yourKey")
```



