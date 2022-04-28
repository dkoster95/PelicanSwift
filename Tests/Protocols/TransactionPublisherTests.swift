import Foundation
import XCTest
import PelicanProtocols
import Combine

final class TransactionPublisherTests: XCTestCase {
    
    private var cancelSet = Set<AnyCancellable>()
    
    func test_receive_whenResultEmitted_expectNoErrorAndFinishedEmitted() {
        let publisher = TransactionPublisher<Int> {
            return 23
        }
        let expectation = XCTestExpectation()
        publisher.sink(receiveCompletion: {
            switch $0 {
            case .finished:
                XCTAssertTrue(true)
                expectation.fulfill()
            case .failure(_ ):
                XCTAssertFalse(false)
            }
            
        }, receiveValue: { value in
            XCTAssertEqual(23, value)
        }).store(in: &cancelSet)
        wait(for: [expectation], timeout: 3)
    }
    
    func test_receive_whenRepositoryErrorEmitted_expectNoErrorAndFinishedEmitted() {
        let publisher = TransactionPublisher<Int> {
            throw RepositoryError.duplicatedData
        }
        let expectation = XCTestExpectation()
        publisher.sink(receiveCompletion: {
            switch $0 {
            case .finished:
                XCTAssert(false)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(RepositoryError.duplicatedData, error)
                expectation.fulfill()
            }
            
        }, receiveValue: { value in
            XCTAssert(false)
        }).store(in: &cancelSet)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_receive_whenAnyErrorEmitted_expectNoErrorAndFinishedEmitted() {
        let publisher = TransactionPublisher<Int> {
            throw AnyError()
        }
        let expectation = XCTestExpectation()
        publisher.sink(receiveCompletion: {
            switch $0 {
            case .finished:
                XCTAssert(false)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(RepositoryError.unknownError(error: AnyError()), error)
                expectation.fulfill()
            }
            
        }, receiveValue: { value in
            XCTAssert(false)
        }).store(in: &cancelSet)
        wait(for: [expectation], timeout: 1)
    }
}

struct AnyError: Error {
}
