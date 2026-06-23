import Foundation

struct ManifestRenderer {
    static let schemaVersion = "acorn.dev/v1"

    func render(template: AppTemplate, appName: String, settings: [String: String]) throws -> AppManifest {
        try validate(template: template, appName: appName, settings: settings)

        let manifestID = UUID().uuidString
        let now = Date()

        return AppManifest(
            id: manifestID,
            appID: normalizedAppName(appName),
            schemaVersion: Self.schemaVersion,
            manifestYAML: yaml(template: template, appName: appName, settings: settings),
            createdAt: now,
            updatedAt: now
        )
    }

    func validate(template: AppTemplate, appName: String, settings: [String: String]) throws {
        guard template.validates else {
            throw ManifestRenderingError.invalidTemplate(template.id)
        }

        guard !normalizedAppName(appName).isEmpty else {
            throw ManifestRenderingError.invalidAppName
        }

        let allowedKeys = Set(template.settings.map(\.id))
        let suppliedKeys = Set(settings.keys)
        let unknownKeys = suppliedKeys.subtracting(allowedKeys).sorted()
        guard unknownKeys.isEmpty else {
            throw ManifestRenderingError.unknownSettings(unknownKeys)
        }

        let missingKeys = template.settings
            .map(\.id)
            .filter { settings[$0]?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true }

        guard missingKeys.isEmpty else {
            throw ManifestRenderingError.missingSettings(missingKeys)
        }
    }

    private func yaml(template: AppTemplate, appName: String, settings: [String: String]) -> String {
        var lines = [
            "apiVersion: \(Self.schemaVersion)",
            "kind: App",
            "metadata:",
            "  name: \(normalizedAppName(appName))",
            "spec:",
            "  template: \(template.id)",
            "  settings:"
        ]

        for setting in template.settings {
            lines.append("    \(setting.id): \(yamlEscaped(settings[setting.id] ?? ""))")
        }

        return lines.joined(separator: "\n") + "\n"
    }

    private func normalizedAppName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func yamlEscaped(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        return "\"\(escaped)\""
    }
}

enum ManifestRenderingError: LocalizedError, Equatable {
    case invalidTemplate(String)
    case invalidAppName
    case missingSettings([String])
    case unknownSettings([String])

    var errorDescription: String? {
        switch self {
        case .invalidTemplate(let templateID):
            "Template is invalid: \(templateID)"
        case .invalidAppName:
            "App name is required."
        case .missingSettings(let keys):
            "Missing required settings: \(keys.joined(separator: ", "))"
        case .unknownSettings(let keys):
            "Unknown settings: \(keys.joined(separator: ", "))"
        }
    }
}
