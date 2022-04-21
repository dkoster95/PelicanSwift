import Foundation
import Combine

public struct AnyTransaction<Result>: AsyncTransaction, SyncTransaction {
    public typealias Result = Result
    private let transactionClosure: () throws -> Result
    
    public init(transactionClosure: @escaping () throws -> Result) {
        self.transactionClosure = transactionClosure
    }
    
    public var publisher: TransactionPublisher<Result> {
        return TransactionPublisher<Result> { try transactionClosure() }
    }
    
    public func perform() async throws -> Result {
        return try transactionClosure()
    }
    
    public func perform() throws -> Result {
        return try transactionClosure()
    }
}
