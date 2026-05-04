import Foundation

public protocol Logger: Sendable {
    func debug(_ msg: String)
    func error(_ msg: String)
    func info(_ msg: String)
}
