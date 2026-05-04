//
//  PelicanLogger.swift
//  Pelican
//
//  Created by Daniel Koster on 4/16/26.
//
import os
import Foundation
import PelicanProtocols

public struct PelicanLogger: PelicanProtocols.Logger {
    private let logger: os.Logger
    
    init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    public func debug(_ msg: String) {
        logger.debug("\(msg)")
    }
    
    public func error(_ msg: String) {
        logger.error("\(msg)")
    }
    
    public func info(_ msg: String) {
        logger.info("\(msg)")
    }
}
