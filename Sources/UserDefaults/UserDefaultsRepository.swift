//
//  UserDefaultsLayer.swift
//  Watch-WatchOS
//
//  Created by common on 9/4/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

public class UserDefaultsRepository<CodableObject: Codable>: PelicanRepository<CodableObject> {
    
    private var key: String
    private var userDefaultsSession: UserDefaults
    private var jsonDecoder = JSONDecoder()
    private var jsonEncoder = JSONEncoder()
    
    public init(key: String, userDefaultsSession: UserDefaults, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.key = key
        self.userDefaultsSession = userDefaultsSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public override func save(object: CodableObject) -> Bool {
        guard let encodedData = try? jsonEncoder.encode(object) else {
            log.error("📱UserDefaultsLayer📱 - failed to save object")
            return false
        }
        userDefaultsSession.set(encodedData, forKey: key)
        return userDefaultsSession.synchronize()
    }
    
    public override func delete(object: CodableObject) -> Bool {
        userDefaultsSession.removeObject(forKey: key)
        return userDefaultsSession.object(forKey: key) == nil
    }
    
    public override var fetchAll: [CodableObject] {
        if let object = userDefaultsSession.data(forKey: key),
            let encodedObject = try? jsonDecoder.decode(CodableObject.self, from: object) {
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
