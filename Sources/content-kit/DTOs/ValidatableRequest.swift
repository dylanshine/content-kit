import Vapor

public protocol ValidatableRequest: Content, Validatable {}

public extension ValidatableRequest {
    static func validations(_ validations: inout Validations) {}
}
