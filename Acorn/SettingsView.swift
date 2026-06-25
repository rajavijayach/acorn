import SwiftUI
import AppKit

struct SettingsView: View {
    let runtimeInfo: RuntimeInfo
    let storageStatus: FoundationStatus
    let templateStatus: FoundationStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView(title: "Settings", subtitle: "Application settings.")

            DiagnosticsSection(items: diagnosticItems)

            Spacer()
        }
        .padding(28)
    }

    private var diagnosticItems: [DiagnosticItem] {
        let macOSCompatible = SystemEnvironment.isMacOSCompatible
        return [
            DiagnosticItem(
                label: "Apple Silicon",
                value: SystemEnvironment.isAppleSilicon ? "Yes" : "No",
                ok: SystemEnvironment.isAppleSilicon
            ),
            DiagnosticItem(
                label: "macOS Version",
                value: SystemEnvironment.macOSVersionString + (macOSCompatible ? "" : " (unsupported)"),
                ok: macOSCompatible
            ),
            DiagnosticItem(
                label: "Apple Container Version",
                value: runtimeInfo.version ?? "Not installed",
                ok: runtimeInfo.isInstalled
            ),
            DiagnosticItem(
                label: "Runtime Available",
                value: runtimeInfo.isInstalled ? "Yes" : "No",
                ok: runtimeInfo.isInstalled
            ),
            DiagnosticItem(
                label: "Database",
                value: storageStatus.label,
                ok: storageStatus.isReady
            ),
            DiagnosticItem(
                label: "Templates",
                value: templateStatus.label,
                ok: templateStatus.isReady
            )
        ]
    }
}

struct DiagnosticsSection: View {
    let items: [DiagnosticItem]

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Diagnostics")
                    .font(.headline)

                Spacer()

                Button {
                    copyReport()
                } label: {
                    Label(copied ? "Copied" : "Copy Diagnostics",
                          systemImage: copied ? "checkmark" : "doc.on.doc")
                }
                .buttonStyle(.bordered)
            }

            VStack(spacing: 0) {
                ForEach(items) { item in
                    DiagnosticRow(item: item)
                }
            }
        }
        .padding(16)
        .background(.quaternary, in: .rect(cornerRadius: 8))
    }

    private func copyReport() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(Diagnostics.report(items), forType: .string)
        copied = true
    }
}

private struct DiagnosticRow: View {
    let item: DiagnosticItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(item.ok ? .green : .yellow)

            Text(item.label)
                .frame(width: 190, alignment: .leading)

            Text(item.value)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    SettingsView(
        runtimeInfo: RuntimeInfo(isInstalled: true, version: "container version 0.5.0"),
        storageStatus: .ready("SQLite initialized"),
        templateStatus: .ready("Loaded 5 apps")
    )
}
