import Foundation
import PelicanProtocols

public struct ObjectKeyValueStore: CodableKeyValueStore {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let store: KeyValueStore
    
    public init(encoder: JSONEncoder, decoder: JSONDecoder, store: KeyValueStore) {
        self.encoder = encoder
        self.decoder = decoder
        self.store = store
    }
    
    public func save<Element>(element: Element, key: String) throws -> Bool where Element : Encodable {
        guard let encodedElement = try? encoder.encode(element) else { throw RepositoryError.serializationError }
        return store.save(data: encodedElement, key: key)
    }
    
    public func update<Element>(element: Element, key: String) throws -> Bool where Element : Encodable {
        guard let encodedElement = try? encoder.encode(element) else { throw RepositoryError.serializationError }
        return store.update(data: encodedElement, key: key)
    }
    
    public func delete(key: String) -> Bool {
        return store.delete(key: key)
    }
    
    public func fetch<Element>(key: String, type: Element.Type) throws -> Element? where Element : Decodable {
        guard let fetchedData = store.fetch(key: key) else { return nil }
        guard let decodedElement = try? decoder.decode(Element.self, from: fetchedData) else { throw RepositoryError.serializationError }
        return decodedElement
    }
}
