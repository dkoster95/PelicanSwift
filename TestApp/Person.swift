//
//  Person.swift
//  SampleApp
//
//  Created by Daniel Koster on 6/3/19.
//  Copyright © 2019 Daniel Koster. All rights reserved.
//

import Foundation

class Person: Codable {
    var firstName: String
    var lastName: String
    var age: Int
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
}
