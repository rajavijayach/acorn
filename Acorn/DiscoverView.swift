import SwiftUI

struct DiscoverView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView(title: "Discover", subtitle: "Application catalog coming next.")

            Spacer()
        }
        .padding(28)
    }
}

#Preview {
    DiscoverView()
}
