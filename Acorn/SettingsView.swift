import SwiftUI

struct SettingsView: View {
    let runtimeInfo: RuntimeInfo
    let storageStatus: FoundationStatus
    let templateStatus: FoundationStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView(title: "Settings", subtitle: "Application settings.")

            ContainerStatusRow(runtimeInfo: runtimeInfo)

            VStack(alignment: .leading, spacing: 12) {
                FoundationStatusRow(title: "SQLite", status: storageStatus)
                FoundationStatusRow(title: "Templates", status: templateStatus)
            }

            Spacer()
        }
        .padding(28)
    }
}

struct FoundationStatusRow: View {
    let title: String
    let status: FoundationStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.isReady ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(status.isReady ? .green : .secondary)

            Text(title)
                .font(.headline)

            Text(status.label)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.quaternary, in: .rect(cornerRadius: 8))
    }
}

#Preview {
    SettingsView(
        runtimeInfo: RuntimeInfo(isInstalled: true, version: "container version"),
        storageStatus: .ready("SQLite initialized"),
        templateStatus: .ready("Loaded 5 apps")
    )
}
