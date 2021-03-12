import Vapor
import FluentKit

public protocol PatchController: ModelController where Model: Patchable {
    func beforePatch(req: Request, model: Model, dto: Model.Patch) -> EventLoopFuture<Model>
    func patch(_ req: Request) throws -> EventLoopFuture<Model.Response>
    func afterPatch(req: Request, model: Model) -> EventLoopFuture<Void>
    func setupPatchRoute(routes: RoutesBuilder)
}

public extension PatchController {
    func beforePatch(req: Request, model: Model, dto: Model.Patch) -> EventLoopFuture<Model> {
        return req.eventLoop.future(model)
    }
    
    func Patch(_ req: Request) throws -> EventLoopFuture<Model.Response> {
        try Model.Patch.validate(content: req)
        let dto = try req.content.decode(Model.Patch.self)
        return try find(req)
            .flatMap { model in
                beforePatch(req: req, model: model, dto: dto)
            }
            .flatMapThrowing { model -> Model in
                try model.patch(dto)
                return model
            }
            .flatMap { model -> EventLoopFuture<Model.Response> in
                return model.update(on: req.db)
                    .flatMap { afterPatch(req: req, model: model) }
                    .transform(to: model.response)
            }
    }
    
    
    func afterPatch(req: Request, model: Model) -> EventLoopFuture<Void> {
        return req.eventLoop.future()
    }
    
    func setupPatchRoute(routes: RoutesBuilder) {
        routes.patch(idPathComponent, use: patch)
    }
}
