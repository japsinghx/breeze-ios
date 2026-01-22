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
                
                if viewModel.isOffline && viewModel.hasAttemptedLoad {
                    // No internet connection state
                    NoInternetView(onRetry: {
                        viewModel.retryFetch()
                    })
                } else if viewModel.isLoading && viewModel.airQuality == nil {
                    LoadingView()
                } else if viewModel.airQuality != nil {
                    DashboardView(viewModel: viewModel)
                } else if viewModel.errorMessage != nil && viewModel.hasAttemptedLoad {
                    // Error state
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Something went wrong")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(viewModel.errorMessage ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button("Try Again") {
                            viewModel.retryFetch()
                        }
                        .buttonStyle(.borderedProminent)
                    }
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
                                    .foregroundColor(.secondary)
                                Text("Search for a city")
                                    .foregroundColor(.secondary)
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
                            viewModel.errorMessage = nil
                            viewModel.isOffline = false
                            viewModel.hasAttemptedLoad = false
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
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    // Handle deep link URLs
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "breeze",
              url.host == "location",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }
        
        var lat: Double?
        var lon: Double?
        var name: String?
        
        for item in queryItems {
            switch item.name {
            case "lat":
                lat = Double(item.value ?? "")
            case "lon":
                lon = Double(item.value ?? "")
            case "name":
                name = item.value
            default:
                break
            }
        }
        
        guard let latitude = lat, let longitude = lon else {
            return
        }
        
        // Set location name if provided
        if let locationName = name {
            viewModel.locationName = locationName
        }
        
        // Fetch data for the shared location
        Task {
            await viewModel.fetchAllData(latitude: latitude, longitude: longitude)
        }
    }
}

#Preview {
    ContentView()
}
