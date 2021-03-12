import Vapor
import Fluent

public protocol BulkDeleteController {
    associatedtype Model: Fluent.Model
    
    func beforeDelete(req: Request, models: [Model]) -> EventLoopFuture<[Model]>
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus>
    func afterDelete(req: Request) -> EventLoopFuture<Void>
    func setupDeleteRoute(routes: RoutesBuilder)
}

public extension BulkDeleteController {
    func beforeDelete(req: Request, models: [Model]) -> EventLoopFuture<[Model]> {
        req.eventLoop.future(models)
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let ids = try req.content.decode(BulkDelete<Model.IDValue>.self).ids
        
        return Model.query(on: req.db)
            .filter(\._$id ~~ ids)
            .all()
            .flatMap {
                beforeDelete(req: req, models: $0)
            }
            .flatMap {
                $0.delete(on: req.db)
            }
            .flatMap {
                afterDelete(req: req)
            }
            .transform(to: .ok)
    }
    
    func afterDelete(req: Request) -> EventLoopFuture<Void> {
        return req.eventLoop.future()
    }
    
    func setupDeleteRoute(routes: RoutesBuilder) {
        routes.delete("bulk", use: delete)
    }
}
