//
//  SizeCachePolicy.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import PelicanProtocols

public struct SizeCachePolicy: CachePolicy {
    private let maxSize: Int
    private let totalSizeCalculator: @Sendable () -> Int
    
    public init(maxSize: Int, totalSizeCalculator: @escaping @Sendable () -> Int) {
        self.maxSize = maxSize
        self.totalSizeCalculator = totalSizeCalculator
    }
    
    public func isValid(_ data: CacheData) throws -> Bool {
        let totalSizeUsed = totalSizeCalculator()
        let potentialSizedUsed = data.content.count + maxSize
        
        if potentialSizedUsed > totalSizeUsed {
            throw CacheError.sizeLimit
        }
        return true
    }
}
