//
//  KeychainLayer.swift
//  Watch-iOS
//
//  Created by common on 9/12/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

public class KeychainRepository<CodableObject: Codable>: PelicanRepository<CodableObject> {
    
    private var keychainWrapper: KeychainWrapper
    private var key: String
    private var jsonDecoder = JSONDecoder()
    private var jsonEncoder = JSONEncoder()
    
    public init(keychainWrapper: KeychainWrapper, key: String, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.keychainWrapper = keychainWrapper
        self.key = key
    }
    
    public override func save(object: CodableObject) -> Bool {
        guard let encodedData = try? jsonEncoder.encode(object) else {
            return false
        }
        return keychainWrapper.save(data: encodedData, key: key)
    }
    
    public override func empty() {
        _ = keychainWrapper.delete(key: key)
    }
    
    public override func update(object: CodableObject) -> Bool {
        guard let encodedData = try? jsonEncoder.encode(object) else {
            return false
        }
        return keychainWrapper.update(data: encodedData, key: key)
    }
    
    override public var fetchAll: [CodableObject] {
        let fetchFromKeychain = keychainWrapper.fetch(key: key)
        if let data = fetchFromKeychain,
            let dataParsed = try? jsonDecoder.decode(CodableObject.self, from: data) {
            return [dataParsed]
        } else {
            return []
        }
    }
    
    public override func delete(object: CodableObject) -> Bool {
        return keychainWrapper.delete(key: key)
    }
}
