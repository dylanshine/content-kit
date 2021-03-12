import Vapor

public protocol BulkCreatable: Upsertable {
    associatedtype BulkCreate: BulkValidatable
}

public protocol BulkValidatable: ValidatableRequest {
    associatedtype Model
    func models() throws -> [Model]
}
 
public struct BulkDelete<T: Codable & Hashable>: Content {
    let ids: [T]
}
