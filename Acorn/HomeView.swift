import SwiftUI

struct HomeView: View {
    let installedApps: [InstalledApp]
    let appModel: AppModel
    let onBrowseApps: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(title: "Home", subtitle: "Installed applications appear here.")

                EnvironmentReadinessView(
                    readiness: appModel.environment,
                    onBrowseApps: onBrowseApps
                )

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

    private var health: AppHealth { status.health }

    var body: some View {
        HStack(spacing: 6) {
            if health == .starting {
                ProgressView()
                    .scaleEffect(0.7)
                    .frame(width: 14, height: 14)
            } else {
                Circle()
                    .fill(healthColor)
                    .frame(width: 8, height: 8)
            }

            Text(health.label)
                .font(.subheadline)
                .foregroundStyle(healthColor)
        }
    }

    private var healthColor: Color {
        switch health {
        case .healthy:  .green
        case .starting: .yellow
        case .stopped:  .secondary
        case .failed:   .red
        }
    }
}

struct EnvironmentReadinessView: View {
    let readiness: EnvironmentReadiness
    let onBrowseApps: () -> Void

    private let installURL = URL(string: "https://github.com/apple/container/releases")!
    private let learnMoreURL = URL(string: "https://github.com/apple/container")!

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if readiness.isReady {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("Ready")
                        .font(.headline)

                    Spacer()

                    Button("Browse Apps", action: onBrowseApps)
                        .buttonStyle(.borderedProminent)
                }
            } else {
                Text("Welcome to Acorn")
                    .font(.title3)
                    .bold()

                CheckRow(ok: readiness.isAppleSilicon,
                         okText: "Apple Silicon",
                         failText: "Apple Silicon Required")
                CheckRow(ok: readiness.isMacOSCompatible,
                         okText: "macOS Compatible",
                         failText: "macOS 26 or Newer Required")
                CheckRow(ok: readiness.isContainerInstalled,
                         okText: "Apple Container Installed",
                         failText: "Apple Container Missing",
                         warnIfNotOK: true)

                HStack(spacing: 8) {
                    Link(destination: installURL) {
                        Label("Install", systemImage: "arrow.down.circle")
                    }
                    .buttonStyle(.borderedProminent)

                    Link(destination: learnMoreURL) {
                        Label("Learn More", systemImage: "questionmark.circle")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.quaternary, in: .rect(cornerRadius: 8))
    }
}

private struct CheckRow: View {
    let ok: Bool
    let okText: String
    let failText: String
    var warnIfNotOK: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(color)
            Text(ok ? okText : failText)
                .foregroundStyle(ok ? .primary : color)
            Spacer()
        }
    }

    private var symbol: String {
        if ok { return "checkmark.circle.fill" }
        return warnIfNotOK ? "exclamationmark.triangle.fill" : "xmark.circle.fill"
    }

    private var color: Color {
        if ok { return .green }
        return warnIfNotOK ? .yellow : .red
    }
}

#Preview {
    let now = Date()
    HomeView(
        installedApps: [
            InstalledApp(id: "1", name: "PostgreSQL", templateID: "postgresql", status: .running, manifestID: "m1", createdAt: now, updatedAt: now),
            InstalledApp(id: "2", name: "Redis", templateID: "redis", status: .stopped, manifestID: "m2", createdAt: now, updatedAt: now),
            InstalledApp(id: "3", name: "Ollama", templateID: "ollama", status: .failed, manifestID: "m3", errorMessage: "Image pull failed", createdAt: now, updatedAt: now)
        ],
        appModel: AppModel(),
        onBrowseApps: {}
    )
}
