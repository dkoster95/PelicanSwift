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
    case always
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case alwaysThisDeviceOnly
}
