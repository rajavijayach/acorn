import SwiftUI

struct DiscoverView: View {
    let catalog: [AppTemplate]
    let appModel: AppModel

    @State private var selectedTemplateForInstall: AppTemplate?

    private var categories: [String] {
        Array(Set(catalog.map(\.category))).sorted()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView(title: "Discover", subtitle: "Application catalog coming next.")

                ForEach(categories, id: \.self) { category in
                    CatalogCategorySection(
                        category: category,
                        templates: catalog.filter { $0.category == category },
                        onSelectTemplate: { template in
                            selectedTemplateForInstall = template
                        }
                    )
                }
            }
            .padding(28)
        }
        .sheet(item: $selectedTemplateForInstall) { template in
            InstallWizardView(template: template, appModel: appModel)
        }
    }
}

struct CatalogCategorySection: View {
    let category: String
    let templates: [AppTemplate]
    let onSelectTemplate: (AppTemplate) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category)
                .font(.title2)
                .bold()

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                ForEach(templates) { template in
                    CatalogAppCard(template: template, onSelect: {
                        onSelectTemplate(template)
                    })
                }
            }
        }
    }
}

struct CatalogAppCard: View {
    let template: AppTemplate
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(template.name)
                    .font(.headline)

                Spacer()

                Text(template.source == .bundled ? "Template" : "Seed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(template.summary ?? template.image)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(template.image)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)

            Spacer(minLength: 0)

            Button {
                onSelect()
            } label: {
                Label("View Details", systemImage: "arrow.right.circle")
            }
        }
        .frame(minHeight: 142, alignment: .topLeading)
        .padding(16)
        .background(.quaternary, in: .rect(cornerRadius: 8))
    }
}

#Preview {
    DiscoverView(catalog: [], appModel: AppModel())
}
