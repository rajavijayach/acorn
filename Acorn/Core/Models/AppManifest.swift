import Foundation

struct AppManifest: Codable, Identifiable, Equatable {
    let id: String
    var appID: String
    var schemaVersion: String
    var manifestYAML: String
    var createdAt: Date
    var updatedAt: Date
}
