import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useFahrenheit") private var useFahrenheit = true
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    
    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceMode) {
                        Label("System", systemImage: "circle.lefthalf.filled")
                            .tag(AppearanceMode.system)
                        Label("Light", systemImage: "sun.max")
                            .tag(AppearanceMode.light)
                        Label("Dark", systemImage: "moon")
                            .tag(AppearanceMode.dark)
                    }
                    .pickerStyle(.inline)
                }
                
                // Temperature Unit
                Section("Preferences") {
                    Toggle(isOn: $useFahrenheit) {
                        Label("Use Fahrenheit", systemImage: "thermometer")
                    }
                }
                
                // About
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://breeze.earth")!) {
                        Label("Website", systemImage: "globe")
                    }
                    
                    Link(destination: URL(string: "https://breeze.earth/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
                
                // Data Sources
                Section("Data Sources") {
                    Link(destination: URL(string: "https://open-meteo.com")!) {
                        HStack {
                            Label("Open-Meteo", systemImage: "cloud")
                            Spacer()
                            Text("Air Quality & Climate")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://developers.google.com/maps/documentation/pollen")!) {
                        HStack {
                            Label("Google Pollen API", systemImage: "leaf")
                            Spacer()
                            Text("Allergy Data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
