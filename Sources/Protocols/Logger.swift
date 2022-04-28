import Foundation

public protocol Logger {
    func debug(_ msg: String)
    func error(_ msg: String)
    func info(_ msg: String)
}
