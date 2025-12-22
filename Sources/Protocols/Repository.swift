import Foundation
import Combine

public protocol BatchRepository<Element> {
    associatedtype Element: Equatable
    func add(elements: [Element]) throws
}


public protocol ExpressionFilterableRepository<Element> {
    associatedtype Element: Equatable
    func find(predicate: NSPredicate, limit: Int?, sortDescriptor: NSSortDescriptor?) -> [Element]
}

extension ExpressionFilterableRepository {
    func contain(predicate: NSPredicate) -> Bool {
        return find(predicate: predicate, limit: nil, sortDescriptor: nil).count > 0
    }
    
    func findFirst(predicate: NSPredicate) -> Element? {
        return find(predicate: predicate, limit: 1, sortDescriptor: nil).first
    }
}

public protocol Repository<Element> {
    associatedtype Element: Equatable
    func add(element: Element) throws -> Element
    func update(element: Element) throws -> Element
    func delete(element: Element) throws
    func find(query: ((Element) -> Bool)?) -> [Element]
    func first(where: @escaping (Element) -> Bool) -> Element?
    func contains(condition: (Element) -> Bool) -> Bool
    func contains(element: Element) -> Bool
    var isEmpty: Bool { get }
    func deleteAll() throws
}

public extension Repository {
    func find() -> [Element] {
        return find(query: nil)
    }
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
            return find(query: `where`)
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
