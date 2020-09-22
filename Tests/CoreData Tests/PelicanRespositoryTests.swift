//
//  PelicanRespositoryTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 9/22/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican

class PelicanRespositoryTests: XCTestCase {
    var subject = PelicanRepository<Int>()
    
    func test() {
        XCTAssertTrue(subject.save(object: 1))
        XCTAssertEqual(subject.fetchAll, [])
        XCTAssertTrue(subject.isEmpty)
        XCTAssertTrue(subject.update(object: 2))
        XCTAssertTrue(subject.delete(object: 2))
        XCTAssertTrue(subject.save())
        subject.empty()
        XCTAssertEqual(subject.filter { $0 > 0 }, [])
    }

}
