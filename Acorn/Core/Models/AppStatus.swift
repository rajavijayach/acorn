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

    /// A user-facing health summary derived from the lifecycle status. More
    /// meaningful at a glance than the raw status, and the place a real health
    /// probe (and uptime/restart metrics) would plug in later.
    var health: AppHealth {
        switch self {
        case .running:               .healthy
        case .installing:            .starting
        case .installed, .stopped:   .stopped
        case .failed:                .failed
        }
    }
}

enum AppHealth: String {
    case healthy
    case starting
    case stopped
    case failed

    var label: String {
        switch self {
        case .healthy:  "Healthy"
        case .starting: "Starting"
        case .stopped:  "Stopped"
        case .failed:   "Failed"
        }
    }
}
