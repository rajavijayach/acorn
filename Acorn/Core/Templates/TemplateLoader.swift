import Foundation

struct TemplateLoader {
    func loadBundledTemplates(bundle: Bundle = .main) throws -> [AppTemplate] {
        let files: [URL]
        if let templateDirectory = bundle.url(forResource: "Templates", withExtension: nil) {
            files = try FileManager.default.contentsOfDirectory(
                at: templateDirectory,
                includingPropertiesForKeys: nil
            )
        } else {
            files = bundle.urls(forResourcesWithExtension: "yaml", subdirectory: nil) ?? []
        }

        return try files
            .filter { $0.pathExtension == "yaml" || $0.pathExtension == "yml" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map(loadTemplate)
    }

    func initialCatalog(bundle: Bundle = .main) throws -> [AppTemplate] {
        let bundledTemplates = try loadBundledTemplates(bundle: bundle)
        let bundledIDs = Set(bundledTemplates.map(\.id))
        let seedTemplates = Self.catalogSeeds.filter { !bundledIDs.contains($0.id) }

        return (bundledTemplates + seedTemplates).sorted {
            if $0.category == $1.category {
                return $0.name < $1.name
            }

            return $0.category < $1.category
        }
    }

    private func loadTemplate(from url: URL) throws -> AppTemplate {
        let yaml = try String(contentsOf: url, encoding: .utf8)
        let fields = parseTopLevelFields(in: yaml)
        let settings = parseSettings(in: yaml)

        let template = AppTemplate(
            id: fields["id"] ?? "",
            name: fields["name"] ?? "",
            category: fields["category"] ?? "",
            image: fields["image"] ?? "",
            summary: fields["summary"],
            settings: settings,
            source: .bundled
        )

        guard template.validates else {
            throw TemplateError.invalidTemplate(name: url.lastPathComponent)
        }

        return template
    }

    private func parseTopLevelFields(in yaml: String) -> [String: String] {
        yaml
            .split(separator: "\n")
            .reduce(into: [String: String]()) { fields, line in
                let text = String(line)
                guard !text.hasPrefix(" "), let delimiter = text.firstIndex(of: ":") else {
                    return
                }

                let key = text[..<delimiter].trimmingCharacters(in: .whitespaces)
                let value = text[text.index(after: delimiter)...]
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

                if !value.isEmpty {
                    fields[key] = value
                }
            }
    }

    private func parseSettings(in yaml: String) -> [TemplateSetting] {
        var settings: [TemplateSetting] = []
        var currentID: String?
        var currentType: SettingType = .string
        var currentTitle: String = ""
        var currentDefault: String?

        func flush() {
            guard let currentID else {
                return
            }

            settings.append(
                TemplateSetting(
                    id: currentID,
                    type: currentType,
                    title: currentTitle.isEmpty ? currentID : currentTitle,
                    defaultValue: currentDefault
                )
            )
        }

        for rawLine in yaml.split(separator: "\n").map(String.init) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            if line.hasPrefix("- id:") {
                flush()
                currentID = value(after: "- id:", in: line)
                currentType = .string
                currentTitle = ""
                currentDefault = nil
            } else if line.hasPrefix("type:") {
                currentType = SettingType(rawValue: value(after: "type:", in: line)) ?? .string
            } else if line.hasPrefix("title:") {
                currentTitle = value(after: "title:", in: line)
            } else if line.hasPrefix("default:") {
                currentDefault = value(after: "default:", in: line)
            }
        }

        flush()
        return settings
    }

    private func value(after prefix: String, in line: String) -> String {
        line
            .dropFirst(prefix.count)
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    private static let catalogSeeds: [AppTemplate] = [
        AppTemplate(
            id: "ollama",
            name: "Ollama",
            category: "AI",
            image: "ollama/ollama:latest",
            summary: "Run local language models.",
            settings: [TemplateSetting(id: "port", type: .integer, title: "Port", defaultValue: "11434")],
            source: .catalogSeed
        ),
        AppTemplate(
            id: "open-webui",
            name: "Open WebUI",
            category: "AI",
            image: "ghcr.io/open-webui/open-webui:main",
            summary: "A web interface for local AI workflows.",
            settings: [TemplateSetting(id: "port", type: .integer, title: "Port", defaultValue: "3000")],
            source: .catalogSeed
        ),
        AppTemplate(
            id: "redis",
            name: "Redis",
            category: "Databases",
            image: "redis:7",
            summary: "In-memory data store.",
            settings: [TemplateSetting(id: "port", type: .integer, title: "Port", defaultValue: "6379")],
            source: .catalogSeed
        ),
        AppTemplate(
            id: "n8n",
            name: "N8N",
            category: "Automation",
            image: "n8nio/n8n:latest",
            summary: "Workflow automation for connected apps.",
            settings: [TemplateSetting(id: "port", type: .integer, title: "Port", defaultValue: "5678")],
            source: .catalogSeed
        )
    ]
}

enum TemplateError: LocalizedError {
    case invalidTemplate(name: String)

    var errorDescription: String? {
        switch self {
        case .invalidTemplate(let name):
            "Invalid template: \(name)"
        }
    }
}
