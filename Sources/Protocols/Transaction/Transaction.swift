import Foundation
import Combine

public protocol Transaction {
    associatedtype Result
    var publisher: TransactionPublisher<Result> { get }
}
public protocol SyncTransaction: Transaction {
    func perform() throws -> Result
}

public protocol AsyncTransaction: Transaction {
    func perform() async throws -> Result
}
