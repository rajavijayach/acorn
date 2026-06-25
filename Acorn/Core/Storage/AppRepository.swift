import Foundation
import SQLite3

final class AppRepository {
    private let database: SQLiteDatabase

    init(database: SQLiteDatabase) {
        self.database = database
    }

    func save(manifest: AppManifest) throws {
        let statement = try database.prepare(
            """
            INSERT OR REPLACE INTO manifests (
              id, app_id, schema_version, manifest_yaml, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?);
            """
        )
        defer { sqlite3_finalize(statement) }

        database.bind(manifest.id, to: statement, at: 1)
        database.bind(manifest.appID, to: statement, at: 2)
        database.bind(manifest.schemaVersion, to: statement, at: 3)
        database.bind(manifest.manifestYAML, to: statement, at: 4)
        database.bind(manifest.createdAt, to: statement, at: 5)
        database.bind(manifest.updatedAt, to: statement, at: 6)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw StorageError.stepFailed(message: database.errorMessage)
        }
    }

    func save(installedApp: InstalledApp) throws {
        let statement = try database.prepare(
            """
            INSERT OR REPLACE INTO installed_apps (
              id, name, template_id, status, manifest_id, error_message, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
            """
        )
        defer { sqlite3_finalize(statement) }

        database.bind(installedApp.id, to: statement, at: 1)
        database.bind(installedApp.name, to: statement, at: 2)
        database.bind(installedApp.templateID, to: statement, at: 3)
        database.bind(installedApp.status.rawValue, to: statement, at: 4)
        database.bind(installedApp.manifestID, to: statement, at: 5)
        database.bind(installedApp.errorMessage ?? "", to: statement, at: 6)
        database.bind(installedApp.createdAt, to: statement, at: 7)
        database.bind(installedApp.updatedAt, to: statement, at: 8)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw StorageError.stepFailed(message: database.errorMessage)
        }
    }

    func updateStatus(appID: String, status: AppStatus, errorMessage: String? = nil) throws {
        let statement = try database.prepare(
            """
            UPDATE installed_apps
            SET status = ?, error_message = ?, updated_at = ?
            WHERE id = ?;
            """
        )
        defer { sqlite3_finalize(statement) }

        database.bind(status.rawValue, to: statement, at: 1)
        database.bind(errorMessage ?? "", to: statement, at: 2)
        database.bind(Date(), to: statement, at: 3)
        database.bind(appID, to: statement, at: 4)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw StorageError.stepFailed(message: database.errorMessage)
        }
    }

    func delete(appID: String, manifestID: String) throws {
        let appStatement = try database.prepare("DELETE FROM installed_apps WHERE id = ?;")
        defer { sqlite3_finalize(appStatement) }

        database.bind(appID, to: appStatement, at: 1)
        guard sqlite3_step(appStatement) == SQLITE_DONE else {
            throw StorageError.stepFailed(message: database.errorMessage)
        }

        let manifestStatement = try database.prepare("DELETE FROM manifests WHERE id = ?;")
        defer { sqlite3_finalize(manifestStatement) }

        database.bind(manifestID, to: manifestStatement, at: 1)
        guard sqlite3_step(manifestStatement) == SQLITE_DONE else {
            throw StorageError.stepFailed(message: database.errorMessage)
        }
    }

    func installedApps() throws -> [InstalledApp] {
        let statement = try database.prepare(
            """
            SELECT id, name, template_id, status, manifest_id, error_message, created_at, updated_at
            FROM installed_apps
            ORDER BY name ASC;
            """
        )
        defer { sqlite3_finalize(statement) }

        var apps: [InstalledApp] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let errMsg = database.text(from: statement, at: 5)
            apps.append(
                InstalledApp(
                    id: database.text(from: statement, at: 0),
                    name: database.text(from: statement, at: 1),
                    templateID: database.text(from: statement, at: 2),
                    status: AppStatus(rawValue: database.text(from: statement, at: 3)) ?? .failed,
                    manifestID: database.text(from: statement, at: 4),
                    errorMessage: errMsg.isEmpty ? nil : errMsg,
                    createdAt: database.date(from: statement, at: 6),
                    updatedAt: database.date(from: statement, at: 7)
                )
            )
        }

        return apps
    }

    func manifest(id: String) throws -> AppManifest? {
        let statement = try database.prepare(
            """
            SELECT id, app_id, schema_version, manifest_yaml, created_at, updated_at
            FROM manifests
            WHERE id = ?
            LIMIT 1;
            """
        )
        defer { sqlite3_finalize(statement) }

        database.bind(id, to: statement, at: 1)

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return nil
        }

        return AppManifest(
            id: database.text(from: statement, at: 0),
            appID: database.text(from: statement, at: 1),
            schemaVersion: database.text(from: statement, at: 2),
            manifestYAML: database.text(from: statement, at: 3),
            createdAt: database.date(from: statement, at: 4),
            updatedAt: database.date(from: statement, at: 5)
        )
    }
}
