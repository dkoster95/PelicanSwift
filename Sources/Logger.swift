

import Foundation

public protocol Logger {
    func debug(_ msg: String)
    func error(_ msg: String)
    func info(_ msg: String)
}

public class Log: Logger {
    public init() {}
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
