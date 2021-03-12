import Vapor

public protocol Requestable {
    associatedtype Response: Content
    var response: Response { get }
}

public extension Requestable where Response == Self {
    var response: Response { self }
}
