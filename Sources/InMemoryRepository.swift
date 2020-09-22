//
//  InMemoryRepository.swift
//  Pelican
//
//  Created by Daniel Koster on 9/22/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import Foundation

public class InMemoryRepository<PersistibleObject: Equatable>: PelicanRepository<PersistibleObject> {
    private var objects: [PersistibleObject] = []
    
    public override init() {}
    
    public override func save(object: PersistibleObject) -> Bool {
        objects.append(object)
        return true
    }
    
    public override func delete(object: PersistibleObject) -> Bool {
        objects.removeAll { $0 == object }
        return true
    }
    
    public override func update(object: PersistibleObject) -> Bool {
        return delete(object: object) && save(object: object)
    }
    
    public override func empty() {
        objects.removeAll()
    }
    
    public override var fetchAll: [PersistibleObject] {
        return objects
    }
    
}
