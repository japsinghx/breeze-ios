import Foundation

/// Historical climate data point
struct ClimateDataPoint: Identifiable {
    let id = UUID()
    let year: Int
    let temperature: Double
}

/// Response from Open-Meteo Archive API
struct ClimateArchiveResponse: Codable {
    let daily: ClimateDaily?
}

struct ClimateDaily: Codable {
    let temperatureMax: [Double]?
    
    enum CodingKeys: String, CodingKey {
        case temperatureMax = "temperature_2m_max"
    }
}
