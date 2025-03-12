import UIKit
import AVFoundation

class VideoManager: NSObject {
    
    private var completion: ((Bool) -> Void)?
    
    // MARK: - Downloading Video
    
    static func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            if let error = error {
                print("Error downloading video: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let location = location else {
                print("No location found for video download.")
                completion(nil)
                return
            }
            
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uniqueFileName = UUID().uuidString + "_" + url.lastPathComponent
            let destinationURL = documentsDirectory.appendingPathComponent(uniqueFileName)
            
            do {
                try fileManager.moveItem(at: location, to: destinationURL)
                print("Video downloaded and saved to local path: \(destinationURL.path)")
                completion(destinationURL)
            } catch {
                print("Error moving downloaded video: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Saving Video to Gallery
    
    func saveVideoToGallery(videoURL: URL, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: videoURL.path) {
            self.completion = completion
            UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            print("Video file does not exist at path: \(videoURL.path)")
            completion(false)
        }
    }
    
    @objc private func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving video: \(error.localizedDescription)")
            completion?(false)
        } else {
            print("Video saved successfully to gallery.")
            completion?(true)
        }
        completion = nil
    }
}
