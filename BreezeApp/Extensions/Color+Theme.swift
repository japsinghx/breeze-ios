import SwiftUI

extension Color {
    // MARK: - Background Colors
    static let appBackground = Color("Background")
    
    // Card backgrounds with better contrast in light mode
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.15, alpha: 1.0)  // Dark mode: slightly lighter than black
            : UIColor(white: 0.91, alpha: 1.0)  // Light mode: darker gray for better visibility
    })
    
    static let searchBarBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.2, alpha: 1.0)   // Dark mode: medium gray
            : UIColor(white: 0.92, alpha: 1.0)  // Light mode: visible gray
    })
    
    // MARK: - AQI Colors
    static let aqiGood = Color(hex: "34c759")
    static let aqiModerate = Color(hex: "ff9500")
    static let aqiUnhealthySensitive = Color(hex: "ff6b00")
    static let aqiUnhealthy = Color(hex: "ff3b30")
    static let aqiVeryUnhealthy = Color(hex: "af52de")
    static let aqiHazardous = Color(hex: "8e0000")
    
    // MARK: - Pollen Level Colors
    static let levelNone = Color(hex: "34c759") // Green for 0/none
    static let levelLow = Color(hex: "34c759")
    static let levelModerate = Color(hex: "ff9500")
    static let levelHigh = Color(hex: "ff3b30")
    static let levelExtreme = Color(hex: "8e0000")
    
    // MARK: - Climate Colors
    static let climateNeutral = Color.gray
    static let climateCool = Color(hex: "34c759")
    static let climateWarm = Color(hex: "ff9500")
    static let climateHot = Color(hex: "ff3b30")
    
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Pollen Color Helper
extension PollenLevel {
    var color: Color {
        switch self {
        case .none: return .levelNone
        case .low: return .levelLow
        case .moderate: return .levelModerate
        case .high: return .levelHigh
        case .veryHigh: return .levelExtreme
        }
    }
}
