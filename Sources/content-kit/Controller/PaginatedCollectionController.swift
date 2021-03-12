import Vapor
import Fluent

public protocol PaginatedCollectionController {
    associatedtype Model: Fluent.Model & Collectable
    
    func collection(_: Request) throws -> EventLoopFuture<Page<Model.Item>>
    func setupListRoute(routes: RoutesBuilder)
}

public extension PaginatedCollectionController {
    func collection(_ req: Request) throws -> EventLoopFuture<Page<Model.Item>> {
        Model.query(on: req.db).paginate(for: req).map { $0.map(\.item) }
    }
}
