//
//  KeyValueStore.swift
//  Pelican
//
//  Created by Daniel Koster on 2/19/22.
//  Copyright © 2022 Daniel Koster. All rights reserved.
//

import Foundation

public protocol KeyValueStore {
    func save(data: Data, key: String) -> Bool
    func update(data: Data, key: String) -> Bool
    func delete(key: String) -> Bool
    func fetch(key: String) -> Data?
}
