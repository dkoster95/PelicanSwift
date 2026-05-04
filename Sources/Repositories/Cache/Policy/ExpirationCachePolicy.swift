//
//  ExpirationCachePolicy.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import PelicanProtocols

public struct ExpirationCachePolicy: CachePolicy {
    private let dateOfExpirationBuilder: @Sendable (Date) -> Date
    
    public init(dateOfExpirationBuilder: @Sendable @escaping (Date) -> Date) {
        self.dateOfExpirationBuilder = dateOfExpirationBuilder
    }
    
    public func isValid(_ data: PelicanProtocols.CacheData) throws -> Bool {
        let dateOfExpiration = dateOfExpirationBuilder(data.createdAt)
        if data.createdAt > dateOfExpiration {
            throw CacheError.expired
        }
        return true
    }
    
    
}
