#  Sync & Async Transactions
---

So far we've seen the operations of a repository returning the concrete types and withouth managing concurrency.

But the Repository protocol also provides CRUD operations returning a Transaction struct that will let you decide how you want to execute that transaction, Sync, Async or use a publisher. you have control over it.



```swift
public protocol Transaction {
    associatedtype Result
    var publisher: TransactionPublisher<Result> { get }
    func perform() throws -> Result
}

public extension Transaction {
    func performAsync() async throws -> Result {
        return try perform()
    }
}

// There is an implementation:
public struct AnyTransaction<Result>: Transaction {
    public typealias Result = Result
    private let transactionClosure: () throws -> Result
    
    public init(transactionClosure: @escaping () throws -> Result) {
        self.transactionClosure = transactionClosure
    }
    
    public var publisher: TransactionPublisher<Result> {
        return TransactionPublisher<Result> { try transactionClosure() }
    }
        
    public func perform() throws -> Result {
        return try transactionClosure()
    }
}
```

And the Repository:

```swift
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
```

Easy right, so how to use it ?


```swift
let repository = CDRepository<Person>(....)
let personToSave = Person(.....)
let transaction: AnyTransaction<Person> = repository.add(personToSave)

//Sync transaction
let result = try transaction.perform()

//Async transaction
let result = try await transaction.performAsync()
```

Why ?

 - We want to be flexible with how we execute the transaction
 - async/await support to be used with Tasks
 - Combine support
 
