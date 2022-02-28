import Foundation

public protocol KeyValueStore {
    subscript(key: String) -> Data? { get set }
    func save(data: Data, key: String) -> Bool
    func update(data: Data, key: String) -> Bool
    func delete(key: String) -> Bool
    func fetch(key: String) -> Data?
}

public extension KeyValueStore {
    subscript(key: String) -> Data? {
        get {
            fetch(key: key)
        }
        set {
            if let value = newValue {
                _ = save(data: value, key: key)
            } else {
                _ = delete(key: key)
            }
        }
    }
}
