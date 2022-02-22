import Foundation

public struct KeyValueRepository<CodableEntity: Codable & Equatable>: Repository {
    
    public typealias Element = CodableEntity
    private let key: String
    private let store: KeyValueStore
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    public init(key: String,
                store: KeyValueStore,
                jsonEncoder: JSONEncoder = JSONEncoder(),
                jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.key = key
        self.store = store
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public var getAll: [CodableEntity] {
        guard let storeData = store.fetch(key: key) else { return [] }
        if let decodedArray = try? jsonDecoder.decode([CodableEntity].self, from: storeData) {
            return decodedArray
        }
        guard let decodedObject = try? jsonDecoder.decode(CodableEntity.self, from: storeData) else { return [] }
        return [decodedObject]
    }
    
    public func save(element: CodableEntity) throws -> CodableEntity {
        guard let encodedData = try? jsonEncoder.encode(element) else {
            throw RepositoryError.serializationError
        }
        _ = store.save(data: encodedData, key: key)
        return element
    }
    
    public func update(element: CodableEntity) throws -> CodableEntity {
        guard let encodedData = try? jsonEncoder.encode(element) else {
            throw RepositoryError.serializationError
        }
        guard store.update(data: encodedData, key: key) else { throw RepositoryError.transactionError }
        guard let storeData = store.fetch(key: key),
              let updatedData = try? jsonDecoder.decode(CodableEntity.self, from: storeData) else { throw RepositoryError.nonExistingData }
        return updatedData
    }
    
    public func delete(element: CodableEntity) {
        _ = store.delete(key: key)
    }
    
    public func filter(query: (CodableEntity) -> Bool) -> [CodableEntity] {
        guard let storeData = store.fetch(key: key) else { return [] }
        guard let decodedData = try? jsonDecoder.decode([CodableEntity].self, from: storeData) else { return [] }
        return decodedData.filter(query)
    }
    
    public func first(where: (CodableEntity) -> Bool) -> CodableEntity? {
        guard let storeData = store.fetch(key: key) else { return nil }
        guard let decodedData = try? jsonDecoder.decode([CodableEntity].self, from: storeData) else { return nil }
        return decodedData.first(where: `where`)
    }
    
    public var first: CodableEntity? {
        guard let storeData = store.fetch(key: key) else { return nil }
        if let decodedArrayData = try? jsonDecoder.decode([CodableEntity].self, from: storeData) {
            return decodedArrayData.first
        }
        if let decodedData = try? jsonDecoder.decode(CodableEntity.self, from: storeData) {
            return decodedData
        }
        return nil
    }
    
    public func contains(condition: (CodableEntity) -> Bool) -> Bool {
        guard let storeData = store.fetch(key: key) else { return false }
        if let decodedArrayData = try? jsonDecoder.decode([CodableEntity].self, from: storeData) {
            return decodedArrayData.contains(where: condition)
        }
        if let decodedData = try? jsonDecoder.decode(CodableEntity.self, from: storeData) {
            return condition(decodedData)
        }
        return false
    }
    
    public func contains(element: CodableEntity) -> Bool {
        guard let storeData = store.fetch(key: key) else { return false }
        if let decodedArrayData = try? jsonDecoder.decode([CodableEntity].self, from: storeData) {
            return decodedArrayData.contains(element)
        }
        if let decodedData = try? jsonDecoder.decode(CodableEntity.self, from: storeData) {
            return element == decodedData
        }
        return false
    }
    
    public var isEmpty: Bool {
        return store.fetch(key: key) != nil
    }
    
    public func empty() {
        _ = store.delete(key: key)
    }
}
