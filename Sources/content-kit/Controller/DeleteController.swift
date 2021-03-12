import Vapor
import Fluent

protocol DeleteController: ModelController {
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model>
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus>
    func afterDelete(req: Request) -> EventLoopFuture<Void>
    func setupDeleteRoute(routes: RoutesBuilder)
}

extension DeleteController {
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try find(req)
            .flatMap { beforeDelete(req: req, model: $0) }
            .flatMap { $0.delete(on: req.db) }
            .flatMap { afterDelete(req: req) }
            .transform(to: .ok)
    }
    
    func afterDelete(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
    
    func setupDeleteRoute(routes: RoutesBuilder) {
        routes.delete(idPathComponent, use: delete)
    }
}
