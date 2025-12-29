//
//  WrtieTransactions.swift
//  Pelican
//
//  Created by Daniel Koster on 12/22/25.
//
import Foundation

public struct WriteElementTransaction<Element: Equatable & Sendable>: Transaction {
    private let executeHandler: (Element) throws -> Element
    private let executeAsyncHandler: (Element) async throws -> Element
    private let element: Element
    
    public init(executeHandler: @escaping ((Element) throws -> Element),
                executeAsyncHandler: @escaping (Element) async throws -> Element,
                element: Element) {
        self.executeHandler = executeHandler
        self.executeAsyncHandler = executeAsyncHandler
        self.element = element
    }

    public var publisher: TransactionPublisher<Element> {
        TransactionPublisher {
            try executeHandler(element)
        }
    }
    
    public func execute() throws -> Element {
        return try executeHandler(element)
    }
    
    public func execute() async throws -> Element {
        return try await executeAsyncHandler(element)
    }
}

public extension WriteElementTransaction {
    
    init(repository: any InsertableRepository<Element>,
         element: Element) {
        self.init(executeHandler: repository.add,
                  executeAsyncHandler: { try await repository.add(element: $0) },
                  element: element)
    }
    
    init(repository: any UpdatableRepository<Element>,
         element: Element) {
        self.init(executeHandler: repository.update,
                  executeAsyncHandler: { try await repository.update(element: $0) },
                  element: element)
    }
}
