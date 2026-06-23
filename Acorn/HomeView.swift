import SwiftUI

struct HomeView: View {
    let containerStatus: ContainerStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView(title: "Home", subtitle: "Installed applications will appear here.")

            ContainerStatusRow(status: containerStatus)

            Spacer()
        }
        .padding(28)
    }
}

struct ContainerStatusRow: View {
    let status: ContainerStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status == .installed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(status == .installed ? .green : .secondary)

            Text("Apple Container:")
                .font(.headline)

            Text(status.label)
                .foregroundStyle(status == .installed ? .green : .secondary)
        }
        .padding(16)
        .background(.quaternary, in: .rect(cornerRadius: 8))
    }
}

#Preview {
    HomeView(containerStatus: .notInstalled)
}
