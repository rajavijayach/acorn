import Foundation

enum AppStatus: String, Codable, CaseIterable, Identifiable {
    case installing
    case installed
    case stopped
    case running
    case failed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .installing: "Installing…"
        case .installed:  "Installed"
        case .stopped:    "Stopped"
        case .running:    "Running"
        case .failed:     "Failed"
        }
    }
}
