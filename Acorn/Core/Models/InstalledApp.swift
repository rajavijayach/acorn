import Foundation

struct InstalledApp: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var templateID: String
    var status: AppStatus
    var manifestID: String
    var errorMessage: String?
    var createdAt: Date
    var updatedAt: Date
}
