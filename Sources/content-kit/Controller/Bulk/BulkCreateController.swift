import Vapor
import Fluent

public protocol BulkCreateController  {
    associatedtype Model: Fluent.Model & BulkCreatable
        
    func beforeCreate(req: Request, models: [Model], dto: Model.BulkCreate) -> EventLoopFuture<[Model]>
    func create(_ req: Request) throws -> EventLoopFuture<[Model.Response]>
    func afterCreate(req: Request, models: [Model]) -> EventLoopFuture<Void>
    func setupCreateRoute(routes: RoutesBuilder)
}

extension BulkCreateController {
    func beforeCreate(req: Request, models: [Model], dto: Model.BulkCreate) -> EventLoopFuture<[Model]> {      req.eventLoop.future(models)
    }
    
    func afterCreate(req: Request, models: [Model]) -> EventLoopFuture<Void> {
        return req.eventLoop.future()
    }
    
    func setupCreateRoute(routes: RoutesBuilder) {
        routes.post("bulk", use: create)
    }
}

extension BulkCreateController where Model.BulkCreate.Model == Self.Model {
    
    func create(_ req: Request) throws -> EventLoopFuture<[Model.Response]> {
    
        try Model.BulkCreate.validate(content: req)
        let dto = try req.content.decode(Model.BulkCreate.self)
        let models = try dto.models()
        
        return beforeCreate(req: req, models: models, dto: dto).flatMap { model in
            return models.create(on: req.db)
                .flatMap { afterCreate(req: req, models: models) }
                .transform(to: models.map { $0.response })
        }
    }
}


