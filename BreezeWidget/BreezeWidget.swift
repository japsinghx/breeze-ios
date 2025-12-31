//
//  BreezeWidget.swift
//  BreezeWidget
//
//  Created by Japmanpreet Singh on 12/26/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct AQIEntry: TimelineEntry {
    let date: Date
    let aqi: Int
    let status: String
    let location: String
    
    var statusColor: Color {
        switch aqi {
        case 0...50: return Color(red: 0.3, green: 0.85, blue: 0.45)
        case 51...100: return Color(red: 1.0, green: 0.8, blue: 0.2)
        case 101...150: return Color(red: 1.0, green: 0.55, blue: 0.2)
        case 151...200: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case 201...300: return Color(red: 0.7, green: 0.3, blue: 0.7)
        default: return Color(red: 0.6, green: 0.2, blue: 0.2)
        }
    }
}

// MARK: - Timeline Provider
struct AQIProvider: TimelineProvider {
    func placeholder(in context: Context) -> AQIEntry {
        AQIEntry(date: Date(), aqi: 42, status: "Good", location: "San Francisco")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AQIEntry) -> Void) {
        completion(AQIEntry(date: Date(), aqi: 42, status: "Good", location: "Current Location"))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AQIEntry>) -> Void) {
        let entry = AQIEntry(date: Date(), aqi: 42, status: "Good", location: "Current Location")
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Divider
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, geometry.size.height * 0.15)
                
                // Right side - Details
                VStack(alignment: .leading) {
                    // Location
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LOCATION")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(0.5)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 9))
                            Text(entry.location)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                        }
                        .foregroundColor(.white.opacity(0.75))
                    }
                    
                    Spacer()
                    
                    // Progress bar
                    VStack(alignment: .leading, spacing: 6) {
                        Text("INDEX")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(0.5)
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.white.opacity(0.12))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(entry.statusColor)
                                .frame(width: (geometry.size.width * 0.35) * min(CGFloat(entry.aqi) / 200, 1.0), height: 6)
                        }
                    }
                    
                    Spacer()
                    
                    // Updated
                    VStack(alignment: .leading, spacing: 4) {
                        Text("UPDATED")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(0.5)
                        
                        Text(entry.date, style: .relative)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
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
    AQIEntry(date: .now, aqi: 42, status: "Good", location: "San Francisco")
}

#Preview(as: .systemMedium) {
    BreezeWidget()
} timeline: {
    AQIEntry(date: .now, aqi: 42, status: "Good", location: "San Francisco")
}
