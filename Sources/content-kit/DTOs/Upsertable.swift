import Vapor

public protocol Upsertable: Requestable {
    associatedtype Upsert: ValidatableRequest
    
    init(_ dto: Upsert) throws
    func update(_ dto: Upsert) throws
}
