//
//  KeychainAccesibility.swift
//  PersistenceLayer
//
//  Created by Daniel Koster on 6/3/19.
//  Copyright © 2019 Daniel Koster. All rights reserved.
//

import Foundation

public enum KeychainAccesibility {
    case whenUnlocked
    case afterFirstUnlock
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
}

public enum KeychainSecurityClass {
    case internetPassword
    case genericPassword
    case certificate
    case key
    case identity
    
    var value: CFString {
        switch self {
        case .internetPassword: return kSecClassInternetPassword
        case .genericPassword: return kSecClassGenericPassword
        case .certificate: return kSecClassCertificate
        case .key: return kSecClassKey
        case .identity: return kSecClassIdentity
        }
    }
}
