import SwiftUI

struct HomeView: View {
    let runtimeInfo: RuntimeInfo
    let installedApps: [InstalledApp]
    let appModel: AppModel

    var body: some View {
        NavigationStack {
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
                    List {
                        if !runningApps.isEmpty {
                            Section("Running") {
                                ForEach(runningApps) { app in
                                    NavigationLink(value: app) {
                                        InstalledAppRow(app: app)
                                    }
                                }
                            }
                        }

                        if !installedSectionApps.isEmpty {
                            Section("Installed") {
                                ForEach(installedSectionApps) { app in
                                    NavigationLink(value: app) {
                                        InstalledAppRow(app: app)
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(28)
            .navigationDestination(for: InstalledApp.self) { app in
                AppDetailView(app: app, appModel: appModel)
            }
        }
    }

    /// Apps currently running, shown in the "Running" section.
    private var runningApps: [InstalledApp] {
        installedApps.filter { $0.status == .running }
    }

    /// Every installed app that is not currently running. Installing, stopped,
    /// installed, and failed apps are all records in `installed_apps`, so they
    /// surface here under their existing status badge.
    private var installedSectionApps: [InstalledApp] {
        installedApps.filter { $0.status != .running }
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

                AppStatusBadge(status: app.status)
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
}

struct AppStatusBadge: View {
    let status: AppStatus

    var body: some View {
        HStack(spacing: 6) {
            if status == .installing {
                ProgressView()
                    .scaleEffect(0.7)
                    .frame(width: 14, height: 14)
            } else {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }

            Text(status.displayName)
                .font(.subheadline)
                .foregroundStyle(statusColor)
        }
    }

    private var statusColor: Color {
        switch status {
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
    let now = Date()
    HomeView(
        runtimeInfo: .unavailable,
        installedApps: [
            InstalledApp(id: "1", name: "PostgreSQL", templateID: "postgresql", status: .running, manifestID: "m1", createdAt: now, updatedAt: now),
            InstalledApp(id: "2", name: "Redis", templateID: "redis", status: .stopped, manifestID: "m2", createdAt: now, updatedAt: now),
            InstalledApp(id: "3", name: "Ollama", templateID: "ollama", status: .failed, manifestID: "m3", errorMessage: "Image pull failed", createdAt: now, updatedAt: now)
        ],
        appModel: AppModel()
    )
}
