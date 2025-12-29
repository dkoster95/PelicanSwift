//
//  ReadTransactions.swift
//  Pelican
//
//  Created by Daniel Koster on 12/29/25.
//
import Foundation

public struct ReadPredicateElementTransaction<Element: Equatable & Sendable>: Transaction {
    public typealias Result = [Element]
    private let repository: any PredicateReadableRepository<Element>
    private let query: NSPredicate
    private let limit: Int?
    private let sort: NSSortDescriptor?
    
    public init(repository: any PredicateReadableRepository<Element>,
                query: NSPredicate,
                limit: Int? = nil,
                sort: NSSortDescriptor? = nil) {
        self.repository = repository
        self.query = query
        self.limit = limit
        self.sort = sort
    }
    
    public var publisher: TransactionPublisher<[Element]> {
        TransactionPublisher {
            repository.find(predicate: query, limit: limit, sortDescriptor: sort)
        }
    }
    
    public func execute() throws -> [Element] {
        return repository.find(predicate: query, limit: limit, sortDescriptor: sort)
    }
    
    public func execute() async throws -> [Element] {
        return await repository.find(predicate: query, limit: limit, sortDescriptor: sort)
    }
}

public struct ReadElementTransaction<Element: Equatable & Sendable>: Transaction {
    public typealias Result = [Element]
    private let repository: any ReadableRepository<Element>
    private let query: ((Element) -> Bool)?
    
    public init(repository: any ReadableRepository<Element>,
                query: ( (Element) -> Bool)?) {
        self.repository = repository
        self.query = query
    }
    
    public var publisher: TransactionPublisher<[Element]> {
        TransactionPublisher {
            repository.find(query: query)
        }
    }
    
    public func execute() throws -> [Element] {
        return repository.find(query: query)
    }
    
    public func execute() async throws -> [Element] {
        return await repository.find(query: query)
    }
}
