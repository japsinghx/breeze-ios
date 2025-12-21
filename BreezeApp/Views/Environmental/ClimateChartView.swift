import SwiftUI
import Charts

struct ClimateChartView: View {
    let data: [ClimateDataPoint]
    @Binding var useFahrenheit: Bool
    let formatTemp: (Double) -> String
    let formatDiff: (Double) -> String
    
    private var temperatureChange: Double {
        guard let first = data.first, let last = data.last else { return 0 }
        return last.temperature - first.temperature
    }
    
    private var baselineYear: Int {
        data.first?.year ?? 1980
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.orange)
                        Text("Local Climate Trend")
                            .font(.headline)
                    }
                    
                    Text("Temperature on this day across decades")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Unit toggle
                Toggle(isOn: $useFahrenheit) {
                    Text(useFahrenheit ? "°F" : "°C")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .toggleStyle(.button)
                .buttonStyle(.bordered)
                .tint(useFahrenheit ? .orange : .blue)
            }
            
            // Change summary
            HStack {
                Text("Change since \(baselineYear)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatDiff(temperatureChange))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(temperatureChange > 0 ? .red : .blue)
            }
            .padding(.vertical, 8)
            
            // Chart
            if #available(iOS 16.0, *) {
                Chart(data) { point in
                    BarMark(
                        x: .value("Year", String(point.year)),
                        y: .value("Temp", displayTemperature(point.temperature))
                    )
                    .foregroundStyle(barColor(for: point))
                    .cornerRadius(4)
                    .annotation(position: .top) {
                        Text(formatTemp(point.temperature))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            } else {
                // Fallback for older iOS
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data) { point in
                        VStack {
                            Text(formatTemp(point.temperature))
                                .font(.caption2)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(barColor(for: point))
                                .frame(height: barHeight(for: point))
                            
                            Text(String(point.year))
                                .font(.caption2)
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func displayTemperature(_ celsius: Double) -> Double {
        useFahrenheit ? (celsius * 9 / 5) + 32 : celsius
    }
    
    private func barColor(for point: ClimateDataPoint) -> Color {
        guard let baseline = data.first else { return .gray }
        let diff = point.temperature - baseline.temperature
        
        if diff > 2 {
            return .red
        } else if diff > 0.5 {
            return .orange
        } else if diff < -0.5 {
            return .blue
        } else {
            return .gray
        }
    }
    
    private func barHeight(for point: ClimateDataPoint) -> CGFloat {
        let temps = data.map { $0.temperature }
        guard let minTemp = temps.min(), let maxTemp = temps.max() else { return 50 }
        let range = maxTemp - minTemp
        guard range > 0 else { return 50 }
        
        let normalized = (point.temperature - minTemp) / range
        return CGFloat(normalized) * 100 + 30
    }
}

#Preview {
    ClimateChartView(
        data: [
            ClimateDataPoint(year: 1980, temperature: 18.5),
            ClimateDataPoint(year: 1990, temperature: 19.2),
            ClimateDataPoint(year: 2000, temperature: 19.8),
            ClimateDataPoint(year: 2010, temperature: 20.1),
            ClimateDataPoint(year: 2020, temperature: 20.8),
            ClimateDataPoint(year: 2024, temperature: 21.2)
        ],
        useFahrenheit: .constant(true),
        formatTemp: { String(format: "%.1f°F", ($0 * 9/5) + 32) },
        formatDiff: { String(format: "%+.1f°F", $0 * 9/5) }
    )
    .padding()
}
