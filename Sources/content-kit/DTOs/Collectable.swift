import Vapor

public protocol Collectable {
    associatedtype Item: Content
    
    var item: Item { get }
}
