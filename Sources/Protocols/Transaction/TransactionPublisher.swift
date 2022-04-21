import Foundation
import Combine

public struct TransactionPublisher<Result>: Publisher {
    public func receive<S>(subscriber: S) where S : Subscriber, RepositoryError == S.Failure, Result == S.Input {
        do {
            let result = try transactionResultGenerator()
            _ = subscriber.receive(result)
            subscriber.receive(completion: Subscribers.Completion<RepositoryError>.finished)
        }
        catch {
            subscriber.receive(completion: Subscribers.Completion<RepositoryError>.failure(RepositoryError.transactionError))
            subscriber.receive(completion: Subscribers.Completion<RepositoryError>.finished)
        }
    }
    
    public typealias Output = Result
    
    public typealias Failure = RepositoryError
    
    private let transactionResultGenerator: () throws -> Result
    
    public init(transactionResultGenerator: @escaping () throws -> Result) {
        self.transactionResultGenerator = transactionResultGenerator
    }
}
