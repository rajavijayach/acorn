import SwiftUI

struct HomeView: View {
    let runtimeInfo: RuntimeInfo
    let installedApps: [InstalledApp]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView(title: "Home", subtitle: "Installed applications appear here.")

            ContainerStatusRow(runtimeInfo: runtimeInfo)

            if installedApps.isEmpty {
                ContentUnavailableView(
                    "No Installed Apps",
                    systemImage: "shippingbox",
                    description: Text("Open Discover to install your first application.")
                )
            } else {
                List(installedApps) { app in
                    InstalledAppRow(app: app)
                }
            }

            Spacer()
        }
        .padding(28)
    }
}

struct InstalledAppRow: View {
    let app: InstalledApp

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(app.name)
                    .font(.headline)

                Spacer()

                HStack(spacing: 6) {
                    if app.status == .installing {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 14, height: 14)
                    } else {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                    }

                    Text(statusLabel)
                        .font(.subheadline)
                        .foregroundStyle(statusColor)
                }
            }

            if let error = app.errorMessage, app.status == .failed {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusLabel: String {
        switch app.status {
        case .installing: "Installing…"
        case .running:    "Running"
        case .stopped:    "Stopped"
        case .installed:  "Installed"
        case .failed:     "Failed"
        }
    }

    private var statusColor: Color {
        switch app.status {
        case .installing: .yellow
        case .running:    .green
        case .stopped:    .secondary
        case .installed:  .blue
        case .failed:     .red
        }
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
