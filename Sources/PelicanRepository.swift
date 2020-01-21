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
    
    public init() {}
    
    open var fetchAll: [PersistibleObject] {
        return []
    }
    
    @discardableResult
    open func save(object: PersistibleObject) -> Bool { return true }
    
    @discardableResult
    open func save() -> Bool { return true }
    
    @discardableResult
    open func delete(object: PersistibleObject) -> Bool { return true }
    
    open func retrieve(query: ((PersistibleObject) -> Bool)? = nil, completionHandler: (Result<[PersistibleObject], Error>) -> Void) {}
    
    open func retrieveFirst(query: ((PersistibleObject) -> Bool)? = nil, completionHandler: (Result<PersistibleObject, Error>) -> Void) {}
}
