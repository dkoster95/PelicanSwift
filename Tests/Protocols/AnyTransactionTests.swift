import Foundation
import XCTest
import PelicanProtocols

final class AnyTransactionTests: XCTestCase {
    
    private func make<Result>(resultGenerator: @escaping () throws -> Result) -> AnyTransaction<Result> {
        return AnyTransaction<Result>(transactionClosure: resultGenerator)
    }
    
    func test_perform_syncTransaction_whenErrorOcurrs_expectErrorThrown() {
        let sut = make { throw AnyError() }
        
        XCTAssertThrowsError(try sut.perform())
    }
    
    func test_perform_syncTransaction_whenTransactionPerformed_expectCorrectResult() throws {
        let sut = make { return "Correct Result" }
        
        let result = try sut.perform()
        
        XCTAssertEqual("Correct Result", result)
    }
    
    func test_perform_asyncTransaction_whenErrorOcurrs_expectErrorThrown() async {
        let sut = make { throw AnyError() }
        do {
            _ = try await sut.performAsync()
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func test_perform_asyncTransaction_whenTransactionPerformed_expectCorrectResult() async throws {
        let sut = make { return "Correct Result" }
        
        let result = try await sut.performAsync()
        
        XCTAssertEqual("Correct Result", result)
    }
}
