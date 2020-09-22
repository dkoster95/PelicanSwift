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
        
        let intPers = KeychainRepository<String>.init(keychainWrapper: .default, key: "key")
        intPers.save(object: "hey")
        print(intPers.first)
        let context = CoreDataContext(modelName: "TestModel")
        let persi = CoreDataRepository<TestEntity>(entityName: "TestEntity",
                                             context: context)
        let test = TestEntity(name: "", age: 24, context: context.persistentContainer.viewContext)
        persi.save()
        print(persi.first?.age)
    }


}

