import XCTest
import PelicanRepositories
class InMemoryRepositoryTests: XCTestCase {
    var subject = InMemoryRepository<Int>()
    override func setUp() {
        try! subject.deleteAll()
    }

    func test_save() throws {
        XCTAssertEqual(2, try subject.add(element: 2))
        XCTAssertEqual(subject.getAll[0], 2)
        XCTAssertFalse(subject.isEmpty)
    }
    
    func test_getAll() throws {
        XCTAssertEqual(2, try subject.add(element: 2))
        XCTAssertEqual(subject.getAll[0], 2)
        XCTAssertFalse(subject.isEmpty)
    }
    
    func test_delete() throws {
        XCTAssertEqual(2, try subject.add(element: 2))
        XCTAssertEqual(subject.getAll[0], 2)
        XCTAssertFalse(subject.isEmpty)
        subject.delete(element: 2)
        XCTAssertTrue(subject.isEmpty)
    }
    
    func test_update() throws {
        XCTAssertEqual(2, try subject.add(element: 2))
        XCTAssertEqual(subject.getAll[0], 2)
        XCTAssertFalse(subject.isEmpty)
        XCTAssertEqual(3, try subject.update(element: 3))
    }
    
}
