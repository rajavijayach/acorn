import SwiftUI

struct HomeView: View {
    let runtimeInfo: RuntimeInfo
    let installedApps: [InstalledApp]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView(title: "Home", subtitle: "Installed applications will appear here.")

            ContainerStatusRow(runtimeInfo: runtimeInfo)

            if installedApps.isEmpty {
                ContentUnavailableView(
                    "No Installed Apps",
                    systemImage: "shippingbox",
                    description: Text("Install flow arrives in the next milestone.")
                )
            } else {
                List(installedApps) { app in
                    HStack {
                        Text(app.name)
                        Spacer()
                        Text(app.status.rawValue.capitalized)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(28)
    }
}

struct ContainerStatusRow: View {
    let runtimeInfo: RuntimeInfo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: runtimeInfo.isInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(runtimeInfo.isInstalled ? .green : .secondary)

            Text("Apple Container:")
                .font(.headline)

            Text(runtimeInfo.isInstalled ? "Installed" : "Not Installed")
                .foregroundStyle(runtimeInfo.isInstalled ? .green : .secondary)

            if let version = runtimeInfo.version {
                Text(version)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.quaternary, in: .rect(cornerRadius: 8))
    }
}

#Preview {
    HomeView(runtimeInfo: .unavailable, installedApps: [])
}
