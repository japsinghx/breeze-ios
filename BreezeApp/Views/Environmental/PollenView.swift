import SwiftUI

struct PollenView: View {
    let items: [PollenItem]
    @State private var selectedPollen: PollenItem?
    @State private var detentSelection: PresentationDetent = .large
    
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
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(items) { item in
                        PollenItemCard(item: item)
                            .onTapGesture {
                                selectedPollen = item
                                detentSelection = .large
                            }
                    }
                }
            }
        }
        .sheet(item: $selectedPollen) { pollen in
            PollenDetailSheet(pollen: pollen)
                .presentationDetents([.large, .medium], selection: $detentSelection)
                .presentationDragIndicator(.visible)
        }
    }
}

struct PollenItemCard: View {
    let item: PollenItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with name, value, and chevron
            HStack(alignment: .center, spacing: 6) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(item.value)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(item.level.color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
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
            
            // Level label
            Text(item.level.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PollenDetailSheet: View {
    let pollen: PollenItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section - moved higher with less padding
                    VStack(spacing: 12) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(pollen.level.color.opacity(0.15))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(pollen.level.color)
                        }
                        
                        // Name
                        VStack(spacing: 4) {
                            Text(pollen.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(pollen.isPlant ? "Plant Pollen" : "Pollen Type")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Current level card - shrunk
                    VStack(spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(pollen.value)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundColor(pollen.level.color)
                            
                            Text("/ 5")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        // Status badge
                        Text(pollen.level.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(pollen.level.color)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Plant Image (if available) - made bigger
                    if let imageUrl = pollen.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 260)
                                    .background(Color.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 260)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            case .failure:
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    // About this Plant - moved below image
                    if pollen.family != nil || pollen.season != nil || pollen.appearance != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About this Plant")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                if let family = pollen.family {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Family")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                        Text(family)
                                            .font(.subheadline)
                                    }
                                }
                                
                                if let season = pollen.season {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Season")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                        Text(season)
                                            .font(.subheadline)
                                    }
                                }
                                
                                if let appearance = pollen.appearance {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Appearance")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                        Text(appearance)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Health Recommendations
                    if let recommendations = pollen.healthRecommendations, !recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.pink)
                                
                                Text("What You Can Do")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 10) {
                                        Circle()
                                            .fill(pollen.level.color.opacity(0.8))
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        
                                        Text(recommendation)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Pollen Index Scale - moved to bottom
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pollen Index Scale")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            PollenScaleRow(
                                level: "None",
                                range: "0",
                                color: .levelNone,
                                isActive: pollen.value == 0
                            )
                            
                            PollenScaleRow(
                                level: "Low",
                                range: "1",
                                color: .levelLow,
                                isActive: pollen.value == 1
                            )
                            
                            PollenScaleRow(
                                level: "Moderate",
                                range: "2-3",
                                color: .levelModerate,
                                isActive: pollen.value >= 2 && pollen.value <= 3
                            )
                            
                            PollenScaleRow(
                                level: "High",
                                range: "4",
                                color: .levelHigh,
                                isActive: pollen.value == 4
                            )
                            
                            PollenScaleRow(
                                level: "Very High",
                                range: "5",
                                color: .levelExtreme,
                                isActive: pollen.value >= 5
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
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
