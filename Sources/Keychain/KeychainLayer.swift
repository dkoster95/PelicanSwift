//
//  KeychainLayer.swift
//  Watch-iOS
//
//  Created by common on 9/12/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

public class KeychainLayer<T: Codable>: PersistenceLayer<T> {
    
    private var keychainWrapper: KeychainWrapper
    private var key: String
    
    public init(keychainWrapper: KeychainWrapper, key: String) {
        self.keychainWrapper = keychainWrapper
        self.key = key
    }
    
    public override func save(object: T) -> Bool {
        guard let encodedData = try? JSONEncoder().encode(object) else {
            return false
        }
        return keychainWrapper.save(data: encodedData, key: key)
    }
    
    public override func empty() {
        _ = keychainWrapper.delete(key: key)
    }
    
    public override func retrieve(query: ((T) -> Bool)?, completionHandler: (Result<[T],Error>) -> Void) {
        let fetchFromKeychain = keychainWrapper.fetch(key: key)
        if let data = fetchFromKeychain,
            let dataParsed = try? JSONDecoder().decode(T.self, from: data) {
            if let filter = query, filter(dataParsed) {
                completionHandler(.success([dataParsed]))
            } else {
                completionHandler(.failure(PersistenceLayerError.nonExistingData))
            }
        } else {
            completionHandler(.failure(PersistenceLayerError.nonExistingData))
        }
    }
    
    override public var fetchAll: [T] {
        let fetchFromKeychain = keychainWrapper.fetch(key: key)
        if let data = fetchFromKeychain,
            let dataParsed = try? JSONDecoder().decode(T.self, from: data) {
            return [dataParsed]
        } else {
            return []
        }
    }
    
    public override func retrieveFirst(query: ((T) -> Bool)?, completionHandler: (Result<T, Error>) -> Void) {
        let fetchFromKeychain = keychainWrapper.fetch(key: key)
        if let data = fetchFromKeychain,
            let dataParsed = try? JSONDecoder().decode(T.self, from: data) {
            if let filter = query, filter(dataParsed) {
                completionHandler(.success(dataParsed))
            } else {
                completionHandler(.success(dataParsed))
            }
        } else {
            completionHandler(.failure(PersistenceLayerError.nonExistingData))
        }
    }
    
    public override func delete(object: T) -> Bool {
        return keychainWrapper.delete(key: key)
    }
}
