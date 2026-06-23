import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle)
                .bold()

            Text(subtitle)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HeaderView(title: "Home", subtitle: "Installed applications will appear here.")
        .padding()
}
