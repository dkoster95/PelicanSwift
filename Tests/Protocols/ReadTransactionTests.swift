//
//  ReadTransactionTests.swift
//  Pelican
//
//  Created by Daniel Koster on 12/29/25.
//

import PelicanProtocols
import Testing
import Foundation

struct ReadTransactionTests {
    
    @Test
    func findAsync_expectRepositoryToReturn() async throws {
        let repositoryMock = ReadableRepositoryMock<DataModel>()
        let sut = ReadElementTransaction<DataModel>(repository: repositoryMock) { $0.name == "name" }
        repositoryMock.findResult = [DataModel(name: "name", age: 2)]
        
        let result = try await sut.execute()
        
        #expect(result.count > 0)
        #expect(repositoryMock.findCount == 1)
    }
    
    @Test
    func find_expectRepositoryToReturn() throws {
        let repositoryMock = ReadableRepositoryMock<DataModel>()
        let sut = ReadElementTransaction<DataModel>(repository: repositoryMock) { $0.name == "name" }
        repositoryMock.findResult = [DataModel(name: "name", age: 2)]
        
        let result = try sut.execute()
        
        #expect(result.count > 0)
        #expect(repositoryMock.findCount == 1)
    }
    
    @Test
    func findPredicate_expectRepositoryToReturn() throws {
        let repositoryMock = PredicateReadableRepositoryMock<DataModel>()
        let sut = ReadPredicateElementTransaction(repository: repositoryMock, query: NSPredicate(format: "name = %@", "name"))
        repositoryMock.findResult = [DataModel(name: "name", age: 2)]
        
        let result = try sut.execute()
        
        #expect(result.count > 0)
        #expect(repositoryMock.findCount == 1)
    }
    
    @Test
    func findPredicateAsync_expectRepositoryToReturn() async throws {
        let repositoryMock = PredicateReadableRepositoryMock<DataModel>()
        let sut = ReadPredicateElementTransaction(repository: repositoryMock, query: NSPredicate(format: "name = %@", "name"))
        repositoryMock.asyncFindResult = [DataModel(name: "name", age: 2)]
        
        let result = try await sut.execute()
        
        #expect(result.count > 0)
        #expect(repositoryMock.asyncFindCount == 1)
    }
}
