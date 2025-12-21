import Foundation
import SwiftUI

/// Represents a pollutant type with its thresholds
enum PollutantType: String, CaseIterable, Identifiable {
    case pm25 = "PM2.5"
    case pm10 = "PM10"
    case no2 = "NO₂"
    case so2 = "SO₂"
    case o3 = "O₃"
    case co = "CO"
    
    var id: String { rawValue }
    
    var fullName: String {
        switch self {
        case .pm25: return "Fine Particulate Matter (PM2.5)"
        case .pm10: return "Coarse Particulate Matter (PM10)"
        case .no2: return "Nitrogen Dioxide (NO₂)"
        case .so2: return "Sulfur Dioxide (SO₂)"
        case .o3: return "Ground-Level Ozone (O₃)"
        case .co: return "Carbon Monoxide (CO)"
        }
    }
    
    var description: String {
        switch self {
        case .pm25: return "Tiny particles ≤2.5 micrometers that can penetrate deep into lungs and bloodstream."
        case .pm10: return "Inhalable particles ≤10 micrometers from dust, pollen, and mold. Affects respiratory system."
        case .no2: return "Reddish-brown gas from vehicle emissions and power plants. Irritates airways and reduces immunity."
        case .so2: return "Colorless gas from fossil fuel combustion. Can trigger asthma and respiratory issues."
        case .o3: return "Formed by sunlight reacting with pollutants. Harmful to lungs, especially during outdoor activities."
        case .co: return "Odorless, colorless gas from incomplete combustion. Reduces oxygen delivery to body tissues."
        }
    }
    
    var icon: String {
        switch self {
        case .pm25: return "wind"
        case .pm10: return "cloud"
        case .no2: return "car.fill"
        case .so2: return "building.2.fill"
        case .o3: return "sun.max.fill"
        case .co: return "flame.fill"
        }
    }
    
    var goodLimit: Double {
        switch self {
        case .pm25: return 12
        case .pm10: return 54
        case .no2: return 53
        case .so2: return 35
        case .o3: return 54
        case .co: return 4400
        }
    }
    
    var moderateLimit: Double {
        switch self {
        case .pm25: return 35.4
        case .pm10: return 154
        case .no2: return 100
        case .so2: return 75
        case .o3: return 70
        case .co: return 9400
        }
    }
    
    var unit: String {
        return "µg/m³"
    }
}

/// Pollutant status based on value
enum PollutantStatus: String {
    case good = "Good"
    case moderate = "Moderate"
    case unhealthy = "Unhealthy"
    
    var color: Color {
        switch self {
        case .good: return .aqiGood
        case .moderate: return .aqiModerate
        case .unhealthy: return .aqiUnhealthy
        }
    }
}

/// A single pollutant reading
struct PollutantReading: Identifiable {
    let id = UUID()
    let type: PollutantType
    let value: Double
    
    var status: PollutantStatus {
        if value <= type.goodLimit {
            return .good
        } else if value <= type.moderateLimit {
            return .moderate
        } else {
            return .unhealthy
        }
    }
    
    var roundedValue: Int {
        Int(value.rounded())
    }
}
