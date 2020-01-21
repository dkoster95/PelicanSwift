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

