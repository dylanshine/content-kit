import Vapor

public protocol GetController: ModelController where Model: Requestable {
    func get(_ req: Request) throws -> EventLoopFuture<Model.Response>
    func setupGetRoute(routes: RoutesBuilder)
}

public extension GetController {
    func get(_ req: Request) throws -> EventLoopFuture<Model.Response> {
        return try find(req).map(\.response)
    }
    
    func setupGetRoute(routes: RoutesBuilder) {
        routes.get(idPathComponent, use: get)
    }
}
