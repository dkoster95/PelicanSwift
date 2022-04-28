import Foundation
import Combine

public struct TransactionPublisher<Result>: Publisher {
    public func receive<S>(subscriber: S) where S : Subscriber, RepositoryError == S.Failure, Result == S.Input {
        do {
            let result = try transactionResultGenerator()
            _ = subscriber.receive(result)
            subscriber.receive(completion: Subscribers.Completion<RepositoryError>.finished)
        }
        catch let error as RepositoryError {
            subscriber.receive(completion: Subscribers.Completion<RepositoryError>.failure(error))
        }
        catch let error {
            subscriber.receive(completion: Subscribers.Completion<RepositoryError>.failure(RepositoryError.unknownError(error: error)))
        }
    }
    
    public typealias Output = Result
    
    public typealias Failure = RepositoryError
    
    private let transactionResultGenerator: () throws -> Result
    
    public init(transactionResultGenerator: @escaping () throws -> Result) {
        self.transactionResultGenerator = transactionResultGenerator
    }
}
