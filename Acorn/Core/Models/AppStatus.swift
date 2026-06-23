import Foundation

enum AppStatus: String, Codable, CaseIterable, Identifiable {
    case installing
    case installed
    case stopped
    case running
    case failed

    var id: String { rawValue }
}
