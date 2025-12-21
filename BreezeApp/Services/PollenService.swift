import Foundation

/// Service for fetching pollen data from Google Pollen API
actor PollenService {
    static let shared = PollenService()
    
    // Backend proxy URL - your production API
    private let baseURL = "https://breeze.earth/api/pollen"
    
    /// Fetch pollen data for a location via backend proxy
    func fetchPollen(latitude: Double, longitude: Double) async throws -> [PollenItem] {
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(PollenResponse.self, from: data)
        
        var items: [PollenItem] = []
        
        if let dailyInfo = result.dailyInfo?.first {
            // Add pollen types (Grass, Tree, Weed)
            if let pollenTypes = dailyInfo.pollenTypeInfo {
                for type in pollenTypes {
                    items.append(PollenItem(
                        id: type.code,
                        name: type.displayName,
                        value: type.indexInfo?.value ?? 0,
                        category: type.indexInfo?.category ?? "Low",
                        isPlant: false,
                        imageUrl: nil,
                        family: nil,
                        season: nil,
                        appearance: nil,
                        healthRecommendations: type.healthRecommendations
                    ))
                }
            }
            
            // Add specific plants
            if let plants = dailyInfo.plantInfo {
                for plant in plants {
                    var displayName = plant.displayName
                    if plant.code == "GRAMINALES" {
                        displayName = "Graminales"
                    }
                    
                    items.append(PollenItem(
                        id: plant.code,
                        name: displayName,
                        value: plant.indexInfo?.value ?? 0,
                        category: plant.indexInfo?.category ?? "Low",
                        isPlant: true,
                        imageUrl: plant.plantDescription?.picture,
                        family: plant.plantDescription?.family,
                        season: plant.plantDescription?.season,
                        appearance: plant.plantDescription?.specialColors,
                        healthRecommendations: plant.healthRecommendations
                    ))
                }
            }
        }
        
        return items
    }
}
