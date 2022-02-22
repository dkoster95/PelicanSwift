//
//  UserDefaultsLayer.swift
//  Watch-WatchOS
//
//  Created by common on 9/4/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

public class KeyValueRepository<CodableObject: Codable>: PelicanRepository<CodableObject> {
    
    private var key: String
    private var store: KeyValueStore
    private var jsonDecoder = JSONDecoder()
    private var jsonEncoder = JSONEncoder()
    
    public init(key: String,
                store: KeyValueStore,
                jsonEncoder: JSONEncoder = JSONEncoder(),
                jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.key = key
        self.store = store
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public override func save(object: CodableObject) -> Bool {
        guard let encodedData = try? jsonEncoder.encode(object) else {
            log.error("Store - failed to save object")
            return false
        }
        return store.save(data: encodedData, key: key)
    }
    
    public override func delete(object: CodableObject) -> Bool {
        return store.delete(key: key)
    }
    
    public override func update(object: CodableObject) -> Bool {
        guard let encodedData = try? jsonEncoder.encode(object) else {
            log.error("Store - failed to save object")
            return false
        }
        return store.update(data: encodedData, key: key)
    }
    
    public override var fetchAll: [CodableObject] {
        if let object = store.fetch(key: key),
            let encodedObject = try? jsonDecoder.decode(CodableObject.self, from: object) {
            return [encodedObject]
        }
        log.debug("Store - no results")
        return []
    }
    
    public override func empty() {
        log.debug("Store - deleting results")
        _ = store.delete(key: key)
    }
    
}
