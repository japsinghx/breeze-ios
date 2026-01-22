//
//  BreezeWidget.swift
//  BreezeWidget
//
//  Created by Japmanpreet Singh on 12/26/25.
//

import WidgetKit
import SwiftUI
import CoreLocation

// MARK: - Widget Colors
struct WidgetColors {
    static let good = Color(red: 0.3, green: 0.85, blue: 0.45)
    static let moderate = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let unhealthySensitive = Color(red: 1.0, green: 0.55, blue: 0.2)
    static let unhealthy = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let veryUnhealthy = Color(red: 0.7, green: 0.3, blue: 0.7)
    static let hazardous = Color(red: 0.6, green: 0.2, blue: 0.2)
    
    // Pollen levels
    static let pollenNone = Color.gray
    static let pollenLow = Color(red: 0.3, green: 0.85, blue: 0.45)
    static let pollenModerate = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let pollenHigh = Color(red: 1.0, green: 0.55, blue: 0.2)
    static let pollenVeryHigh = Color(red: 1.0, green: 0.3, blue: 0.3)
    
    // Unavailable
    static let unavailable = Color(white: 0.4)
}

// MARK: - Pollutant Helper
struct WidgetPollutant {
    let name: String
    let value: Double
    let goodLimit: Double
    let moderateLimit: Double
    
    var status: String {
        if value <= goodLimit { return "Good" }
        else if value <= moderateLimit { return "Moderate" }
        else { return "Unhealthy" }
    }
    
    var color: Color {
        if value <= goodLimit { return WidgetColors.good }
        else if value <= moderateLimit { return WidgetColors.moderate }
        else { return WidgetColors.unhealthy }
    }
    
    var icon: String {
        switch name {
        case "PM2.5": return "wind"
        case "PM10": return "cloud"
        case "NO₂": return "car.fill"
        case "SO₂": return "building.2.fill"
        case "O₃": return "sun.max.fill"
        case "CO": return "flame.fill"
        default: return "aqi.medium"
        }
    }
    
    // Higher score = worse
    var severityScore: Double {
        if value <= goodLimit { return value / goodLimit }
        else if value <= moderateLimit { return 1.0 + (value - goodLimit) / (moderateLimit - goodLimit) }
        else { return 2.0 + (value - moderateLimit) / moderateLimit }
    }
}

// MARK: - Timeline Entry
struct AQIEntry: TimelineEntry {
    let date: Date
    let aqi: Int
    let status: String
    var location: String
    
    // Worst pollutant data
    let worstPollutantName: String
    let worstPollutantStatus: String
    let worstPollutantColor: Color
    let worstPollutantIcon: String
    
    // Worst pollen data
    let worstPollenName: String
    let worstPollenStatus: String
    let worstPollenColor: Color
    
    var statusColor: Color {
        switch aqi {
        case 0...50: return WidgetColors.good
        case 51...100: return WidgetColors.moderate
        case 101...150: return WidgetColors.unhealthySensitive
        case 151...200: return WidgetColors.unhealthy
        case 201...300: return WidgetColors.veryUnhealthy
        default: return WidgetColors.hazardous
        }
    }
    
    static var placeholder: AQIEntry {
        AQIEntry(
            date: Date(),
            aqi: 42,
            status: "Good",
            location: "Loading...",
            worstPollutantName: "PM2.5",
            worstPollutantStatus: "Good",
            worstPollutantColor: WidgetColors.good,
            worstPollutantIcon: "wind",
            worstPollenName: "Grass",
            worstPollenStatus: "Low",
            worstPollenColor: WidgetColors.pollenLow
        )
    }
}

// MARK: - API Response Models
struct WidgetAirQualityResponse: Codable {
    let current: WidgetAirQuality?
}

struct WidgetAirQuality: Codable {
    let us_aqi: Int?
    let pm2_5: Double?
    let pm10: Double?
    let carbon_monoxide: Double?
    let nitrogen_dioxide: Double?
    let sulphur_dioxide: Double?
    let ozone: Double?
}

struct WidgetPollenResponse: Codable {
    let dailyInfo: [WidgetDailyPollenInfo]?
}

