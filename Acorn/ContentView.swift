import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarDestination? = .home
    @State private var appModel = AppModel()

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
                    HomeView(runtimeInfo: appModel.runtimeInfo, installedApps: appModel.installedApps, appModel: appModel)
                case .discover:
                    DiscoverView(catalog: appModel.catalog, appModel: appModel)
                case .settings:
                    SettingsView(
                        runtimeInfo: appModel.runtimeInfo,
                        storageStatus: appModel.storageStatus,
                        templateStatus: appModel.templateStatus
                    )
                case nil:
                    HomeView(runtimeInfo: appModel.runtimeInfo, installedApps: appModel.installedApps, appModel: appModel)
                }
            }
            .frame(minWidth: 520, minHeight: 360)
        }
        .task {
            await appModel.start()
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

#Preview {
    ContentView()
}
