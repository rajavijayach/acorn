import Foundation

enum SQLiteStorageVerifier {
    static func verifyReadWrite() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AcornStorageVerifier-\(UUID().uuidString)", isDirectory: true)
        let databaseURL = directory.appendingPathComponent("verify.sqlite")
        defer { try? FileManager.default.removeItem(at: directory) }

        let database = try SQLiteDatabase(url: databaseURL)
        try database.migrate()

        let repository = AppRepository(database: database)
        let now = Date()
        let manifest = AppManifest(
            id: "verify-manifest",
            appID: "verify-app",
            schemaVersion: "1",
            manifestYAML: "id: verify",
            createdAt: now,
            updatedAt: now
        )
        let app = InstalledApp(
            id: "verify-app",
            name: "Verify App",
            templateID: "verify-template",
            status: .installed,
            manifestID: manifest.id,
            createdAt: now,
            updatedAt: now
        )

        try repository.save(manifest: manifest)
        try repository.save(installedApp: app)

        guard try repository.installedApps().contains(app) else {
            throw StorageError.stepFailed(message: "SQLite read/write verification failed")
        }
    }
}
