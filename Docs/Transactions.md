#  Sync & Async Transactions
---

So far we've seen the operations of a repository returning the concrete types and withouth managing concurrency.

If we want to achieve more granularity we use a transaction only, because we dont want to import an entire repository to just perform a single transaction.

A transaction is an operation that given an input it produces an output:


```swift
public protocol Transaction<Result> {
    associatedtype Result: Equatable & Sendable
    var publisher: TransactionPublisher<Result> { get }
    func execute() throws -> Result
    func execute() async throws -> Result
}
 it supports both sync/async modes and a publisher to access it.
 
 we have 3 different transactions:
- WriteElementTransaction
- ReadElementTransaction
- ReadPredicateElementTransaction

basically they are split in read/write

## WriteElementTransaction
---

WriteElementTransaction uses a generic type and it supports integration with InsertableRepository and UpdatableRepository, meaning you can run updates and insertions using WriteElementTransaction.

example: 

```swift
/// InsertRepository implements InsertableRepository protocol
let insertRepository = InsertRepository<Element>(....)
let elementToInsert = Element(....)

let transaction = WriteElementTransaction<Element>(insertRepository, elementToInsert)

Task {
    let result = try await transaction.execute() 
}
```

## ReadElementTransaction
---
ReadElementTransaction is very similar but difference is the Transaction type which is read


```swift
/// ReadableRepositoryImp implements ReadableRepository protocol
let readRepository = ReadableRepositoryImp<Element>(....)


let transaction = ReadElementTransaction<Element>(readRepository) { $0.name == "some name" }

Task {
    let result = try await transaction.execute() 
}
```

Why ?

 - We want to be flexible with how we execute the transaction
 - async/await support to be used with Tasks
 - Combine support
 
