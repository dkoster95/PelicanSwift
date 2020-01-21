//
//  CoreDataRepositoryTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
@testable import Pelican
@testable import TestApp
import CoreData

class CoreDataRepositoryTests: XCTestCase {

    private var coreDataRepository: CoreDataRepository<Test>!
    
    private var context: CoreDataContext {
        return CoreDataContext(modelName: "Test")
    }
    
    override func setUp() {
        coreDataRepository = CoreDataRepository<Test>(entityName: "Test", context: context)
        coreDataRepository.empty()
    }
    
    

}
