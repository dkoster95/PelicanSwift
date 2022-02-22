//
//  KeychainWrapper.swift
//  Watch-iOS
//
//  Created by common on 9/13/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

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
    private let securityClass: CFString
    
    public init() {
        self.init(service: Bundle.main.bundleIdentifier ?? "",
                  groupId: nil,
                  accesibility: .afterFirstUnlock,
                  securityClass: kSecClassGenericPassword)
    }
    
    public init(service: String? = Bundle.main.bundleIdentifier,
                groupId: String? = nil,
                accesibility: KeychainAccesibility,
                securityClass: CFString) {
        self.service = service ?? ""
        self.groupId = groupId
        self.accesibility = accesibility
        self.securityClass = securityClass
    }
    
    public func save(data: Data, key: String) -> Bool {
        var queryAdd = keychainQueryDictionary(key: key)
        queryAdd[KeychainKeys.SecValueData] = data
        let resultCode = SecItemAdd(queryAdd as CFDictionary, nil)
        if resultCode != noErr {
            log.error("🔐KeychainWrapper🔐 - Error saving to Keychain: \(resultCode)")
            if resultCode == errSecDuplicateItem {
                log.debug("🔐KeychainWrapper🔐 - Updating Item")
                return update(data: data, key: key)
            }
            return false
        }
        log.debug("🔐KeychainWrapper🔐 - Saved Item")
        return true
    }
    
    public func update(data: Data, key: String) -> Bool {
        let queryAdd = keychainQueryDictionary(key: key)
        let updateDictionary = [KeychainKeys.SecValueData: data]
        let resultCode = SecItemUpdate(queryAdd as CFDictionary, updateDictionary as CFDictionary)
        if resultCode != noErr {
            log.error("🔐KeychainWrapper🔐 - Error saving to Keychain: \(resultCode)")
            return false
        }
        log.debug("🔐KeychainWrapper🔐 - Item Updated")
        return true
    }
    
    public func delete(key: String) -> Bool {
        let queryDelete = keychainQueryDictionary(key: key)
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        if resultCodeDelete != noErr {
            log.error("🔐KeychainWrapper🔐 - Error deleting from Keychain: \(resultCodeDelete)")
            return false
        }
        log.debug("🔐KeychainWrapper🔐 - Item Deleted")
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
            log.error("🔐KeychainWrapper🔐 - Error loading from Keychain: \(resultCodeLoad)")
        }
        return nil
    }
    
    private func keychainQueryDictionary(key: String) -> [String: Any] {
        guard let key = key.data(using: .utf8) else { return [:] }
        var dictionary: [String: Any] = [
            KeychainKeys.SecClass: securityClass,
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
