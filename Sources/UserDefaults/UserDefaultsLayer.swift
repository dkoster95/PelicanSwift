//
//  UserDefaultsLayer.swift
//  Watch-WatchOS
//
//  Created by common on 9/4/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

public class UserDefaultsLayer<T: Codable>: PersistenceLayer<T> {
    
    private var key: String
    private var userDefaultsSession: UserDefaults
    
    public init(key: String, userDefaultsSession: UserDefaults) {
        self.key = key
        self.userDefaultsSession = userDefaultsSession
    }
    
    public override func save(object: T) -> Bool {
        guard let encodedData = try? JSONEncoder().encode(object) else {
            log.error("📱UserDefaultsLayer📱 - failed to save object")
            return false
        }
        userDefaultsSession.set(encodedData, forKey: key)
        return userDefaultsSession.synchronize()
    }
    
    public override func delete(object: T) -> Bool {
        userDefaultsSession.removeObject(forKey: key)
        return userDefaultsSession.object(forKey: key) == nil
    }
    
    public override func retrieveFirst(query: ((T) -> Bool)?, completionHandler: (Result<T, Error>) -> Void) {
        if let object = userDefaultsSession.data(forKey: key),
            let encodedObject = try? JSONDecoder().decode(T.self, from: object) {
            completionHandler(.success(encodedObject))
            return
        }
        log.error("📱UserDefaultsLayer📱 - failed to retrieve object")
        completionHandler(.failure(PersistenceLayerError.nonExistingData))
    }
    
    public override var fetchAll: [T] {
        if let object = userDefaultsSession.data(forKey: key),
            let encodedObject = try? JSONDecoder().decode(T.self, from: object) {
            return [encodedObject]
        }
        log.debug("📱UserDefaultsLayer📱 - no results")
        return []
    }
    
    public override func empty() {
        log.debug("📱UserDefaultsLayer📱 - deleting results")
        userDefaultsSession.removeObject(forKey: key)
    }
    
}