struct WidgetDailyPollenInfo: Codable {
    let pollenTypeInfo: [WidgetPollenTypeInfo]?
    let plantInfo: [WidgetPlantInfo]?
}

struct WidgetPollenTypeInfo: Codable {
    let displayName: String
    let indexInfo: WidgetIndexInfo?
}

struct WidgetPlantInfo: Codable {
    let displayName: String
    let indexInfo: WidgetIndexInfo?
}

struct WidgetIndexInfo: Codable {
    let value: Int?
    let category: String?
}

// MARK: - Widget Data Service
struct WidgetDataService {
    static let shared = WidgetDataService()
    
    private let airQualityURL = "https://air-quality-api.open-meteo.com/v1/air-quality"
    private let pollenURL = "https://breeze.earth/api/pollen"
    
    func fetchData(latitude: Double, longitude: Double) async -> AQIEntry {
        async let airQualityResult = fetchAirQuality(latitude: latitude, longitude: longitude)
        async let pollenResult = fetchPollen(latitude: latitude, longitude: longitude)
        
        let (airQuality, pollen) = await (airQualityResult, pollenResult)
        
        // Calculate AQI status
        let aqi = airQuality?.us_aqi ?? 42
        let status = getAQIStatus(aqi)
        
        // Find worst pollutant
        let pollutants = createPollutants(from: airQuality)
        let worstPollutant = pollutants.max(by: { $0.severityScore < $1.severityScore })
        
        // Find worst pollen
        let (worstPollenName, worstPollenValue) = findWorstPollen(from: pollen)
        let (pollenStatus, pollenColor) = getPollenStatusAndColor(value: worstPollenValue)
        
        return AQIEntry(
            date: Date(),
            aqi: aqi,
            status: status,
            location: "Current Location",
            worstPollutantName: worstPollutant?.name ?? "PM2.5",
            worstPollutantStatus: worstPollutant?.status ?? "Good",
            worstPollutantColor: worstPollutant?.color ?? WidgetColors.good,
            worstPollutantIcon: worstPollutant?.icon ?? "wind",
            worstPollenName: worstPollenName,
            worstPollenStatus: pollenStatus,
            worstPollenColor: pollenColor
        )
    }
    
