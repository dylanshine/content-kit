import Vapor
import Fluent

public protocol CreateController {
    associatedtype Model: Fluent.Model & Upsertable
    
    func beforeCreate(req: Request, model: Model, dto: Model.Upsert) -> EventLoopFuture<Model>
    func create(_ req: Request) throws -> EventLoopFuture<Model.Response>
    func afterCreate(req: Request, model: Model) -> EventLoopFuture<Void>
    func setupCreateRoute(routes: RoutesBuilder)
}

public extension CreateController {
    func beforeCreate(req: Request, model: Model, dto: Model.Upsert) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Model.Response> {
        try Model.Upsert.validate(content: req)
        let dto = try req.content.decode(Model.Upsert.self)
        let model = try Model(dto)

        return beforeCreate(req: req, model: model, dto: dto).flatMap { model in
            return model.create(on: req.db)
                .flatMap { afterCreate(req: req, model: model) }
                .transform(to: model.response)
        }
    }
    
    func afterCreate(req: Request, model: Model) -> EventLoopFuture<Void> {
        return req.eventLoop.future()
    }
    
    func setupCreateRoute(routes: RoutesBuilder) {
        routes.post(use: create)
    }
}
