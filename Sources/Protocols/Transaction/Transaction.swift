import Foundation
import Combine

public protocol Transaction<Result> {
    associatedtype Result: Equatable & Sendable
    var publisher: TransactionPublisher<Result> { get }
    func execute() throws -> Result
    func execute() async throws -> Result
}
