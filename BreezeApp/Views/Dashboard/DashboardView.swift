import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Location Header
                VStack(spacing: 4) {
                    Text(viewModel.locationName)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text(Date().formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // AQI Card
                AQICard(viewModel: viewModel)
                
                // Pollen Section
                if !viewModel.pollenItems.isEmpty {
                    PollenView(items: viewModel.pollenItems)
                }
                
                // Pollutants Grid
                PollutantsGrid(pollutants: viewModel.pollutants)
                
                // Climate Chart
                if !viewModel.climateData.isEmpty {
                    ClimateChartView(
                        data: viewModel.climateData,
                        useFahrenheit: $viewModel.useFahrenheit,
                        formatTemp: viewModel.formatTemperature,
                        formatDiff: viewModel.formatTemperatureDiff
                    )
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .refreshable {
            // Refresh data when pulled down
            if let coords = getCurrentCoordinates() {
                await viewModel.fetchAllData(latitude: coords.lat, longitude: coords.lon)
            }
        }
    }
    
    private func getCurrentCoordinates() -> (lat: Double, lon: Double)? {
        // For refresh, we'd ideally store the current coordinates
        // For now, return nil to skip refresh
        return nil
    }
}

#Preview {
    let viewModel = DashboardViewModel()
    return DashboardView(viewModel: viewModel)
}
