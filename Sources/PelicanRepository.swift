//
//  PersistenceLayer.swift
//  Watch-WatchOS
//
//  Created by common on 9/4/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

open class PelicanRepository <PersistibleObject: Any> {
    
    open func empty() {}
    
    open var isEmpty: Bool { return fetchAll.isEmpty }
    
    public init() {}
    
    open var fetchAll: [PersistibleObject] {
        return []
    }
    
    @discardableResult
    open func save(object: PersistibleObject) -> Bool { return true }
    
    @discardableResult
    open func save() -> Bool { return true }
    
    open func filter(query: (PersistibleObject) -> Bool) -> [PersistibleObject] { return fetchAll.filter { query($0) }
    }
    
    @discardableResult
    open func delete(object: PersistibleObject) -> Bool { return true }
    
    open var first: PersistibleObject? {
        return fetchAll.first
    }
}