    private func fetchAirQuality(latitude: Double, longitude: Double) async -> WidgetAirQuality? {
        let urlString = "\(airQualityURL)?latitude=\(latitude)&longitude=\(longitude)&current=us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone&timezone=auto"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WidgetAirQualityResponse.self, from: data)
            return response.current
        } catch {
            print("Widget: Failed to fetch air quality: \(error)")
            return nil
        }
    }
    
    private func fetchPollen(latitude: Double, longitude: Double) async -> WidgetPollenResponse? {
        let urlString = "\(pollenURL)?lat=\(latitude)&lon=\(longitude)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WidgetPollenResponse.self, from: data)
            return response
        } catch {
            print("Widget: Failed to fetch pollen: \(error)")
            return nil
        }
    }
    
    private func getAQIStatus(_ aqi: Int) -> String {
        switch aqi {
        case 0...50: return "Good"
        case 51...100: return "Moderate"
        case 101...150: return "Unhealthy for Sensitive"
        case 151...200: return "Unhealthy"
        case 201...300: return "Very Unhealthy"
        default: return "Hazardous"
        }
    }
    
    private func createPollutants(from airQuality: WidgetAirQuality?) -> [WidgetPollutant] {
        guard let aq = airQuality else { return [] }
        
        return [
            WidgetPollutant(name: "PM2.5", value: aq.pm2_5 ?? 0, goodLimit: 12, moderateLimit: 35.4),
            WidgetPollutant(name: "PM10", value: aq.pm10 ?? 0, goodLimit: 54, moderateLimit: 154),
            WidgetPollutant(name: "NO₂", value: aq.nitrogen_dioxide ?? 0, goodLimit: 53, moderateLimit: 100),
            WidgetPollutant(name: "SO₂", value: aq.sulphur_dioxide ?? 0, goodLimit: 35, moderateLimit: 75),
            WidgetPollutant(name: "O₃", value: aq.ozone ?? 0, goodLimit: 54, moderateLimit: 70),
            WidgetPollutant(name: "CO", value: aq.carbon_monoxide ?? 0, goodLimit: 4400, moderateLimit: 9400)
        ]
    }
    
    private func findWorstPollen(from response: WidgetPollenResponse?) -> (name: String, value: Int) {
        // Return -1 value to indicate unavailable/failed to fetch
        guard let dailyInfo = response?.dailyInfo?.first else {
            return ("Unavailable", -1)
        }
        
        var worstName = "Healthy"
        var worstValue = 0
        
        // Check pollen types (Grass, Tree, Weed)
        if let types = dailyInfo.pollenTypeInfo {
            for type in types {
                let value = type.indexInfo?.value ?? 0
                if value > worstValue {
                    worstValue = value
                    worstName = type.displayName
                }
            }
        }
        
        // Check specific plants
        if let plants = dailyInfo.plantInfo {
            for plant in plants {
                let value = plant.indexInfo?.value ?? 0
                if value > worstValue {
                    worstValue = value
                    worstName = plant.displayName
                }
            }
        }
        
        return (worstName, worstValue)
    }
    
    private func getPollenStatusAndColor(value: Int) -> (status: String, color: Color) {
        switch value {
        case ..<0:
            return ("Unavailable", WidgetColors.unavailable)
        case 0:
            return ("Healthy", WidgetColors.pollenLow)
        case 1:
            return ("Low", WidgetColors.pollenLow)
        case 2...3:
            return ("Moderate", WidgetColors.pollenModerate)
        case 4:
            return ("High", WidgetColors.pollenHigh)
        default:
            return ("Very High", WidgetColors.pollenVeryHigh)
        }
    }
}

// MARK: - Location Manager for Widget
class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation?, Never>?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func getCurrentLocation() async -> CLLocation? {
        // Widgets inherit location permission from the main app
        // We just need to check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations.first)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Widget location error: \(error)")
        continuation?.resume(returning: nil)
        continuation = nil
    }
}

// MARK: - Timeline Provider
struct AQIProvider: TimelineProvider {
    private let locationManager = WidgetLocationManager()
    
    // Default location (San Francisco) if location services unavailable
    private let defaultLatitude = 37.7749
    private let defaultLongitude = -122.4194
    
