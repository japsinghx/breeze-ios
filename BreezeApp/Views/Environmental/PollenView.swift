import SwiftUI

struct PollenView: View {
    let items: [PollenItem]
    @State private var selectedPollen: PollenItem?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("Allergy Tracker")
                    .font(.headline)
                
                Spacer()
                
                Text("Powered by Google")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            if items.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.circle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No pollen data available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(items) { item in
                        PollenItemCard(item: item)
                            .onTapGesture {
                                selectedPollen = item
                            }
                    }
                }
            }
        }
        .sheet(item: $selectedPollen) { pollen in
            PollenDetailSheet(pollen: pollen)
                .presentationDetents([.medium])
        }
    }
}

struct PollenItemCard: View {
    let item: PollenItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("\(item.value)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(item.level.color)
                    
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(item.level.color)
                        .frame(width: geometry.size.width * CGFloat(item.value) / 5.0, height: 6)
                }
            }
            .frame(height: 6)
            
            Text(item.level.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PollenDetailSheet: View {
    let pollen: PollenItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .font(.title)
                                .foregroundColor(.green)
                            
                            Spacer()
                        }
                        
                        Text(pollen.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(pollen.isPlant ? "Plant Pollen" : "Pollen Type")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Plant Image
                    if let imageUrl = pollen.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            case .failure:
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Current Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Level")
                            .font(.headline)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(pollen.value)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(pollen.level.color)
                            
                            Text("(\(pollen.level.rawValue))")
                                .font(.body)
                                .foregroundColor(pollen.level.color)
                        }
                    }
                    
                    // Level Scale
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pollen Index Scale")
                            .font(.headline)
                        
                        VStack(spacing: 4) {
                            PollenScaleRow(level: "None", range: "0", color: .levelNone, isActive: pollen.value == 0)
                            PollenScaleRow(level: "Low", range: "1", color: .levelLow, isActive: pollen.value == 1)
                            PollenScaleRow(level: "Moderate", range: "2-3", color: .levelModerate, isActive: pollen.value >= 2 && pollen.value <= 3)
                            PollenScaleRow(level: "High", range: "4", color: .levelHigh, isActive: pollen.value == 4)
                            PollenScaleRow(level: "Very High", range: "5", color: .levelExtreme, isActive: pollen.value >= 5)
                        }
                    }
                    
                    // About this Plant
                    if pollen.family != nil || pollen.season != nil || pollen.appearance != nil {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About this Plant")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                if let family = pollen.family {
                                    HStack(alignment: .top) {
                                        Text("Family:")
                                            .fontWeight(.semibold)
                                        Text(family)
                                            .foregroundColor(.secondary)
                                    }
                                    .font(.subheadline)
                                }
                                
                                if let season = pollen.season {
                                    HStack(alignment: .top) {
                                        Text("Season:")
                                            .fontWeight(.semibold)
                                        Text(season)
                                            .foregroundColor(.secondary)
                                    }
                                    .font(.subheadline)
                                }
                                
                                if let appearance = pollen.appearance {
                                    HStack(alignment: .top) {
                                        Text("Appearance:")
                                            .fontWeight(.semibold)
                                        Text(appearance)
                                            .foregroundColor(.secondary)
                                    }
                                    .font(.subheadline)
                                }
                            }
                        }
                    }
                    
                    // Health Recommendations
                    if let recommendations = pollen.healthRecommendations, !recommendations.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Health Recommendations")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(.secondary)
                                        Text(recommendation)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct PollenScaleRow: View {
    let level: String
    let range: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(level)
                .font(.subheadline)
            
            Spacer()
            
            Text(range)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isActive ? color.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PollenView(items: [
        PollenItem(id: "GRASS", name: "Grass", value: 3, category: "Moderate", isPlant: false, imageUrl: nil, family: nil, season: nil, appearance: nil, healthRecommendations: nil),
        PollenItem(id: "TREE", name: "Tree", value: 2, category: "Low", isPlant: false, imageUrl: nil, family: nil, season: nil, appearance: nil, healthRecommendations: nil),
        PollenItem(id: "WEED", name: "Weed", value: 4, category: "High", isPlant: false, imageUrl: nil, family: nil, season: nil, appearance: nil, healthRecommendations: nil),
        PollenItem(id: "RAGWEED", name: "Ragweed", value: 1, category: "Low", isPlant: true, imageUrl: nil, family: nil, season: nil, appearance: nil, healthRecommendations: nil)
    ])
    .padding()
}
