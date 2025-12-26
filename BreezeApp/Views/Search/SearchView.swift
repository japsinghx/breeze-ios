import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    if #available(iOS 17.0, *) {
                        TextField("Search for a city", text: $viewModel.searchQuery)
                            .focused($isSearchFocused)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .onChange(of: viewModel.searchQuery) { _, newValue in
                                viewModel.searchCities(newValue)
                            }
                    } else {
                        // Fallback for iOS 16 and earlier
                        TextField("Search for a city", text: $viewModel.searchQuery)
                            .focused($isSearchFocused)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled(true)
                            .onChange(of: viewModel.searchQuery) { newValue in
                                viewModel.searchCities(newValue)
                            }
                    }
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                            viewModel.searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color.searchBarBackground)
                .clipShape(Capsule())
                .padding()
                
                // Use current location
                Button {
                    dismiss()
                    viewModel.requestLocation()
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.accentColor)
                        
                        Text("Use Current Location")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                // Search results
                if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { city in
                        Button {
                            viewModel.selectCity(city)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.name)
                                    .font(.headline)
                                
                                Text(city.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                } else if viewModel.searchQuery.count >= 2 {
                    VStack {
                        Spacer()
                        Text("No results found")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    // Popular cities
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Popular Cities")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(TopCity.all.prefix(10), id: \.name) { city in
                                    Button {
                                        viewModel.locationName = "\(city.name), \(city.country)"
                                        dismiss()
                                        Task {
                                            await viewModel.fetchAllData(latitude: city.lat, longitude: city.lon)
                                        }
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(city.name)
                                                    .font(.body)
                                                Text(city.country)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Divider()
                                        .padding(.leading)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            isSearchFocused = true
        }
    }
}

#Preview {
    SearchView(viewModel: DashboardViewModel())
}
