import Vapor

public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    try routes(app)
}
