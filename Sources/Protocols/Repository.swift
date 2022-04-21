import Foundation
import Combine


public protocol Repository {
    associatedtype Element: Equatable
    func add(element: Element) throws -> Element
    func update(element: Element) throws -> Element
    func delete(element: Element)
    func filter(query: (Element) -> Bool) -> [Element]
    func first(where: (Element) -> Bool) -> Element?
    func contains(condition: (Element) -> Bool) -> Bool
    func contains(element: Element) -> Bool
    var isEmpty: Bool { get }
    var getAll: [Element] { get }
    func deleteAll() throws
}

public protocol AsyncRepository {
    associatedtype Element: Equatable
    func add<AddTransaction: AsyncTransaction>(element: Element) -> AddTransaction where AddTransaction.Result == Element
    func update<UpdateTransaction: AsyncTransaction>(element: Element) -> UpdateTransaction where UpdateTransaction.Result == Element
    func delete<DeleteTransaction: AsyncTransaction>(element: Element) -> DeleteTransaction where DeleteTransaction.Result == Void
    func find<FindTransaction: AsyncTransaction>(where: ((Element) -> Bool)?) -> FindTransaction where FindTransaction.Result == [Element]
    func first<FindTransaction: AsyncTransaction>(where: ((Element) -> Bool)?) -> FindTransaction where FindTransaction.Result == Element?
}
