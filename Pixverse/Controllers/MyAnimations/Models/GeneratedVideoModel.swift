import Foundation
import UIKit

struct GeneratedVideoModel: Codable {
    let id: UUID
    let name: String
    var video: String?
    var imagePath: String?
    var isFinished: Bool?
    let createdAt: Date
    let generationId: String

    enum CodingKeys: String, CodingKey {
        case id, name, video, isFinished, imagePath = "image", createdAt, generationId
    }

    init(id: UUID, name: String, video: String?, imagePath: String?, isFinished: Bool? = nil, createdAt: Date = Date(), generationId: String) {
        self.id = id
        self.name = name
        self.video = video
        self.imagePath = imagePath
        self.isFinished = isFinished
        self.createdAt = createdAt
        self.generationId = generationId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        video = try container.decodeIfPresent(String.self, forKey: .video)
        isFinished = try container.decodeIfPresent(Bool.self, forKey: .isFinished)
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        generationId = try container.decode(String.self, forKey: .generationId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(isFinished, forKey: .isFinished)
        try container.encodeIfPresent(imagePath, forKey: .imagePath)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(generationId, forKey: .generationId)
    }
}
