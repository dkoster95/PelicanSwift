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

/*
 func calculateDirectorySize(at url: URL) -> Int64 {
     let fileManager = FileManager.default
     // Pre-fetch fileSizeKey for better performance
     guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: []) else {
         return 0
     }
     
     var totalSize: Int64 = 0
     for case let fileURL as URL in enumerator {
         do {
             let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
             // Only add size if it's a regular file (skips directories themselves)
             if let fileSize = resourceValues.fileSize {
                 totalSize += Int64(fileSize)
             }
         } catch {
             print("Error reading file size: \(error)")
         }
     }
     return totalSize
 }
 */
