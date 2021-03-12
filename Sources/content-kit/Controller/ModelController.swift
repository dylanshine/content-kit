import Vapor
import Fluent

public protocol ModelController {
    associatedtype Model: Fluent.Model
    
    var idParamKey: String { get }
    var idPathComponent: PathComponent  { get }
    func find(_ id: Request) throws -> EventLoopFuture<Model>
}

extension ModelController {
    var idParamKey: String { "id" }
    var idPathComponent: PathComponent { .init(stringLiteral: ":\(idParamKey)") }
}

public extension ModelController where Model.IDValue == UUID {
    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        guard let id = req.parameters.get(idParamKey),
              let uuid = UUID(uuidString: id) else {
            throw Abort(.badRequest)
        }
        
        return try find(uuid, db: req.db)
    }
}

public extension ModelController where Model.IDValue == Int {
    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        let id = req.parameters.get(idParamKey, as: Int.self)

        return try find(id, db: req.db)
    }
}

extension ModelController {
    func find(_ id: Model.IDValue?, db: Fluent.Database) throws -> EventLoopFuture<Model> {
        return Model.find(id, on: db).unwrap(or: Abort(.notFound))
    }
}
