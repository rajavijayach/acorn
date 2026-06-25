import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var runtimeInfo: RuntimeInfo = .unavailable
    var installedApps: [InstalledApp] = []
    var catalog: [AppTemplate] = []
    var storageStatus: FoundationStatus = .pending
    var templateStatus: FoundationStatus = .pending

    private let runtimeService = AppleContainerRuntimeService()
    private let templateLoader = TemplateLoader()
    private var repository: AppRepository?

    func start() async {
        await refreshRuntimeInfo()
        initializeStorage()
        loadCatalog()
    }

    private func refreshRuntimeInfo() async {
        runtimeInfo = await runtimeService.info()
    }

    private func initializeStorage() {
        do {
            let database = try SQLiteDatabase(url: Self.databaseURL)
            try database.migrate()
            repository = AppRepository(database: database)
            installedApps = try repository?.installedApps() ?? []

            try SQLiteStorageVerifier.verifyReadWrite()
            storageStatus = .ready("SQLite initialized")
        } catch {
            storageStatus = .failed(error.localizedDescription)
        }
    }

    private func loadCatalog() {
        do {
            catalog = try templateLoader.initialCatalog()
            if let postgreSQLTemplate = catalog.first(where: { $0.id == "postgresql" }) {
                try ManifestRenderingVerifier.verifyPostgreSQLPersistence(template: postgreSQLTemplate)
            }
            templateStatus = .ready("Loaded \(catalog.count) apps")
        } catch {
            templateStatus = .failed(error.localizedDescription)
        }
    }

    func installApp(template: AppTemplate, appName: String, settings: [String: String]) async throws {
        guard let repository = repository else {
            throw StorageError.executionFailed(message: "Database not initialized")
        }

        // 1. Render manifest (validation only — no DB writes yet)
        let manifest = try ManifestRenderer().render(
            template: template,
            appName: appName,
            settings: settings
        )

        // 2. Persist the manifest
        try repository.save(manifest: manifest)

        // 3. Create InstalledApp record with .installing status
        let appID = UUID().uuidString
        let now = Date()
        let installedApp = InstalledApp(
            id: appID,
            name: appName,
            templateID: template.id,
            status: .installing,
            manifestID: manifest.id,
            errorMessage: nil,
            createdAt: now,
            updatedAt: now
        )
        try repository.save(installedApp: installedApp)

        // 4. Refresh so the UI shows "Installing…"
        installedApps = try repository.installedApps()

        // 5. Execute via RuntimeService
        do {
            try await runtimeService.installApp(manifest: manifest, template: template)

            // 6. Success → update to .running
            try repository.updateStatus(appID: appID, status: .running)
        } catch {
            // 7. Failure → update to .failed, persist error message
            try? repository.updateStatus(appID: appID, status: .failed, errorMessage: error.localizedDescription)
            installedApps = try repository.installedApps()
            throw error
        }

        // 8. Final refresh
        installedApps = try repository.installedApps()
    }

    func startApp(_ app: InstalledApp) async throws {
        try await transition(app, success: .running) { try await runtimeService.startApp(appID: $0) }
    }

    func stopApp(_ app: InstalledApp) async throws {
        try await transition(app, success: .stopped) { try await runtimeService.stopApp(appID: $0) }
    }

    func restartApp(_ app: InstalledApp) async throws {
        try await transition(app, success: .running) { try await runtimeService.restartApp(appID: $0) }
    }

    /// Removes an app. `keepData` (the safe default) preserves the data volume;
    /// when false, the template's volumes are purged along with the container.
    func deleteApp(_ app: InstalledApp, keepData: Bool) async throws {
        guard let repository else {
            throw StorageError.executionFailed(message: "Database not initialized")
        }

        guard let manifest = manifest(for: app) else {
            throw StorageError.executionFailed(message: "Manifest not found for \(app.name).")
        }

        let volumeNames = keepData ? [] : (template(for: app)?.runtime?.volumes.map(\.name) ?? [])

        try await runtimeService.uninstallApp(appID: manifest.appID, volumeNames: volumeNames)
        try repository.delete(appID: app.id, manifestID: manifest.id)
        installedApps = try repository.installedApps()
    }

    /// Runs a lifecycle command against the app's container, then persists the
    /// resulting status. Container is identified by the manifest's appID — the
    /// name used at `container run --name`. No reinstall involved.
    private func transition(
        _ app: InstalledApp,
        success: AppStatus,
        command: (String) async throws -> Void
    ) async throws {
        guard let repository else {
            throw StorageError.executionFailed(message: "Database not initialized")
        }

        guard let manifest = manifest(for: app) else {
            throw StorageError.executionFailed(message: "Manifest not found for \(app.name).")
        }

        do {
            try await command(manifest.appID)
            try repository.updateStatus(appID: app.id, status: success)
        } catch {
            try? repository.updateStatus(appID: app.id, status: .failed, errorMessage: error.localizedDescription)
            installedApps = (try? repository.installedApps()) ?? installedApps
            throw error
        }

        installedApps = try repository.installedApps()
    }

    func manifest(for app: InstalledApp) -> AppManifest? {
        guard let repository else { return nil }
        return try? repository.manifest(id: app.manifestID)
    }

    func template(for app: InstalledApp) -> AppTemplate? {
        catalog.first { $0.id == app.templateID }
    }

    private static var databaseURL: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Acorn", isDirectory: true)
            .appendingPathComponent("acorn.sqlite")
    }
}

enum FoundationStatus: Equatable {
    case pending
    case ready(String)
    case failed(String)

    var label: String {
        switch self {
        case .pending:
            "Pending"
        case .ready(let message), .failed(let message):
            message
        }
    }

    var isReady: Bool {
        if case .ready = self {
            return true
        }

        return false
    }
}
