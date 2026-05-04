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
    private let logger: Logger
    
    public init(maxSize: Int,
                logger: Logger,
                totalSizeCalculator: @escaping @Sendable () -> Int) {
        self.maxSize = maxSize
        self.totalSizeCalculator = totalSizeCalculator
        self.logger = logger
    }
    
    public func isValid(_ data: CacheData) throws -> Bool {
        logger.debug("Checking cache size")
        
        let totalSizeUsed = totalSizeCalculator()
        logger.debug("cache size: \(totalSizeUsed)")
        logger.debug("data size: \(data.content.count)")
        let potentialSizeUsed = data.content.count + totalSizeUsed
        
        if potentialSizeUsed > maxSize {
            logger.error("Cache size limit reached")
            throw CacheError.sizeLimit
        }
        return true
    }
}

extension FileManager: @unchecked @retroactive Sendable {}

public extension SizeCachePolicy {
    init(maxSize: Int, fileManager: FileManager) {
        self.init(maxSize: maxSize, logger: PelicanLogger(subsystem: "FileSizeCachePolicty", category: "Cache Policies")) {
            Int(fileManager.calculateDirectorySize(at: FileCacheDirectory.filesURL))
        }
    }
}

extension FileManager {
    func calculateDirectorySize(at url: URL) -> Int64 {
        // Pre-fetch fileSizeKey for better performance
        guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: []) else {
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
}