    func placeholder(in context: Context) -> AQIEntry {
        AQIEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AQIEntry) -> Void) {
        if context.isPreview {
            completion(AQIEntry.placeholder)
        } else {
            Task {
                let entry = await fetchEntry()
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AQIEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            // Refresh every 30 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
    
    private func fetchEntry() async -> AQIEntry {
        // Try to get location from shared UserDefaults (saved by main app)
        var latitude = defaultLatitude
        var longitude = defaultLongitude
        var locationName = "Current Location"
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.japmanpreet.breeze") {
            let savedLat = sharedDefaults.double(forKey: "userLatitude")
            let savedLon = sharedDefaults.double(forKey: "userLongitude")
            
            // Check if we have valid saved coordinates (not 0,0)
            if savedLat != 0 || savedLon != 0 {
                latitude = savedLat
                longitude = savedLon
                locationName = sharedDefaults.string(forKey: "userLocationName") ?? "Current Location"
            }
        }
        
        var entry = await WidgetDataService.shared.fetchData(latitude: latitude, longitude: longitude)
        entry.location = locationName
        return entry
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    var entry: AQIEntry
    @Environment(\.widgetContentMargins) var margins
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                // Header
                HStack(spacing: 6) {
                    Image(systemName: "wind")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("AIR QUALITY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(0.5)
                }
                
                Spacer()
                
                // AQI Value - scales with widget size
                Text("\(entry.aqi)")
                    .font(.system(size: geometry.size.height * 0.35, weight: .bold, design: .rounded))
                    .foregroundColor(entry.statusColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                // Status
                Text(entry.status)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 8))
                    Text(entry.location)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundColor(.white.opacity(0.4))
            }
            .padding(margins)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    var entry: AQIEntry
    @Environment(\.widgetContentMargins) var margins
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - AQI
                VStack(alignment: .leading) {
                    // Header
                    HStack(spacing: 6) {
                        Image(systemName: "wind")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("AIR QUALITY")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(0.5)
                    }
                    
                    Spacer()
                    
                    // AQI Value - scales with widget size
                    Text("\(entry.aqi)")
                        .font(.system(size: geometry.size.height * 0.4, weight: .bold, design: .rounded))
                        .foregroundColor(entry.statusColor)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    
                    // Status
                    Text(entry.status)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                        Text(entry.location)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Divider
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, geometry.size.height * 0.12)
                
                // Right side - Pollutant & Allergy
                VStack(alignment: .leading, spacing: 0) {
                    // Pollutant Info
                    VStack(alignment: .leading, spacing: 5) {
                        Text("POLLUTANT INFO")
                            .font(.system(size: 8, weight: .bold))
                            .tracking(0.3)
                            .foregroundColor(.white.opacity(0.35))
                        
                        // Only show Healthy badge when all pollutants are good, otherwise show icon + name + badge
                        if entry.worstPollutantStatus == "Good" {
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(WidgetColors.good)
                                
                                Text("Healthy")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(WidgetColors.good)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(WidgetColors.good.opacity(0.15))
                                    )
                            }
                        } else {
                            HStack(spacing: 5) {
                                Image(systemName: entry.worstPollutantIcon)
                                    .font(.system(size: 12))
                                    .foregroundColor(entry.worstPollutantColor)
                                
                                Text(entry.worstPollutantName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(entry.worstPollutantStatus)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(entry.worstPollutantColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(entry.worstPollutantColor.opacity(0.15))
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Allergy Info (formerly Pollen Info)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ALLERGY INFO")
                            .font(.system(size: 8, weight: .bold))
                            .tracking(0.3)
                            .foregroundColor(.white.opacity(0.35))
                        
                        // Handle three states: Unavailable, Healthy, or elevated pollen
                        if entry.worstPollenName == "Unavailable" {
                            HStack(spacing: 5) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(WidgetColors.unavailable)
                                
                                Text("Unavailable")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(WidgetColors.unavailable)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(WidgetColors.unavailable.opacity(0.15))
                                    )
                            }
                        } else if entry.worstPollenName == "Healthy" {
                            HStack(spacing: 5) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(WidgetColors.pollenLow)
                                
                                Text("Healthy")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(WidgetColors.pollenLow)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(WidgetColors.pollenLow.opacity(0.15))
                                    )
                            }
                        } else {
                            HStack(spacing: 5) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(entry.worstPollenColor)
                                
                                Text(entry.worstPollenName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(entry.worstPollenStatus)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(entry.worstPollenColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(entry.worstPollenColor.opacity(0.15))
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Updated time - aligned to right
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 9))
                            Text(entry.date, style: .relative)
                                .font(.system(size: 10, weight: .medium))
                            + Text(" ago")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.4))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            }
            .padding(margins)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Main Widget View
struct BreezeWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: AQIEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration
struct BreezeWidget: Widget {
    let kind: String = "BreezeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AQIProvider()) { entry in
            BreezeWidgetView(entry: entry)
                .containerBackground(Color(red: 0.1, green: 0.1, blue: 0.12), for: .widget)
        }
        .configurationDisplayName("Air Quality")
        .description("View current air quality at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    BreezeWidget()
} timeline: {
    AQIEntry.placeholder
}

#Preview(as: .systemMedium) {
    BreezeWidget()
} timeline: {
    AQIEntry(
        date: .now,
        aqi: 42,
        status: "Good",
        location: "San Francisco",
        worstPollutantName: "PM2.5",
        worstPollutantStatus: "Moderate",
        worstPollutantColor: WidgetColors.moderate,
        worstPollutantIcon: "wind",
        worstPollenName: "Grass",
        worstPollenStatus: "High",
        worstPollenColor: WidgetColors.pollenHigh
    )
}
