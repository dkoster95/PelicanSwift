//
//  PersistenceLayerError.swift
//  Watch-WatchOS
//
//  Created by common on 9/4/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

public enum PersistenceLayerError: Error {
    case nonExistingData
    case serializationError
}
