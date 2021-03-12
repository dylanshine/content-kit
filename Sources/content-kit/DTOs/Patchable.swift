import Vapor

public protocol Patchable: Requestable {
    associatedtype Patch: ValidatableRequest
    
    func patch(_ dto: Patch) throws
}
