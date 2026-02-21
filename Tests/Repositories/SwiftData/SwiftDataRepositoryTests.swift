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
    
    @Test func test_update_whenElementFound_expectUpdateCorrect() async throws {
        let (sut, _) = try makeSUT()
        let objectToInsert = TestEntityV2(id: UUID(), name: "some name", createdAt: Date())
        _ = try await sut.add(element: objectToInsert)
        let objectToUpdate = TestEntityV2(id: objectToInsert.id, name: "updated Name", createdAt: Date())
        
        _ = try await sut.update(element: objectToUpdate)
        let find = await sut.find()
        
        #expect(find[0].name == "updated Name")
    }
    
    @Test func test_delete_whenElementFound_expectUpdateCorrect() async throws {
        let (sut, _) = try makeSUT()
        let objectToInsert = TestEntityV2(id: UUID(), name: "some name", createdAt: Date())
        _ = try await sut.add(element: objectToInsert)
        
        try await sut.delete(element: objectToInsert)
        let find = await sut.find()
        
        #expect(find.isEmpty)
    }
    
    @Test func test_deleteAll_expectNoValues() async throws {
        let (sut, _) = try makeSUT()
        let objectToInsert = TestEntityV2(id: UUID(), name: "some name", createdAt: Date())
        let objectToInsert2 = TestEntityV2(id: UUID(), name: "some name 2", createdAt: Date())
        _ = try await sut.add(element: objectToInsert)
        _ = try await sut.add(element: objectToInsert2)
        
        try await sut.deleteAll()
        let find = await sut.find()
        
        #expect(find.isEmpty)
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
    var identifiablePredicate: Predicate<TestSwiftDataEntity> {
        let uuid = self.id
        return #Predicate { element in
            element.uuid == uuid
        }
    }
    
    init(from: TestSwiftDataEntity) {
        id = from.uuid
        name = from.name
        createdAt = from.createdAt
    }
    
    func asEntity() -> TestSwiftDataEntity {
        TestSwiftDataEntity(uuid: id, name: name, createdAt: createdAt)
    }
    
    func merge(into: TestSwiftDataEntity) {
        into.name = name
    }
    
    typealias SwiftDataEntity = TestSwiftDataEntity
    
    
}

@Model
final class TestSwiftDataEntity {
    @Attribute(.unique) var uuid: UUID
    var name: String
    var createdAt: Date
    
    init(uuid: UUID,
         name: String,
         createdAt: Date) {
        self.uuid = uuid
        self.name = name
        self.createdAt = createdAt
    }
    
}
