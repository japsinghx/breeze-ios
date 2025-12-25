import SwiftUI

struct AQICard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // AQI Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(viewModel.aqiColor.opacity(0.2), lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(
                        viewModel.aqiColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progressValue)
                
                // AQI Value
                VStack(spacing: 4) {
                    Text("\(viewModel.airQuality?.usAQI ?? 0)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.aqiColor)
                    
                    Text("US AQI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            
            // Status
            if let status = viewModel.aqiStatus {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.aqiColor)
                            .frame(width: 12, height: 12)
                        
                        Text(status.text)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.aqiColor)
                    }
                    
                    Text(status.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Health Tips Section - Merged seamlessly
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.pink)
                        
                        Text("What You Can Do")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(spacing: 10) {
                        ForEach(Array(status.tips.enumerated()), id: \.offset) { index, tip in
                            HStack(alignment: .top, spacing: 10) {
                                Circle()
                                    .fill(viewModel.aqiColor.opacity(0.8))
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                
                                Text(tip)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Share button
            ShareLink(
                item: "Air Quality in \(viewModel.locationName): AQI \(viewModel.airQuality?.usAQI ?? 0) - \(viewModel.aqiStatus?.text ?? "Unknown")",
                subject: Text("Air Quality Report"),
                message: Text("Check out the air quality via Breeze!")
            ) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.bordered)
            .tint(viewModel.aqiColor)
        }
        .padding(24)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private var progressValue: CGFloat {
        guard let aqi = viewModel.airQuality?.usAQI else { return 0 }
        // Scale AQI 0-500 to 0-1
        return min(CGFloat(aqi) / 500.0, 1.0)
    }
}

#Preview {
    AQICard(viewModel: DashboardViewModel())
        .padding()
}
