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

    func installApp(template: AppTemplate, appName: String, settings: [String: String]) throws {
        guard let repository = repository else {
            throw StorageError.executionFailed(message: "Database not initialized")
        }

        let manifest = try ManifestRenderer().render(
            template: template,
            appName: appName,
            settings: settings
        )

        try repository.save(manifest: manifest)

        let installedApp = InstalledApp(
            id: UUID().uuidString,
            name: appName,
            templateID: template.id,
            status: .running,
            manifestID: manifest.id,
            createdAt: Date(),
            updatedAt: Date()
        )

        try repository.save(installedApp: installedApp)

        // Refresh list
        installedApps = try repository.installedApps()
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
