import Foundation

// MARK: - Template Models
struct TemplatesResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [TemplateCategory]
}

struct TemplateCategory: Codable {
    let categoryId: Int
    let categoryTitleRu: String
    let categoryTitleEn: String
    let templates: [Template]
}

struct Template: Codable, Equatable {
    let id: Int
    let ai: String
    let pos: Int?
    let title: String
    let categoryId: Int
    let categoryTitleRu: String
    let categoryTitleEn: String
    let effect: String
    var preview: String
    let previewSmall: String
    var isSelected: Bool?
    var localVideoName: String?

    static func ==(lhs: Template, rhs: Template) -> Bool {
        return lhs.id == rhs.id &&
               lhs.ai == rhs.ai &&
               lhs.pos == rhs.pos &&
               lhs.title == rhs.title &&
               lhs.categoryId == rhs.categoryId &&
               lhs.categoryTitleRu == rhs.categoryTitleRu &&
               lhs.categoryTitleEn == rhs.categoryTitleEn &&
               lhs.effect == rhs.effect &&
               lhs.preview == rhs.preview &&
               lhs.previewSmall == rhs.previewSmall &&
               lhs.isSelected == rhs.isSelected &&
               lhs.localVideoName == rhs.localVideoName
    }
}

// MARK: - Generation status Models
struct GenerationStatusResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: GenerationStatusData
}

struct GenerationStatusData: Codable {
    let status: String
    let resultUrl: String?
    let progress: Int?
}

// MARK: - Generation Models
struct GenerationResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: GenerationData
}

struct GenerationData: Codable {
    let generationId: String
    let totalWeekGenerations: Int
    let maxGenerations: Int
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case apiError
    case serverError(statusCode: Int)
}

// MARK: - Data Extension for Multipart Form
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

