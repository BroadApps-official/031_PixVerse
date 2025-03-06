import Foundation
import UIKit

final class CacheManager {
    static let shared = CacheManager()

    private let fileManager = FileManager.default
    private let videoCacheDirectory: URL
    private let templatesCacheFileURL: URL
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private init() {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!

        videoCacheDirectory = cacheDir.appendingPathComponent("video_cache")
        try? fileManager.createDirectory(at: videoCacheDirectory, withIntermediateDirectories: true, attributes: nil)

        templatesCacheFileURL = cacheDir.appendingPathComponent("templates_cache.json")
    }

    // MARK: - Saving

    func saveOrUpdateVideoModel(_ model: GeneratedVideoModel, completion: @escaping (Bool) -> Void) {
        let modelURL = videoCacheDirectory.appendingPathComponent("\(model.id.uuidString).json")

        do {
            let data: Data
            var existingModel: GeneratedVideoModel
            if fileManager.fileExists(atPath: modelURL.path) {
                data = try Data(contentsOf: modelURL)
                existingModel = try JSONDecoder().decode(GeneratedVideoModel.self, from: data)
            } else {
                existingModel = model
                data = try JSONEncoder().encode(existingModel)
            }

            existingModel.video = model.video ?? existingModel.video
            existingModel.imagePath = model.imagePath ?? existingModel.imagePath
            existingModel.isFinished = model.isFinished ?? existingModel.isFinished

            let updatedData = try JSONEncoder().encode(existingModel)
            try updatedData.write(to: modelURL)

            completion(true)
        } catch {
            completion(false)
        }
    }

    func saveVideo(for template: Template, completion: @escaping (Result<URL, Error>) -> Void) {
        guard !template.preview.isEmpty, let videoURL = URL(string: template.preview) else {
            let invalidURLError = NSError(domain: "Invalid URL", code: 400, userInfo: nil)
            completion(.failure(invalidURLError))
            return
        }

        let videoFileURL = videoCacheDirectory.appendingPathComponent("\(template.id).mp4")
        let tempVideoURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
        let cachedPreviewKey = "cached_preview_\(template.id)"
        let cachedPreview = UserDefaults.standard.string(forKey: cachedPreviewKey)

        if let cachedPreview, cachedPreview != template.preview {
            let oldVideoBackupURL = videoCacheDirectory.appendingPathComponent("\(template.id)_old.mp4")

            do {
                if fileManager.fileExists(atPath: videoFileURL.path) {
                    try fileManager.moveItem(at: videoFileURL, to: oldVideoBackupURL)
                }
                UserDefaults.standard.set(template.preview, forKey: cachedPreviewKey)
            } catch {
                print("Error renaming old video: \(error.localizedDescription)")
            }
        } else if fileManager.fileExists(atPath: videoFileURL.path) {
            completion(.success(videoFileURL))
            return
        } else {
            UserDefaults.standard.set(template.preview, forKey: cachedPreviewKey)
        }

        URLSession.shared.downloadTask(with: videoURL) { [weak self] location, _, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let location = location else {
                let downloadError = NSError(domain: "Download error", code: 404, userInfo: nil)
                completion(.failure(downloadError))
                return
            }

            do {
                try self.fileManager.moveItem(at: location, to: tempVideoURL)
                if self.fileManager.fileExists(atPath: videoFileURL.path) {
                    try self.fileManager.removeItem(at: videoFileURL)
                }
                try self.fileManager.moveItem(at: tempVideoURL, to: videoFileURL)

                completion(.success(videoFileURL))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func loadVideo(for template: Template, completion: @escaping (Result<URL, Error>) -> Void) {
        let videoFileURL = videoCacheDirectory.appendingPathComponent("\(template.id).mp4")

        if fileManager.fileExists(atPath: videoFileURL.path) {
            completion(.success(videoFileURL))
        } else {
            saveVideo(for: template) { result in
                switch result {
                case let .success(url):
                    completion(.success(url))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func loadPreview(for template: Template, completion: @escaping (Result<URL, Error>) -> Void) {
        let videoFileURL = videoCacheDirectory.appendingPathComponent("\(template.id)_preview.mp4")

        if fileManager.fileExists(atPath: videoFileURL.path) {
            completion(.success(videoFileURL))
        } else {
            saveVideo(for: template) { result in
                switch result {
                case let .success(url):
                    completion(.success(url))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func saveTemplateToCache(_ templates: [Template]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(templates)
            try data.write(to: templatesCacheFileURL, options: .atomic)
            print("templates saved in cashe.")
        } catch {
            print("failed templates saving in cashe: \(error.localizedDescription)")
        }
    }

    func loadAllTemplatesFromCache() -> [Template] {
        guard fileManager.fileExists(atPath: templatesCacheFileURL.path) else {
            print("no templates")
            return []
        }

        do {
            let data = try Data(contentsOf: templatesCacheFileURL)
            let decoder = JSONDecoder()
            let templates = try decoder.decode([Template].self, from: data)
            print("templates loaded from cashe.")
            return templates
        } catch {
            print("error templates loading from cashe: \(error.localizedDescription)")
            return []
        }
    }

    func loadAllVideoModels(completion: @escaping ([GeneratedVideoModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            var models: [GeneratedVideoModel] = []

            do {
                let files = try self.fileManager.contentsOfDirectory(at: self.videoCacheDirectory, includingPropertiesForKeys: nil)
                for file in files where file.pathExtension == "json" {
                    if let data = try? Data(contentsOf: file),
                       let model = try? JSONDecoder().decode(GeneratedVideoModel.self, from: data) {
                        models.append(model)
                    }
                }
            } catch {
                print("Failed to load all video models: \(error)")
            }

            DispatchQueue.main.async {
                completion(models)
            }
        }
    }

    // MARK: - Load all models
    func loadAllVideoModels() -> [GeneratedVideoModel] {
        var models: [GeneratedVideoModel] = []

        do {
            let files = try fileManager.contentsOfDirectory(at: videoCacheDirectory, includingPropertiesForKeys: nil)

            for file in files {
                if file.pathExtension == "json" {
                    let data = try Data(contentsOf: file)
                    if var model = try? JSONDecoder().decode(GeneratedVideoModel.self, from: data) {
                        if let imagePath = model.imagePath, !fileManager.fileExists(atPath: imagePath) {
                            print("Image at path \(imagePath) does not exist. Updating model.")
                            model.imagePath = nil
                        }

                        models.append(model)
                    }
                }
            }
        } catch {
            print("Failed to load all models: \(error)")
        }

        return models
    }

    // MARK: - Deleting model
    func deleteVideoModel(withId id: UUID) {
        let modelURL = videoCacheDirectory.appendingPathComponent("\(id.uuidString).json")
        let videoURL = videoCacheDirectory.appendingPathComponent("\(id.uuidString).mp4")

        do {
            if fileManager.fileExists(atPath: modelURL.path) {
                try fileManager.removeItem(at: modelURL)
            }

            if fileManager.fileExists(atPath: videoURL.path) {
                try fileManager.removeItem(at: videoURL)
            }
        } catch {
            print("Failed to delete cached data: \(error)")
        }
    }
}
