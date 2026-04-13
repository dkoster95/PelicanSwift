//
//  ExpirationCachePolicy.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import PelicanProtocols

public struct ExpirationCachePolicy: CachePolicy {
    private let dateOfExpiration: Date
    
    public init(dateOfExpiration: Date) {
        self.dateOfExpiration = dateOfExpiration
    }
    
    public func isValid(_ data: PelicanProtocols.CacheData) throws -> Bool {
        if data.createdAt > dateOfExpiration {
            throw CacheError.expired
        }
        return true
    }
    
    
}
