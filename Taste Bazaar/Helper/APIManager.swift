//
//  APIManager.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 25/02/25.
//

import Foundation

struct APIManager {
    static let shared = APIManager()
    private init() {}
    
    private let baseURL = "https://uat.onebanc.ai/emulator/interview/"
    
    // Common Headers (without X-Forward-Proxy-Action)
    private let commonHeaders: [String: String] = [
        "X-Partner-API-Key": "uonebancservceemultrS3cg8RaL30",
        "Content-Type": "application/json"
    ]
    
    // Generic function to make POST API calls
    func postRequest(
        endpoint: String,
        parameters: [String: Any],
        proxyAction: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = commonHeaders
        headers["X-Forward-Proxy-Action"] = proxyAction
        request.allHTTPHeaderFields = headers
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 500, userInfo: nil)))
                return
            }
            
            completion(.success(data)) // Return raw data first
        }.resume()
    }
}



