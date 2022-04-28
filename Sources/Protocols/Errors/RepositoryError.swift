import Foundation

public enum RepositoryError: Error {
    case nonExistingData
    case serializationError
    case entityInitializationError(innerError: Error)
    case queryError(innerError: Error)
    case duplicatedData
    case transactionError
    case unknownError(error: Error)
}

extension RepositoryError: Equatable {
    public static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {
        switch (lhs, rhs) {
        case (.unknownError(_), .unknownError(_ )): return true
        case (.nonExistingData, .nonExistingData): return true
        case (.serializationError, .serializationError): return true
        case (.duplicatedData, .duplicatedData): return true
        case (.transactionError, .transactionError): return true
        case (.entityInitializationError(_ ), .entityInitializationError(_ )): return true
        case (.queryError(_), .queryError(_ )): return true
        default: return false
        }
    }
}
