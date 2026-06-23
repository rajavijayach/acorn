import Foundation

struct InstalledApp: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var templateID: String
    var status: AppStatus
    var manifestID: String
    var createdAt: Date
    var updatedAt: Date
}
