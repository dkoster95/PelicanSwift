import Foundation

public enum RepositoryError: Error {
    case nonExistingData
    case serializationError
    case duplicatedData
    case transactionError
}
