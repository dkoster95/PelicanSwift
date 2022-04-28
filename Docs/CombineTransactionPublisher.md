#  Combine Support and TransactionPublisher

Reactive and functional programming is taking over.
So any data driven flow must have compatibility with Combine so it can be used as a publisher. The idea behind Pelican is to be used with any paradigm.
Thats why it provides a custom publisher to be used with other Publishers.

This Publisher is bound to the Transaction protocol:

```swift
public protocol Transaction {
    associatedtype Result
    var publisher: TransactionPublisher<Result> { get }
    func perform() throws -> Result
}
....
....
public struct TransactionPublisher<Result>: Publisher
```

And the Repository Protocol provides operations to be handled with transactions:

```swift
public extension Repository {
    
    func add<AddTransaction: Transaction>(_ element: Element) throws -> AddTransaction where AddTransaction.Result == Element
```

Lets see an example of its use:

```swift
// Initialize a Repository
let repository = CDRepository<String>(.....)

let recordToAdd = "New Record"
let publisher = repository.add(recordToAdd).publisher

let cancelSet = Set<AnyCancelable>()
publisher.map { $0 + "Mapped into a new string" }
         .sink(receiveCompletion: {
            switch $0 {
            case .finished:
                print("finished")
            case .failure(_ ):
                print("some Error")
            }
            
        }, receiveValue: { value in
            print(value)
        }).store(in: &cancelSet)

```

