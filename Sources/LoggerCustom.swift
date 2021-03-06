//
//  Logger.swift
//  FordPass
//
//  Created by Daniel Koster on 9/18/17.
//  Copyright © 2017 Daniel Koster. All rights reserved.
//

import Foundation

public let log = Log()

public class Log {
    public func debug(_ msg: String) {
        #if DEBUG
        NSLog("Persistence: \(thread) ✅ DEBUG -- \(msg)")
        #endif
    }

    public func error(_ msg: String) {
        #if DEBUG
            NSLog("Persistence: \(thread) ❌ ERROR -- \(msg)")
        #endif
    }
    
    public func info(_ msg: String) {
        #if DEBUG
            NSLog("Persistence: \(thread) ℹ️ INFO -- \(msg)")
        #endif
    }
    
    private var thread: String {
        var thread = "Thread:"
        if Thread.current.isMainThread {
            thread += "main:"
        } else {
            thread += "background:"
        }
        thread += "priority:\(Thread.current.threadPriority)"
        return thread
    }
}
