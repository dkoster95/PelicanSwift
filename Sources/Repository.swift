import Foundation

public protocol Repository {
    associatedtype Element: Equatable
    func save(element: Element) throws -> Element
    func update(element: Element) throws -> Element
    func delete(element: Element)
    func filter(query: (Element) -> Bool) -> [Element]
    func first(where: (Element) -> Bool) -> Element?
    var first: Element? { get }
    func contains(condition: (Element) -> Bool) -> Bool
    func contains(element: Element) -> Bool
    var isEmpty: Bool { get }
    var getAll: [Element] { get }
    func empty()
}
