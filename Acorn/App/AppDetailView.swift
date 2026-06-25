import SwiftUI
import AppKit

struct AppDetailView: View {
    let app: InstalledApp
    let appModel: AppModel

    @State private var manifest: AppManifest?
    @State private var selectedTab: DetailTab = .overview
    @State private var logStream = LogStream()

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

            AppControls(app: liveApp, appModel: appModel)

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
                LogsSection(stream: logStream)
            case .manifest:
                ManifestSection(manifest: manifest)
            }

            Spacer()
        }
        .padding(28)
        .navigationTitle(liveApp.name)
        .task(id: app.id) {
            manifest = appModel.manifest(for: app)
            logStream.start(
                appID: manifest?.appID ?? app.name,
                runtimeAvailable: appModel.runtimeInfo.isInstalled
            )
        }
        .onDisappear {
            logStream.stop()
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

private struct AppControls: View {
    let app: InstalledApp
    let appModel: AppModel

    @State private var inFlight = false
    @State private var errorMessage: String?

    private var canStart: Bool { app.status == .stopped || app.status == .failed }
    private var canStop: Bool { app.status == .running }

    var body: some View {
        HStack(spacing: 8) {
            Button {
                perform { try await appModel.startApp(app) }
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .disabled(!canStart || inFlight)

            Button {
                perform { try await appModel.stopApp(app) }
            } label: {
                Label("Stop", systemImage: "stop.fill")
            }
            .disabled(!canStop || inFlight)

            Button {
                perform { try await appModel.restartApp(app) }
            } label: {
                Label("Restart", systemImage: "arrow.clockwise")
            }
            .disabled(!canStop || inFlight)

            if inFlight {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 16, height: 16)
            }

            Spacer()
        }
        .buttonStyle(.bordered)
        .alert(
            "Action Failed",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func perform(_ action: @escaping () async throws -> Void) {
        inFlight = true
        Task {
            do {
                try await action()
            } catch {
                errorMessage = error.localizedDescription
            }
            inFlight = false
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
    let stream: LogStream

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    stream.isPaused ? stream.resume() : stream.pause()
                } label: {
                    Label(stream.isPaused ? "Resume" : "Pause",
                          systemImage: stream.isPaused ? "play.fill" : "pause.fill")
                }

                Button {
                    copyToPasteboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .disabled(stream.lines.isEmpty)

                Button(role: .destructive) {
                    stream.clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(stream.lines.isEmpty)

                Spacer()

                if stream.isPaused {
                    Text("Paused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.bordered)

            logBody
        }
    }

    @ViewBuilder
    private var logBody: some View {
        if stream.lines.isEmpty {
            ContentUnavailableView(
                "No Logs Yet",
                systemImage: "doc.plaintext",
                description: Text("Waiting for output…")
            )
            .frame(maxWidth: .infinity, minHeight: 160)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(stream.lines) { line in
                            Text(line.text)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(line.id)
                        }
                    }
                    .padding(12)
                }
                .background(.quaternary, in: .rect(cornerRadius: 8))
                .onChange(of: stream.lines.count) {
                    // Auto-scroll to the newest line, but not while paused so the
                    // view doesn't jump while the user is reading.
                    guard !stream.isPaused, let last = stream.lines.last else { return }
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private func copyToPasteboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(stream.text, forType: .string)
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
