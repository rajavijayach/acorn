import SwiftUI

struct SettingsView: View {
    let containerStatus: ContainerStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView(title: "Settings", subtitle: "Application settings.")

            ContainerStatusRow(status: containerStatus)

            Spacer()
        }
        .padding(28)
    }
}

#Preview {
    SettingsView(containerStatus: .installed)
}
