import Foundation

// MARK: - Template Models
struct TemplatesResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [Template]
}

struct Template: Codable {
    let id: Int
    let ai: String
    let pos: Int?
    let effect: String
    let preview: String
    let previewSmall: String
    var isSelected: Bool?
    var localVideoName: String?
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

