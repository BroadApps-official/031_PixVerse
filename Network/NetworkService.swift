import Foundation

// MARK: - NetworkService
final class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https:/testingerapp.site/api/user"
    private let bearerToken = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"

    private init() {}

    func fetchEffects(forApp appName: String, completionHandler: @escaping (Result<[Template], Error>) -> Void) {
        guard let baseUrl = URL(string: "https://testingerapp.site/api/templatesByCategories") else {
            print("Failed to create base URL")
            completionHandler(.failure(NetworkError.invalidURL))
            return
        }

        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "appName", value: appName),
            URLQueryItem(name: "ai[]", value: "pv")
        ]

        guard let finalUrl = urlComponents?.url else {
            print("Failed to construct URL with query items")
            completionHandler(.failure(NetworkError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: finalUrl)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let networkError = error {
                print("Request failed with error: \(networkError)")
                completionHandler(.failure(networkError))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server responded with status code: \(httpResponse.statusCode)")
                completionHandler(.failure(NetworkError.invalidResponse))
                return
            }

            guard let responseData = data else {
                print("No data received from the server")
                completionHandler(.failure(NetworkError.noData))
                return
            }

            if let rawResponse = String(data: responseData, encoding: .utf8) {
                print("Raw response data: \(rawResponse)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TemplatesResponse.self, from: responseData)
                if decodedResponse.error {
                    completionHandler(.failure(NetworkError.apiError))
                } else {
                    let allTemplates = decodedResponse.data.flatMap { $0.templates }
                    print("Parsed templates: \(allTemplates)")
                    completionHandler(.success(allTemplates))
                }
            } catch {
                print("Failed to decode response: \(error)")
                completionHandler(.failure(error))
            }
        }.resume()
    }

    func fetchEffectGenerationStatus(generationId: String?, completion: @escaping (Result<GenerationStatusData, Error>) -> Void) {
        var urlComponents = URLComponents(string: "https://testingerapp.site/api/generationStatus?format=json")
        if let generationId = generationId {
            urlComponents?.queryItems = [URLQueryItem(name: "generationId", value: generationId)]
        }

        guard let url = urlComponents?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let bearerToken = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response to fetchGenerationStatus:\n\(rawResponse)")
            } else {
                print("Unable to parse raw response as string")
            }

            do {
                let response = try JSONDecoder().decode(GenerationStatusResponse.self, from: data)
                completion(.success(response.data))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func generateEffect(
        templateId: String?,
        imageFilePath: String?,
        userId: String,
        appId: String,
        completion: @escaping (Result<GenerationResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "https://testingerapp.site/api/generate?format=json") else {
            print("Invalid URL for generateEffect.")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let bearerToken = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        if let templateId = templateId {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"templateId\"\r\n\r\n")
            body.append("\(templateId)\r\n")
        }

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n")
        body.append("\(userId)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"appId\"\r\n\r\n")
        body.append("\(appId)\r\n")

        if let imageFilePath = imageFilePath {
            do {
                let fileName = (imageFilePath as NSString).lastPathComponent
                let imageData = try Data(contentsOf: URL(fileURLWithPath: imageFilePath))
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            } catch {
                completion(.failure(error))
                return
            }
        } else {
            print("No image file provided.")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request body:\n\(bodyString)")
        }

        if let bodySize = request.httpBody?.count {
            print("HTTP Body size: \(bodySize) bytes")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response to generateEffect:\n\(rawResponse)")
            } else {
                print("Unable to parse raw response as string.")
            }

            do {
                let response = try JSONDecoder().decode(GenerationResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - Tokens
extension NetworkService {
    // MARK: - Get User Tokens
    func getUserTokens(userId: String, bundleId: String) async throws -> Int {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "bundleId", value: bundleId)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
        }

        guard let data = json["data"] as? [String: Any],
              let availableGenerations = data["availableGenerations"] as? Int else {
            throw NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Missing 'availableGenerations' field in response"])
        }

        return availableGenerations
    }
    
    // MARK: - Buy Tokens
    func buyTokens(userId: String, bundleId: String, generations: Int) async throws {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId,
            "bundleId": bundleId,
            "generations": generations
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        _ = try await URLSession.shared.data(for: request)
    }
}

// MARK: - Data Extension
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
