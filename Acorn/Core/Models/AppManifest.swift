import Foundation

struct AppManifest: Codable, Identifiable, Equatable {
    let id: String
    var appID: String
    var schemaVersion: String
    var manifestYAML: String
    var createdAt: Date
    var updatedAt: Date
}

extension AppManifest {
    /// Key/value pairs parsed from the rendered manifest's `spec.settings` block.
    /// Single source of truth for reading settings back out of a stored manifest.
    var settings: [String: String] {
        var result: [String: String] = [:]
        var inSettings = false

        for line in manifestYAML.split(separator: "\n").map(String.init) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed == "settings:" {
                inSettings = true
                continue
            }

            guard inSettings else { continue }

            // Setting entries are indented four spaces under `spec.settings`.
            guard line.hasPrefix("    ") else {
                inSettings = false
                continue
            }

            if let colonIndex = trimmed.firstIndex(of: ":") {
                let key = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let value = String(trimmed[trimmed.index(after: colonIndex)...])
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                result[key] = value
            }
        }

        return result
    }
}
