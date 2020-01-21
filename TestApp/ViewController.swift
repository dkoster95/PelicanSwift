//
//  ViewController.swift
//  TestApp
//
//  Created by Daniel Koster on 8/7/19.
//  Copyright © 2019 Daniel Koster. All rights reserved.
//

import UIKit
import Pelican

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let person = Person(firstName: "Daniel", lastName: "Koster", age: 23)
//        let userDefaultsLayer = KeychainLayer<Person>(keychainWrapper: KeychainWrapper.default, key: "test")
//
//        userDefaultsLayer.retrieveFirst(query: nil) {
//            (result: Result<Person,Error>) in
//            switch result {
//            case .success(let person):
//                print(person.firstName)
//                break
//            case .failure( _):
//                break
//            }
//        }
//        if userDefaultsLayer.fetchAll.count > 0 {
//            print("keychain working \(userDefaultsLayer.fetchAll[0])")
//        }
//        let saveResult = userDefaultsLayer.save(object: person)
//        if saveResult {
//            print(userDefaultsLayer.fetchAll[0])
//        }
        
        let intPers = KeychainRepository<String>.init(keychainWrapper: .default, key: "key")
        intPers.save(object: "hey")
        intPers.retrieveFirst(query: nil) {
            (result: Result<String,Error>) in
            switch result {
            case .success(let int):
                print(int)
                break
            case .failure( _):
                break
            }
        }
    }


}

