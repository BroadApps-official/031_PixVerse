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
        print("Starting to save video for template with ID: \(template.id)")

        if !template.preview.isEmpty, let videoURL = URL(string: template.preview) {
            let videoFileURL = videoCacheDirectory.appendingPathComponent("\(template.id).mp4")

            print("Video URL for template: \(videoURL)")
            print("Video file URL in cache: \(videoFileURL)")

            if fileManager.fileExists(atPath: videoFileURL.path) {
                print("Video already exists in cache. Returning cached file.")
                completion(.success(videoFileURL))
                return
            }

            print("Downloading video from URL: \(videoURL)")
            URLSession.shared.downloadTask(with: videoURL) { [weak self] location, _, error in
                if let error = error {
                    print("Error downloading video: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let location = location else {
                    let downloadError = NSError(domain: "Download error", code: 404, userInfo: nil)
                    completion(.failure(downloadError))
                    return
                }

                print("Download completed, moving video to cache...")

                do {
                    try self?.fileManager.moveItem(at: location, to: videoFileURL)
                    print("Video successfully saved to cache at path: \(videoFileURL.path)")
                    completion(.success(videoFileURL))
                } catch {
                    print("Error moving downloaded video to cache: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }.resume()
        } else {
            print("Invalid URL for template with ID: \(template.id)")
            let invalidURLError = NSError(domain: "Invalid URL", code: 400, userInfo: nil)
            completion(.failure(invalidURLError))
        }
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
