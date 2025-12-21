import Foundation

/// Service for geocoding city searches using Open-Meteo API
actor GeocodingService {
    static let shared = GeocodingService()
    
    private let baseURL = "https://geocoding-api.open-meteo.com/v1/search"
    
    /// Search for cities by name
    func searchCities(query: String) async throws -> [City] {
        guard query.count >= 2 else { return [] }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "5"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(GeocodingResponse.self, from: data)
        
        return result.results ?? []
    }
}
