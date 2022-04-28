import Foundation
import Combine

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
