import Foundation

/// Host checks for Apple Container's hard requirements: Apple silicon and
/// macOS 26 or newer.
enum SystemEnvironment {
    /// Apple Container requires macOS 26 (it relies on new Virtualization and
    /// networking features in that release).
    static let minimumMacOSMajorVersion = 26

    /// Runtime check (not `#if arch`, which is compile-time and reports the
    /// build's architecture, not the host's — wrong under Rosetta).
    static var isAppleSilicon: Bool {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        let result = sysctlbyname("hw.optional.arm64", &value, &size, nil, 0)
        return result == 0 && value == 1
    }

    static var isMacOSCompatible: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= minimumMacOSMajorVersion
    }

    static var macOSVersionString: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }
}

/// One line in the diagnostics report. `ok` drives the row indicator.
struct DiagnosticItem: Identifiable {
    let label: String
    let value: String
    let ok: Bool

    var id: String { label }
}

/// Builds a plain-text diagnostics report suitable for pasting into a GitHub
/// issue.
enum Diagnostics {
    static func report(_ items: [DiagnosticItem]) -> String {
        var lines = ["Acorn Diagnostics", "================="]
        for item in items {
            lines.append("\(item.label): \(item.value)")
        }
        return lines.joined(separator: "\n") + "\n"
    }
}

/// Whether the environment can run apps, broken down so the UI can guide the
/// user through any missing prerequisite.
struct EnvironmentReadiness: Equatable {
    var isAppleSilicon: Bool
    var isMacOSCompatible: Bool
    var isContainerInstalled: Bool

    var isReady: Bool {
        isAppleSilicon && isMacOSCompatible && isContainerInstalled
    }

    static let unknown = EnvironmentReadiness(
        isAppleSilicon: false,
        isMacOSCompatible: false,
        isContainerInstalled: false
    )

    static func current(containerInstalled: Bool) -> EnvironmentReadiness {
        EnvironmentReadiness(
            isAppleSilicon: SystemEnvironment.isAppleSilicon,
            isMacOSCompatible: SystemEnvironment.isMacOSCompatible,
            isContainerInstalled: containerInstalled
        )
    }
}
