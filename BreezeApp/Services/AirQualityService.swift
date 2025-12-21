import Foundation

/// Service for fetching air quality data from Open-Meteo API
actor AirQualityService {
    static let shared = AirQualityService()
    
    private let baseURL = "https://air-quality-api.open-meteo.com/v1/air-quality"
    
    /// Fetch current air quality for a location
    func fetchAirQuality(latitude: Double, longitude: Double) async throws -> AirQuality {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone"),
            URLQueryItem(name: "timezone", value: "auto")
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
        let result = try decoder.decode(AirQualityResponse.self, from: data)
        
        guard let airQuality = result.current else {
            throw NSError(domain: "AirQualityService", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "No air quality data available"])
        }
        
        return airQuality
    }
    
    /// Fetch AQI for multiple cities (for ticker)
    func fetchMultipleCities(_ cities: [TopCity]) async -> [(city: TopCity, aqi: Int?)] {
        let lats = cities.map { String($0.lat) }.joined(separator: ",")
        let lons = cities.map { String($0.lon) }.joined(separator: ",")
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: lats),
            URLQueryItem(name: "longitude", value: lons),
            URLQueryItem(name: "current", value: "us_aqi")
        ]
        
        guard let url = components.url else {
            return cities.map { ($0, nil) }
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Parse the response - can be array or single object
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return zip(cities, json).map { city, data in
                    let current = data["current"] as? [String: Any]
                    let aqi = current?["us_aqi"] as? Int
                    return (city, aqi)
                }
            } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let current = json["current"] as? [String: Any],
                      let aqi = current["us_aqi"] as? Int,
                      let firstCity = cities.first {
                return [(firstCity, aqi)]
            }
        } catch {
            print("Error fetching multiple cities: \(error)")
        }
        
        return cities.map { ($0, nil) }
    }
}
