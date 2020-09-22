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
    }


}

