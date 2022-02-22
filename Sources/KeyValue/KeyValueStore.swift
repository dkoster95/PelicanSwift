

import Foundation

public protocol KeyValueStore {
    func save(data: Data, key: String) -> Bool
    func update(data: Data, key: String) -> Bool
    func delete(key: String) -> Bool
    func fetch(key: String) -> Data?
}
