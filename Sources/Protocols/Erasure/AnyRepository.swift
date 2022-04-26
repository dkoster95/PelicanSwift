//
//  AnyRepository.swift
//  Pelican
//
//  Created by Daniel Koster on 2/26/22.
//  Copyright © 2022 Daniel Koster. All rights reserved.
//

import Foundation

public struct AnyRepository<Entity: Equatable>: Repository {
    public typealias Element = Entity
    
    public init<AnyStorage: Repository> (storage: AnyStorage) where AnyStorage.Element == Entity {
        self.allGenerator = { storage.getAll }
        self.addClosure = storage.add
        self.updateClosure = storage.update
        self.deleteClosure = storage.delete
        self.filterClosure = storage.filter
        self.firstClosure = storage.first
        self.containsClosure = storage.contains
        self.containsElement = { element in storage.contains(element: element) }
        self.isEmptyClosure = { storage.isEmpty }
        self.deleteAllClosure = storage.deleteAll
    }
    
    private let allGenerator: () -> [Entity]
    public var getAll: [Element] { allGenerator() }
    
    private let addClosure: (Entity) throws -> Entity
    public func add(element: Entity) throws -> Entity {
        return try addClosure(element)
    }
    
    private let updateClosure: (Entity) throws -> Entity
    public func update(element: Entity) throws -> Entity {
        return try updateClosure(element)
    }
    
    private let deleteClosure: (Entity) throws -> Void
    public func delete(element: Entity) throws {
        try deleteClosure(element)
    }
    
    private let filterClosure: ((Entity) -> Bool) -> [Entity]
    public func filter(query: (Entity) -> Bool) -> [Entity] {
        return filterClosure(query)
    }
    
    private let firstClosure: (@escaping (Entity) -> Bool) -> Entity?
    public func first(where: @escaping (Entity) -> Bool) -> Entity? {
        return firstClosure(`where`)
    }
    
    private let containsClosure: ((Entity) -> Bool) -> Bool
    public func contains(condition: (Entity) -> Bool) -> Bool {
        return containsClosure(condition)
    }
    
    private let containsElement: (Entity) -> Bool
    public func contains(element: Entity) -> Bool {
        return containsElement(element)
    }
    
    private let isEmptyClosure: () -> Bool
    public var isEmpty: Bool {
        isEmptyClosure()
    }
    
    private let deleteAllClosure: () throws -> Void
    public func deleteAll() throws {
        try deleteAllClosure()
    }
}

public extension Repository {
    func eraseToAnyRepository() -> AnyRepository<Element> {
        return AnyRepository<Element>(storage: self)
    }
}
