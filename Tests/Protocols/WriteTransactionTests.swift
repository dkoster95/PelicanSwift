//
//  WriteTransactionTests.swift
//  Pelican
//
//  Created by Daniel Koster on 12/23/25.
//

import PelicanProtocols
import Testing
import Foundation

struct WriteTransactionTests {
    
    @Test
    func executeAsync() async throws {
        let (sut, repository) = addTransactionSut(dataModel: DataModel(name: "name", age: 21))
        
        let result = try await sut.execute()
        
        #expect(DataModel(name: "name", age: 21) == result)
        #expect(repository.addAsyncCount == 1)
    }
    
    @Test
    func execute() throws {
        let (sut, repository) = addTransactionSut(dataModel: DataModel(name: "name", age: 21))
        
        let result = try sut.execute()
        
        #expect(DataModel(name: "name", age: 21) == result)
        #expect(repository.addCount == 1)
    }
    
    @Test
    func updatExecuteAsync() async throws {
        let (sut, repository) = updateTransactionSut(dataModel: DataModel(name: "name", age: 21))
        
        let result = try await sut.execute()
        
        #expect(DataModel(name: "name", age: 21) == result)
        #expect(repository.updateAsyncCount == 1)
    }
    
    @Test
    func updateExecute() throws {
        let (sut, repository) = updateTransactionSut(dataModel: DataModel(name: "name", age: 21))
        
        let result = try sut.execute()
        
        #expect(DataModel(name: "name", age: 21) == result)
        #expect(repository.updateCount == 1)
    }
    
    private func addTransactionSut(dataModel: DataModel) -> (WriteElementTransaction<DataModel>,
                                                             InsertableRepositoryMock<DataModel>) {
        let repository = InsertableRepositoryMock<DataModel>()
        repository.addReturn = dataModel
        repository.addAsyncReturn = dataModel
        return (WriteElementTransaction(repository: repository, element: dataModel), repository)
    }
    
    private func updateTransactionSut(dataModel: DataModel) -> (WriteElementTransaction<DataModel>,
                                                                UpdatableRepositoryMock<DataModel>) {
        let repository = UpdatableRepositoryMock<DataModel>()
        repository.updateReturn = dataModel
        repository.updateAsyncReturn = dataModel
        return (WriteElementTransaction(repository: repository, element: dataModel), repository)
    }
}

struct DataModel: Equatable {
    let name: String
    let age: Int
}

class PredicateReadableRepositoryMock<Element: Equatable & Sendable>: PredicateReadableRepository {
    
    private(set) var asyncFindCount = 0
    var asyncFindResult: [Element] = []
    func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) async -> [Element] {
        asyncFindCount += 1
        return asyncFindResult
    }
    
    private(set) var findCount = 0
    var findResult: [Element] = []
    func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) -> [Element] {
        findCount += 1
        return findResult
    }
    
    
}
class ReadableRepositoryMock<T:Equatable & Sendable>: ReadableRepository {
    
    private(set) var findCount = 0
    var findResult: [T] = []
    func find(query: ((T) -> Bool)?) -> [T] {
        findCount += 1
        return findResult
    }
    
    private(set) var containsCount = 0
    var containsResult = false
    func contains(element: T) -> Bool {
        containsCount += 1
        return containsResult
    }
    
    private(set) var asyncContainsCount = 0
    var asyncContainsResult = false
    func contains(element: T) async -> Bool {
        asyncContainsCount += 1
        return asyncContainsResult
    }
    
    typealias Element = T
    
    private(set) var isEmptyCount = 0
    var isEmptyResult = false
    var isEmpty: Bool {
        isEmptyCount += 1
        return isEmptyResult
    }
    
    
}

class InsertableRepositoryMock<T: Equatable & Sendable>: @unchecked Sendable, InsertableRepository {
    
    private(set) var addCount = 0
    var addReturn: T!
    var addError: Error?
    func add(element: T) throws -> T {
        addCount += 1
        if let error = addError { throw error }
        return addReturn
    }
    
    private(set) var addAsyncCount = 0
    var addAsyncError: Error?
    var addAsyncReturn: T!
    func add(element: T) async throws -> T {
        addAsyncCount += 1
        if let error = addAsyncError { throw error }
        return addAsyncReturn
    }
    
    typealias Element = T
}

class UpdatableRepositoryMock<T: Equatable & Sendable>: UpdatableRepository {
    private(set) var updateCount = 0
    var updateReturn: T!
    var updateError: Error?
    func update(element: T) throws -> T {
        updateCount += 1
        if let error = updateError { throw error }
        return updateReturn
    }
    
    private(set) var updateAsyncCount = 0
    var updateAsyncError: Error?
    var updateAsyncReturn: T!
    func update(element: T) async throws -> T {
        updateAsyncCount += 1
        if let error = updateAsyncError { throw error }
        return updateAsyncReturn
    }
    
    typealias Element = T
}
