//
//  SwiftDataRepositoryTests.swift
//  Pelican
//
//  Created by Daniel Koster on 2/15/26.
//
import Foundation
import SwiftData
import PelicanRepositories
import PelicanProtocols
import Testing

struct SwiftDataRepositoryTests {
    
    @Test func test_add_expectElementAdded() async throws {
        let (sut, _) = try makeSUT()
        let objectToInsert = TestEntityV2(id: UUID(), name: "some name", createdAt: Date())
        
        let _ = try await sut.add(element: objectToInsert)
        let result = await sut.find()
        
        #expect(result.count == 1)
        #expect(result[0] == objectToInsert)
    }
    
    @Test func test_add_whenElementRepeatedExpectNoElementAddedAndNoErrorThrown() async throws {
        let (sut, _) = try makeSUT()
        let objectToInsert = TestEntityV2(id: UUID(), name: "some name", createdAt: Date())
        
        let _ = try await sut.add(element: objectToInsert)
        let _ = try await sut.add(element: objectToInsert)
        let result = await sut.find()
        
        print(result)
        #expect(result.count == 1)
        #expect(result[0] == objectToInsert)
    }
    
    @Test func test_contains_whenElementExist_expectTrue() async throws {
        let (sut, _) = try makeSUT()
        let objectToInsert = TestEntityV2(id: UUID(), name: "some name", createdAt: Date())
        
        let _ = try await sut.add(element: objectToInsert)
        let result = await sut.contains(element: objectToInsert)
        
        #expect(result == true)
    }
    
    func makeSUT() throws -> (SwiftDataRepository<TestEntityV2>, ModelContainer) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TestSwiftDataEntity.self, configurations: config)
        let sut = SwiftDataRepository<TestEntityV2>(modelContainer: container)
        return (sut, container)
    }
}

struct TestEntityV2: Equatable {
    let id: UUID
    let name: String
    let createdAt: Date
}

extension TestEntityV2: PersistenModelConvertible {
    init(from: TestSwiftDataEntity) {
        id = from.id
        name = from.name
        createdAt = from.createdAt
    }
    
    func asEntity() -> TestSwiftDataEntity {
        TestSwiftDataEntity(id: id, name: name, createdAt: createdAt)
    }
    
    func merge(into: TestSwiftDataEntity) {
        into.name = name
    }
    
    typealias SwiftDataEntity = TestSwiftDataEntity
    
    
}

@Model
final class TestSwiftDataEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    
    init(id: UUID,
         name: String,
         createdAt: Date) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
    
}
