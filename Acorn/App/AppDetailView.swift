import SwiftUI

struct AppDetailView: View {
    let app: InstalledApp
    let appModel: AppModel

    @State private var manifest: AppManifest?
    @State private var selectedTab: DetailTab = .overview

    /// Always read the freshest record so status changes (e.g. start/stop in a
    /// later milestone) reflect here without re-pushing the view.
    private var liveApp: InstalledApp {
        appModel.installedApps.first { $0.id == app.id } ?? app
    }

    private var template: AppTemplate? {
        appModel.template(for: app)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(liveApp.name)
                        .font(.largeTitle)
                        .bold()

                    Text(template?.summary ?? liveApp.templateID)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                AppStatusBadge(status: liveApp.status)
            }

            Picker("Section", selection: $selectedTab) {
                ForEach(DetailTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch selectedTab {
            case .overview:
                OverviewSection(app: liveApp, manifest: manifest, template: template)
            case .logs:
                LogsSection()
            case .manifest:
                ManifestSection(manifest: manifest)
            }

            Spacer()
        }
        .padding(28)
        .navigationTitle(liveApp.name)
        .task {
            manifest = appModel.manifest(for: app)
        }
    }

    enum DetailTab: String, CaseIterable, Identifiable {
        case overview
        case logs
        case manifest

        var id: String { rawValue }

        var title: String {
            switch self {
            case .overview: "Overview"
            case .logs:     "Logs"
            case .manifest: "Manifest"
            }
        }
    }
}

private struct OverviewSection: View {
    let app: InstalledApp
    let manifest: AppManifest?
    let template: AppTemplate?

    private var settings: [String: String] {
        manifest?.settings ?? [:]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DetailRow(label: "Status", value: app.status.displayName)
            DetailRow(label: "Template", value: template?.name ?? app.templateID)

            if let schemaVersion = manifest?.schemaVersion {
                DetailRow(label: "Schema Version", value: schemaVersion)
            }

            DetailRow(
                label: "Created",
                value: app.createdAt.formatted(date: .abbreviated, time: .shortened)
            )

            if let port = settings["port"] {
                DetailRow(label: "Port", value: port)
            }

            if let username = settings["username"] {
                DetailRow(label: "Username", value: username)
            }

            DetailRow(label: "Data Volume", value: dataLocation)

            if let error = app.errorMessage, app.status == .failed {
                DetailRow(label: "Error", value: error)
            }
        }
        .padding(16)
        .background(.quaternary, in: .rect(cornerRadius: 8))
    }

    private var dataLocation: String {
        guard let volumes = template?.runtime?.volumes, !volumes.isEmpty else {
            return "Not configured"
        }

        return volumes
            .map { "\($0.name) → \($0.path)" }
            .joined(separator: ", ")
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 130, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .textSelection(.enabled)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}

private struct LogsSection: View {
    var body: some View {
        ContentUnavailableView(
            "Logs Coming Soon",
            systemImage: "doc.plaintext",
            description: Text("Live log streaming arrives in the next update.")
        )
        .frame(maxWidth: .infinity, minHeight: 160)
    }
}

private struct ManifestSection: View {
    let manifest: AppManifest?

    var body: some View {
        if let manifest {
            ScrollView {
                Text(manifest.manifestYAML)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(.quaternary, in: .rect(cornerRadius: 8))
        } else {
            ContentUnavailableView(
                "No Manifest",
                systemImage: "doc.text.magnifyingglass",
                description: Text("This app has no stored manifest.")
            )
            .frame(maxWidth: .infinity, minHeight: 160)
        }
    }
}

#Preview {
    let now = Date()
    NavigationStack {
        AppDetailView(
            app: InstalledApp(
                id: "1",
                name: "PostgreSQL",
                templateID: "postgresql",
                status: .running,
                manifestID: "m1",
                createdAt: now,
                updatedAt: now
            ),
            appModel: AppModel()
        )
    }
}
