import ApphudSDK
import Siren
import UIKit
import StoreKit
import AppTrackingTransparency
import AdSupport
import Firebase
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var userId: String?
    var cachedTemplates: [Template] = []
    var experimentV = String()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Apphud.start(apiKey: "app_b2QfLv9Rbk4nGjy16LGe8HUQ2D5L9X")
        FirebaseApp.configure()
        
        let userId = Apphud.userID()
        UserDefaults.standard.set(userId, forKey: "userId")
//        fetchExperiment(with: userId)
        preloadTemplates()
        Siren.shared.wail()
        
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .notDetermined:
                        print("notDetermined")
                    case .restricted:
                        print("restricted")
                    case .denied:
                        print("denied")
                    case .authorized:
                        print("authorized")
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    @unknown default:
                        print("@unknown")
                    }
                }
            }
        }

        return true
    }
    
    private func preloadTemplates() {
        let savedTemplates = CacheManager.shared.loadAllTemplatesFromCache()
        if !savedTemplates.isEmpty {
            cachedTemplates = savedTemplates
            return
        }
        
        NetworkService.shared.fetchEffects(forApp: Bundle.main.bundleIdentifier ?? "com.test.test") { [weak self] result in
            switch result {
            case .success(let templates):
                var updatedTemplates: [Template] = []
                Task {
                    for (index, template) in templates.enumerated() {
                        
                        if !template.preview.isEmpty {
                            do {
                                let videoURL = try await self?.downloadAndSaveVideo(for: template)
  
                                var updatedTemplate = template
                                updatedTemplate.localVideoName = videoURL?.lastPathComponent ?? ""
                                updatedTemplates.append(updatedTemplate)
                                
                                self?.cachedTemplates = updatedTemplates
                                CacheManager.shared.saveTemplateToCache(updatedTemplates)
                                
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: .templatesUpdated, object: updatedTemplates)
                                }
                            } catch {
                                print("Error downloading video for template \(template.id): \(error.localizedDescription)")
                            }
                        } else {
                            print("Template \(template.id) has no preview. Skipping video download.")
                        }
                    }
                }
                
            case .failure(let error):
                print("Error fetching templates from server: \(error.localizedDescription)")
            }
        }
    }

    private func downloadAndSaveVideo(for template: Template) async throws -> URL? {
        return try await withCheckedThrowingContinuation { continuation in
            CacheManager.shared.saveVideo(for: template) { result in
                switch result {
                case .success(let videoURL):
                    print("Video successfully saved for template \(template.id).")
                    continuation.resume(returning: videoURL)
                case .failure(let error):
                    print("Error saving video for template \(template.id): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchExperiment(with userId: String?) {
        guard let userId = userId, let url = URL(string: "https://appruregapp.shop/api/campaign/bwWGbwnLbtCGjop") else {
            print("Invalid userId or URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["appHudUserId": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed with error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            } else {
                print("No data in response")
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response or no data")
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                    for experiment in jsonArray {
                        if let code = experiment["code"], code == "freeexp",
                           let segment = experiment["segment"] {
                            self.experimentV = segment
                            print("Paywalls Segment: \(self.experimentV)")
                            break
                        }
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
