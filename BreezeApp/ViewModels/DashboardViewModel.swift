import Foundation
import SwiftUI
import CoreLocation

/// Main view model for the dashboard
@MainActor
class DashboardViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var airQuality: AirQuality?
    @Published var pollutants: [PollutantReading] = []
    @Published var pollenItems: [PollenItem] = []
    @Published var climateData: [ClimateDataPoint] = []
    @Published var locationName: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    @Published var searchResults: [City] = []
    @Published var useFahrenheit = true
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    var aqiStatus: AQIStatus? {
        guard let aqi = airQuality?.usAQI else { return nil }
        return AQIStatus.from(aqi: aqi)
    }
    
    var aqiColor: Color {
        guard let status = aqiStatus else { return .gray }
        switch status.color {
        case "aqiGood": return .aqiGood
        case "aqiModerate": return .aqiModerate
        case "aqiUnhealthySensitive": return .aqiUnhealthySensitive
        case "aqiUnhealthy": return .aqiUnhealthy
        case "aqiVeryUnhealthy": return .aqiVeryUnhealthy
        case "aqiHazardous": return .aqiHazardous
        default: return .gray
        }
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Request user's current location
    func requestLocation() {
        isLoading = true
        errorMessage = nil
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable in Settings."
            isLoading = false
        @unknown default:
            errorMessage = "Unknown location authorization status."
            isLoading = false
        }
    }
    
    /// Search for cities by query
    func searchCities(_ query: String) {
        searchTask?.cancel()
        
        guard query.count >= 2 else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                let results = try await GeocodingService.shared.searchCities(query: query)
                if !Task.isCancelled {
                    self.searchResults = results
                }
            } catch {
                if !Task.isCancelled {
                    print("Search error: \(error)")
                }
            }
        }
    }
    
    /// Select a city from search results
    func selectCity(_ city: City) {
        locationName = city.displayName
        searchResults = []
        searchQuery = ""
        
        Task {
            await fetchAllData(latitude: city.latitude, longitude: city.longitude)
        }
    }
    
    /// Fetch all data for a location
    func fetchAllData(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil
        
        // Fetch air quality
        do {
            let aq = try await AirQualityService.shared.fetchAirQuality(
                latitude: latitude,
                longitude: longitude
            )
            self.airQuality = aq
            
            // Create pollutant readings
            self.pollutants = [
                PollutantReading(type: .pm25, value: aq.pm25),
                PollutantReading(type: .pm10, value: aq.pm10),
                PollutantReading(type: .no2, value: aq.nitrogenDioxide),
                PollutantReading(type: .so2, value: aq.sulphurDioxide),
                PollutantReading(type: .o3, value: aq.ozone),
                PollutantReading(type: .co, value: aq.carbonMonoxide)
            ]
        } catch {
            self.errorMessage = "Unable to fetch air quality data."
            print("Air quality error: \(error)")
        }
        
        // Fetch pollen data (non-blocking)
        Task {
            do {
                let pollen = try await PollenService.shared.fetchPollen(
                    latitude: latitude,
                    longitude: longitude
                )
                self.pollenItems = pollen
            } catch {
                print("Pollen error: \(error)")
            }
        }
        
        // Fetch climate data (non-blocking)
        Task {
            do {
                let climate = try await ClimateService.shared.fetchClimateData(
                    latitude: latitude,
                    longitude: longitude
                )
                self.climateData = climate
            } catch {
                print("Climate error: \(error)")
            }
        }
        
        isLoading = false
    }
    
    /// Format temperature based on unit preference
    func formatTemperature(_ celsius: Double) -> String {
        if useFahrenheit {
            let fahrenheit = (celsius * 9 / 5) + 32
            return String(format: "%.1f°F", fahrenheit)
        }
        return String(format: "%.1f°C", celsius)
    }
    
    /// Format temperature difference
    func formatTemperatureDiff(_ celsiusDiff: Double) -> String {
        let value = useFahrenheit ? celsiusDiff * 9 / 5 : celsiusDiff
        let unit = useFahrenheit ? "°F" : "°C"
        let sign = value >= 0 ? "+" : ""
        return String(format: "%@%.1f%@", sign, value, unit)
    }
}

// MARK: - CLLocationManagerDelegate
extension DashboardViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        locationName = "Your Location"
        
        // Reverse geocode
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let placemark = placemarks?.first {
                var components: [String] = []
                if let city = placemark.locality {
                    components.append(city)
                }
                if let country = placemark.country {
                    components.append(country)
                }
                if !components.isEmpty {
                    self?.locationName = components.joined(separator: ", ")
                }
            }
        }
        
        Task {
            await fetchAllData(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Unable to get your location."
        isLoading = false
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied."
            isLoading = false
        default:
            break
        }
    }
}
