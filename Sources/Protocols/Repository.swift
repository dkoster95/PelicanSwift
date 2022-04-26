import Foundation
import Combine


public protocol Repository {
    associatedtype Element: Equatable
    func add(element: Element) throws -> Element
    func update(element: Element) throws -> Element
    func delete(element: Element) throws
    func filter(query: (Element) -> Bool) -> [Element]
    func first(where: @escaping (Element) -> Bool) -> Element?
    func contains(condition: (Element) -> Bool) -> Bool
    func contains(element: Element) -> Bool
    var isEmpty: Bool { get }
    var getAll: [Element] { get }
    func deleteAll() throws
}

public extension Repository {
    
    func add<AddTransaction: Transaction>(_ element: Element) throws -> AddTransaction where AddTransaction.Result == Element {
        guard let transaction = AnyTransaction<Element>(transactionClosure: { return try add(element: element) }) as? AddTransaction else {
            throw RepositoryError.transactionError
        }
        return transaction
    }
    
    func update<UpdateTransaction: Transaction>(_ element: Element) throws -> UpdateTransaction where UpdateTransaction.Result == Element {
        guard let transaction = AnyTransaction<Element>(transactionClosure: { return try update(element: element) }) as? UpdateTransaction else {
            throw RepositoryError.transactionError
        }
        return transaction
    }
    
    func delete<DeleteTransaction: Transaction>(_ element: Element) throws -> DeleteTransaction where DeleteTransaction.Result == Void {
        guard let transaction =  AnyTransaction<Void>(transactionClosure: { try delete(element: element) }) as? DeleteTransaction else {
            throw RepositoryError.transactionError
        }
        return transaction
    }
    
    func fetch<FetchTransaction: Transaction>(where: ((Element) -> Bool)?) throws -> FetchTransaction where FetchTransaction.Result == [Element] {
        guard let transaction = AnyTransaction<[Element]> (transactionClosure: {
            guard let query = `where` else { return getAll }
            return filter(query: query)
        }) as? FetchTransaction else {
            throw RepositoryError.transactionError
        }
        return transaction
    }
    
    func first<FetchTransaction: Transaction>(where: @escaping ((Element) -> Bool)) throws -> FetchTransaction where FetchTransaction.Result == Element? {
        guard let transaction = AnyTransaction<Element?> (transactionClosure: { return first(where: `where`) }) as? FetchTransaction else {
            throw RepositoryError.transactionError
        }
        return transaction
    }
}
