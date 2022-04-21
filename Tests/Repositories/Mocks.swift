import Foundation
import PelicanProtocols

struct MockEntity: Codable, Equatable {
    let parameter: String
    let number: Double
}
func == (lhs: MockEntity, rhs: MockEntity) -> Bool {
    return lhs.parameter == rhs.parameter && lhs.number == rhs.number
}

class MockStore: KeyValueStore {
    
    var didSave = false
    func save(data: Data, key: String) -> Bool {
        didSave = true
        return didSave
    }
    var didUpdate = false
    func update(data: Data, key: String) -> Bool {
        didUpdate = true
        return didUpdate
    }
    
    var didDelete = false
    func delete(key: String) -> Bool {
        didDelete = true
        return didDelete
    }
    
    var didFetch = false
    var data: Data?
    func fetch(key: String) -> Data? {
        didFetch = true
        return data
    }
}
