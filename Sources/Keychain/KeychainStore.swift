import Foundation
import PelicanProtocols

private extension KeychainAccesibility {
    var parseValue: CFString {
        switch self {
        case .whenUnlocked: return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock: return kSecAttrAccessibleAfterFirstUnlock
        case .whenPasscodeSetThisDeviceOnly: return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlockedThisDeviceOnly: return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly: return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
    }
}

public struct KeychainStore: KeyValueStore {
    private let service: String
    private let groupId: String?
    private let accesibility: KeychainAccesibility
    private let securityClass: KeychainSecurityClass
    private let logger: Logger
    
    public init(logger: Logger) {
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
                logger: Logger) {
        self.service = service ?? ""
        self.groupId = groupId
        self.accesibility = accesibility
        self.securityClass = securityClass
        self.logger = logger
    }
    
    public func save(data: Data, key: String) -> Bool {
        var queryAdd = keychainQueryDictionary(key: key)
        queryAdd[KeychainKeys.SecValueData] = data
        let resultCode = SecItemAdd(queryAdd as CFDictionary, nil)
        if resultCode != noErr {
            logger.error("🔐 KeychainStore 🔐 - Error saving to Keychain: \(resultCode)")
            if resultCode == errSecDuplicateItem {
                logger.debug("🔐 KeychainStore 🔐 - Updating Item")
                return update(data: data, key: key)
            }
            return false
        }
        logger.debug("🔐 KeychainStore 🔐 - Saved Item")
        return true
    }
    
    public func update(data: Data, key: String) -> Bool {
        let queryAdd = keychainQueryDictionary(key: key)
        let updateDictionary = [KeychainKeys.SecValueData: data]
        let resultCode = SecItemUpdate(queryAdd as CFDictionary, updateDictionary as CFDictionary)
        if resultCode != noErr {
            logger.error("🔐 KeychainStore 🔐 - Error saving to Keychain: \(resultCode)")
            return false
        }
        logger.debug("🔐 KeychainStore 🔐 - Item Updated")
        return true
    }
    
    public func delete(key: String) -> Bool {
        let queryDelete = keychainQueryDictionary(key: key)
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        if resultCodeDelete != noErr {
            logger.error("🔐 KeychainStore 🔐 - Error deleting from Keychain: \(resultCodeDelete)")
            return false
        }
        logger.debug("🔐 KeychainStore 🔐 - Item Deleted")
        return true
    }
    
    public func fetch(key: String) -> Data? {
        var queryLoad = keychainQueryDictionary(key: key)
        queryLoad[KeychainKeys.SecReturnData] = kCFBooleanTrue
        queryLoad[KeychainKeys.SecMatchLimit] = kSecMatchLimitOne
        var result: AnyObject?
        
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        if resultCodeLoad == noErr {
            if let result = result as? Data {
                return result
            }
        } else {
            logger.error("🔐 KeychainStore 🔐 - Error loading from Keychain: \(resultCodeLoad)")
        }
        return nil
    }
    
    private func keychainQueryDictionary(key: String) -> [String: Any] {
        guard let key = key.data(using: .utf8) else { return [:] }
        var dictionary: [String: Any] = [
            KeychainKeys.SecClass: securityClass.value,
            KeychainKeys.SecAttrAccount: key,
            KeychainKeys.SecAttrGeneric: key,
            KeychainKeys.SecAttrService: service,
            KeychainKeys.SecAttrAccessible: accesibility.parseValue]
        if let groupId = groupId {
            dictionary[KeychainKeys.SecAttrAccessGroup] = groupId as Any
        }
        return dictionary
    }
    
}
