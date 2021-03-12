import Vapor
import Fluent

public protocol UpdateController: ModelController where Model: Upsertable {
    func beforeUpdate(req: Request, model: Model, dto: Model.Upsert) -> EventLoopFuture<Model>
    func update(_ req: Request) throws -> EventLoopFuture<Model.Response>
    func afterUpdate(req: Request, model: Model) -> EventLoopFuture<Void>
    func setupUpdateRoute(routes: RoutesBuilder)
}

public extension UpdateController {
    func beforeUpdate(req: Request, model: Model, dto: Model.Upsert) -> EventLoopFuture<Model> {
        return req.eventLoop.future(model)
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Model.Response> {
        try Model.Upsert.validate(content: req)
        let dto = try req.content.decode(Model.Upsert.self)
        return try find(req)
            .flatMap { model in
                beforeUpdate(req: req, model: model, dto: dto)
            }
            .flatMapThrowing { model -> Model in
                try model.update(dto)
                return model
            }
            .flatMap { model -> EventLoopFuture<Model.Response> in
                return model.update(on: req.db)
                    .flatMap { afterUpdate(req: req, model: model) }
                    .transform(to: model.response)
            }
    }
    
    
    func afterUpdate(req: Request, model: Model) -> EventLoopFuture<Void> {
        return req.eventLoop.future()
    }
    
    func setupUpdateRoute(routes: RoutesBuilder) {
        routes.put(idPathComponent, use: update)
    }
}
