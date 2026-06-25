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

    /// A connection endpoint derived from the manifest settings. Returns a
    /// libpq-style URI when database credentials are present, otherwise a plain
    /// host:port endpoint. Host is always localhost — apps are port-mapped to
    /// the host by Apple Container.
    var connectionString: String {
        let settings = self.settings
        let host = "localhost"
        let port = settings["port"] ?? ""

        if let username = settings["username"],
           let password = settings["password"],
           let database = settings["database"] {
            return "postgresql://\(username):\(password)@\(host):\(port)/\(database)"
        }

        return "\(host):\(port)"
    }
}
