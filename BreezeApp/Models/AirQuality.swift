import Foundation

/// Air quality data from Open-Meteo API
struct AirQuality: Codable {
    let usAQI: Int
    let pm25: Double
    let pm10: Double
    let carbonMonoxide: Double
    let nitrogenDioxide: Double
    let sulphurDioxide: Double
    let ozone: Double
    
    enum CodingKeys: String, CodingKey {
        case usAQI = "us_aqi"
        case pm25 = "pm2_5"
        case pm10
        case carbonMonoxide = "carbon_monoxide"
        case nitrogenDioxide = "nitrogen_dioxide"
        case sulphurDioxide = "sulphur_dioxide"
        case ozone
    }
}

/// Response wrapper from Open-Meteo Air Quality API
struct AirQualityResponse: Codable {
    let current: AirQuality?
}

/// AQI status with color and description
struct AQIStatus {
    let text: String
    let emoji: String
    let description: String
    let color: String
    let tips: [String]
    
    static func from(aqi: Int) -> AQIStatus {
        switch aqi {
        case 0...25:
            return AQIStatus(
                text: "Excellent",
                emoji: "✨",
                description: "Air quality is pristine! Perfect day for adventures.",
                color: "aqiGood",
                tips: [
                    "Air is exceptionally clean right now",
                    "No air quality concerns at this level"
                ]
            )
        case 26...50:
            return AQIStatus(
                text: "Good",
                emoji: "😊",
                description: "Air quality is great. Breathe easy!",
                color: "aqiGood",
                tips: [
                    "Air quality meets health standards",
                    "Pollutant levels are low",
                    "No health risks from air quality"
                ]
            )
        case 51...75:
            return AQIStatus(
                text: "Moderate",
                emoji: "😐",
                description: "Air quality is acceptable for most people.",
                color: "aqiModerate",
                tips: [
                    "Air quality is acceptable for most",
                    "Unusually sensitive people may experience minor effects",
                    "Pollutant levels are within moderate range"
                ]
            )
        case 76...100:
            return AQIStatus(
                text: "Slightly High",
                emoji: "😕",
                description: "Getting a bit iffy for sensitive groups.",
                color: "aqiModerate",
                tips: [
                    "Sensitive groups may experience respiratory symptoms",
                    "Air pollutants are at elevated levels",
                    "Those with asthma should have medication available"
                ]
            )
        case 101...150:
            return AQIStatus(
                text: "Unhealthy for Sensitive Groups",
                emoji: "😷",
                description: "Sensitive groups should be cautious.",
                color: "aqiUnhealthySensitive",
                tips: [
                    "Air quality may affect children, elderly, and those with respiratory conditions",
                    "Pollutant concentrations are unhealthy for sensitive groups",
                    "Consider using air purifiers indoors"
                ]
            )
        case 151...200:
            return AQIStatus(
                text: "Unhealthy",
                emoji: "😨",
                description: "Everyone may feel the effects now.",
                color: "aqiUnhealthy",
                tips: [
                    "Air quality is unhealthy for everyone",
                    "Keeping windows closed will help maintain indoor air quality",
                    "Wearing masks can reduce exposure to pollutants"
                ]
            )
        case 201...300:
            return AQIStatus(
                text: "Very Unhealthy",
                emoji: "🚨",
                description: "Serious health concerns for everyone.",
                color: "aqiVeryUnhealthy",
                tips: [
                    "Air pollutants are at dangerous levels",
                    "Indoor air quality is significantly better than outdoor",
                    "Air purifiers can help reduce indoor pollutant levels"
                ]
            )
        default:
            return AQIStatus(
                text: "Hazardous",
                emoji: "☠️",
                description: "Emergency conditions. Seriously bad air.",
                color: "aqiHazardous",
                tips: [
                    "Air quality has reached hazardous levels",
                    "Outdoor air contains dangerous pollutant concentrations",
                    "N95 masks filter harmful particles from the air",
                    "Air purifiers on high settings can improve indoor air"
                ]
            )
        }
    }
}
