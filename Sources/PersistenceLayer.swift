//
//  PersistenceLayer.swift
//  Watch-WatchOS
//
//  Created by common on 9/4/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import Foundation

open class PersistenceLayer <T: Any> {
    
    open func empty() {}
    
    public init() {}
    
    open var fetchAll: [T] {
        return []
    }
    
    @discardableResult
    open func save(object: T) -> Bool { return true }
    
    @discardableResult
    open func save() -> Bool { return true }
    
    @discardableResult
    open func delete(object: T) -> Bool { return true }
    
    open func retrieve(query: ((T) -> Bool)? = nil, completionHandler: (Result<[T], Error>) -> Void) {}
    
    open func retrieveFirst(query: ((T) -> Bool)? = nil, completionHandler: (Result<T, Error>) -> Void) {}
}
