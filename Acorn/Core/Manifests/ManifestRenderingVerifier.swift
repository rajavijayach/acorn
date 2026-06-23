import Foundation

enum ManifestRenderingVerifier {
    static func verifyPostgreSQLPersistence(template: AppTemplate) throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AcornManifestVerifier-\(UUID().uuidString)", isDirectory: true)
        let databaseURL = directory.appendingPathComponent("verify.sqlite")
        defer { try? FileManager.default.removeItem(at: directory) }

        let database = try SQLiteDatabase(url: databaseURL)
        try database.migrate()

        let repository = AppRepository(database: database)
        let manifest = try ManifestRenderer().render(
            template: template,
            appName: "postgresql",
            settings: [
                "database": "app",
                "username": "postgres",
                "password": "postgres",
                "port": "5432"
            ]
        )

        try repository.save(manifest: manifest)

        guard try repository.manifest(id: manifest.id) == manifest else {
            throw ManifestRenderingError.invalidTemplate(template.id)
        }
    }
}
