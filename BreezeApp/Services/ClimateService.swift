import Foundation

/// Service for fetching historical climate data from Open-Meteo Archive API
actor ClimateService {
    static let shared = ClimateService()
    
    private let baseURL = "https://archive-api.open-meteo.com/v1/archive"
    
    /// Fetch historical temperature data for multiple years
    func fetchClimateData(latitude: Double, longitude: Double) async throws -> [ClimateDataPoint] {
        let today = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        let years = [1980, 1990, 2000, 2010, 2020, currentYear]
        
        var dataPoints: [ClimateDataPoint] = []
        
        for year in years {
            let dateString = String(format: "%d-%02d-%02d", year, month, day)
            
            var components = URLComponents(string: baseURL)!
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "start_date", value: dateString),
                URLQueryItem(name: "end_date", value: dateString),
                URLQueryItem(name: "daily", value: "temperature_2m_max"),
                URLQueryItem(name: "timezone", value: "auto")
            ]
            
            guard let url = components.url else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                let result = try decoder.decode(ClimateArchiveResponse.self, from: data)
                
                if let temp = result.daily?.temperatureMax?.first {
                    dataPoints.append(ClimateDataPoint(year: year, temperature: temp))
                }
            } catch {
                print("Error fetching climate data for \(year): \(error)")
            }
        }
        
        return dataPoints.sorted { $0.year < $1.year }
    }
}
