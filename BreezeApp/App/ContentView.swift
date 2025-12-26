import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showSearch = false
    @State private var showSettings = false
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.airQuality == nil {
                    LoadingView()
                } else if let airQuality = viewModel.airQuality {
                    DashboardView(viewModel: viewModel)
                } else {
                    // Landing view
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Logo and text on same line
                        HStack(spacing: 12) {
                            Image(systemName: "wind")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.linearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                            
                            Text("Breeze")
                                .font(.system(size: 36, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        AnimatedText(text: "Take a deep breath")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Search button
                        Button {
                            showSearch = true
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search for a city")
                                Spacer()
                            }
                            .padding()
                            .background(Color.searchBarBackground)
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                        
                        // Use current location button
                        Button {
                            viewModel.requestLocation()
                        } label: {
                            Label("Use My Location", systemImage: "location.circle.fill")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.airQuality != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            // Clear data to go back to landing page
                            viewModel.airQuality = nil
                            viewModel.pollutants = []
                            viewModel.pollenItems = []
                            viewModel.climateData = []
                            viewModel.locationName = ""
                        } label: {
                            Image(systemName: "house")
                                .font(.body)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            Button {
                                showSearch = true
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView(viewModel: viewModel)
                    .preferredColorScheme(appearanceMode.colorScheme)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .preferredColorScheme(appearanceMode.colorScheme)
            }
        }
        .preferredColorScheme(appearanceMode.colorScheme)
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
