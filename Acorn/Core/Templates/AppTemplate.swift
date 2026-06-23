import Foundation

struct AppTemplate: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var category: String
    var image: String
    var summary: String?
    var settings: [TemplateSetting]
    var source: TemplateSource

    var validates: Bool {
        !id.isEmpty && !name.isEmpty && !category.isEmpty && !image.isEmpty && !settings.isEmpty
    }
}

struct TemplateSetting: Codable, Identifiable, Equatable {
    let id: String
    var type: SettingType
    var title: String
    var defaultValue: String?
}

enum SettingType: String, Codable {
    case string
    case password
    case integer
    case boolean
}

enum TemplateSource: String, Codable {
    case bundled
    case catalogSeed
}
