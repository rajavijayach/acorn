import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarDestination? = .home
    @State private var containerStatus: ContainerStatus = .notInstalled

    var body: some View {
        NavigationSplitView {
            List(SidebarDestination.allCases, selection: $selection) { destination in
                Label(destination.title, systemImage: destination.systemImage)
                    .tag(destination)
            }
            .navigationTitle("Acorn")
        } detail: {
            Group {
                switch selection {
                case .home:
                    HomeView(containerStatus: containerStatus)
                case .discover:
                    DiscoverView()
                case .settings:
                    SettingsView(containerStatus: containerStatus)
                case nil:
                    HomeView(containerStatus: containerStatus)
                }
            }
            .frame(minWidth: 520, minHeight: 360)
        }
        .task {
            containerStatus = await ContainerRuntimeDetector.status()
        }
    }
}

enum SidebarDestination: String, CaseIterable, Identifiable {
    case home
    case discover
    case settings

    var id: Self { self }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .discover:
            "Discover"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            "house"
        case .discover:
            "square.grid.2x2"
        case .settings:
            "gearshape"
        }
    }
}

enum ContainerStatus: Equatable {
    case installed
    case notInstalled

    var label: String {
        switch self {
        case .installed:
            "Installed"
        case .notInstalled:
            "Not Installed"
        }
    }
}

enum ContainerRuntimeDetector {
    static func status() async -> ContainerStatus {
        await Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["which", "container"]

            do {
                try process.run()
                process.waitUntilExit()
                return process.terminationStatus == 0 ? .installed : .notInstalled
            } catch {
                return .notInstalled
            }
        }.value
    }
}

#Preview {
    ContentView()
}
