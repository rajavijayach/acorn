import Foundation

enum AppStatus: String, Codable, CaseIterable, Identifiable {
    case installed
    case stopped
    case running
    case failed

    var id: String { rawValue }
}
