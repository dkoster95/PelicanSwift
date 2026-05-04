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
    private let logger: Logger
    
    public init(logger: Logger,
                dateOfExpirationBuilder: @Sendable @escaping (Date) -> Date) {
        self.dateOfExpirationBuilder = dateOfExpirationBuilder
        self.logger = logger
    }
    
    public func isValid(_ data: PelicanProtocols.CacheData) throws -> Bool {
        let dateOfExpiration = dateOfExpirationBuilder(data.createdAt)
        logger.debug("cache record expires on: \(dateOfExpiration)")
        if Date() > dateOfExpiration {
            logger.error("cache record expired")
            throw CacheError.expired
        }
        return true
    }
    
}

public extension ExpirationCachePolicy {
    init(dateOfExpirationBuilder: @escaping @Sendable (Date) -> Date) {
        self.init(logger: PelicanLogger(subsystem: "ExpirationCachePolicy", category: "Cache Policies"),
                  dateOfExpirationBuilder: dateOfExpirationBuilder)
    }
}
