import Foundation

/// Pollen data from Google Pollen API
struct PollenResponse: Codable {
    let dailyInfo: [DailyPollenInfo]?
}

struct DailyPollenInfo: Codable {
    let pollenTypeInfo: [PollenTypeInfo]?
    let plantInfo: [PlantInfo]?
}

struct PollenTypeInfo: Codable, Identifiable {
    let code: String
    let displayName: String
    let indexInfo: IndexInfo?
    let healthRecommendations: [String]?
    
    var id: String { code }
}

struct PlantInfo: Codable, Identifiable {
    let code: String
    let displayName: String
    let indexInfo: IndexInfo?
    let plantDescription: PlantDescription?
    let healthRecommendations: [String]?
    
    var id: String { code }
}

struct IndexInfo: Codable {
    let value: Int?
    let category: String?
    let indexDescription: String?
}

struct PlantDescription: Codable {
    let family: String?
    let season: String?
    let specialColors: String?
    let crossReaction: String?
    let picture: String?
}

/// Unified pollen item for display
struct PollenItem: Identifiable {
    let id: String
    let name: String
    let value: Int
    let category: String
    let isPlant: Bool
    let imageUrl: String?
    let family: String?
    let season: String?
    let appearance: String?
    let healthRecommendations: [String]?
    
    var level: PollenLevel {
        // Use numeric value (0-5 scale) for more reliable level determination
        switch value {
        case 0:
            return .none
        case 1:
            return .low
        case 2...3:
            return .moderate
        case 4:
            return .high
        case 5...:
            return .veryHigh
        default:
            return .low
        }
    }
}

enum PollenLevel: String {
    case none = "None"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"
    
    var colorName: String {
        switch self {
        case .none: return "levelNone"
        case .low: return "levelLow"
        case .moderate: return "levelModerate"
        case .high: return "levelHigh"
        case .veryHigh: return "levelExtreme"
        }
    }
}
