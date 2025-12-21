import Foundation
import CoreLocation

/// City model for search results
struct City: Identifiable, Codable {
    let id: Int
    let name: String
    let country: String?
    let admin1: String?
    let latitude: Double
    let longitude: Double
    
    var displayName: String {
        var components = [name]
        if let admin1 = admin1, !admin1.isEmpty {
            components.append(admin1)
        }
        if let country = country, !country.isEmpty {
            components.append(country)
        }
        return components.joined(separator: ", ")
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Response from Open-Meteo Geocoding API
struct GeocodingResponse: Codable {
    let results: [City]?
}

/// Top cities for the ticker display
struct TopCity {
    let name: String
    let country: String
    let lat: Double
    let lon: Double
    
    static let all: [TopCity] = [
        TopCity(name: "New York", country: "USA", lat: 40.7128, lon: -74.0060),
        TopCity(name: "Los Angeles", country: "USA", lat: 34.0522, lon: -118.2437),
        TopCity(name: "Chicago", country: "USA", lat: 41.8781, lon: -87.6298),
        TopCity(name: "London", country: "UK", lat: 51.5074, lon: -0.1278),
        TopCity(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522),
        TopCity(name: "Tokyo", country: "Japan", lat: 35.6762, lon: 139.6503),
        TopCity(name: "Berlin", country: "Germany", lat: 52.5200, lon: 13.4050),
        TopCity(name: "Toronto", country: "Canada", lat: 43.6532, lon: -79.3832),
        TopCity(name: "Sydney", country: "Australia", lat: -33.8688, lon: 151.2093),
        TopCity(name: "Dubai", country: "UAE", lat: 25.2048, lon: 55.2708)
    ]
}
