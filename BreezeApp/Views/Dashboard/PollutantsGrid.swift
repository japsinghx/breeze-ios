import SwiftUI

struct PollutantsGrid: View {
    let pollutants: [PollutantReading]
    @State private var selectedPollutant: PollutantReading?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Air Quality Details")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // Pollutant Cards - Apple-style list
            VStack(spacing: 1) {
                ForEach(Array(pollutants.enumerated()), id: \.element.id) { index, pollutant in
                    PollutantRow(pollutant: pollutant)
                        .onTapGesture {
                            selectedPollutant = pollutant
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        // Round top corners for first item
                        .clipShape(
                            RoundedCorner(
                                radius: index == 0 ? 12 : 0,
                                corners: index == 0 ? [.topLeft, .topRight] : []
                            )
                        )
                        // Round bottom corners for last item
                        .clipShape(
                            RoundedCorner(
                                radius: index == pollutants.count - 1 ? 12 : 0,
                                corners: index == pollutants.count - 1 ? [.bottomLeft, .bottomRight] : []
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .sheet(item: $selectedPollutant) { pollutant in
            PollutantDetailSheet(pollutant: pollutant)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// Custom shape for individual corner rounding
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct PollutantRow: View {
    let pollutant: PollutantReading
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with colored background
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(pollutant.status.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: pollutant.type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(pollutant.status.color)
            }
            
            // Name and description
            VStack(alignment: .leading, spacing: 2) {
                Text(pollutant.type.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(pollutant.type.fullName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Value and status
            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(pollutant.roundedValue)")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text(pollutant.type.unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(pollutant.status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(pollutant.status.color)
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct PollutantDetailSheet: View {
    let pollutant: PollutantReading
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero section
                    VStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(pollutant.status.color.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: pollutant.type.icon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(pollutant.status.color)
                        }
                        
                        // Name
                        VStack(spacing: 4) {
                            Text(pollutant.type.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(pollutant.type.fullName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Current reading card
                    VStack(spacing: 12) {
                        Text("Current Level")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(pollutant.roundedValue)")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(pollutant.status.color)
                            
                            Text(pollutant.type.unit)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        // Status badge
                        Text(pollutant.status.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(pollutant.status.color)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // About section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline)
                        
                        Text(pollutant.type.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Health ranges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health Ranges")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            RangeRow(
                                label: "Good",
                                range: "0–\(Int(pollutant.type.goodLimit)) \(pollutant.type.unit)",
                                color: .aqiGood,
                                isActive: pollutant.status == .good
                            )
                            
                            RangeRow(
                                label: "Moderate",
                                range: "\(Int(pollutant.type.goodLimit))–\(Int(pollutant.type.moderateLimit)) \(pollutant.type.unit)",
                                color: .aqiModerate,
                                isActive: pollutant.status == .moderate
                            )
                            
                            RangeRow(
                                label: "Unhealthy",
                                range: ">\(Int(pollutant.type.moderateLimit)) \(pollutant.type.unit)",
                                color: .aqiUnhealthy,
                                isActive: pollutant.status == .unhealthy
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
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

struct RangeRow: View {
    let label: String
    let range: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .regular)
            }
            
            Spacer()
            
            Text(range)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(isActive ? color.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    PollutantsGrid(pollutants: [
        PollutantReading(type: .pm25, value: 15),
        PollutantReading(type: .pm10, value: 30),
        PollutantReading(type: .no2, value: 45),
        PollutantReading(type: .so2, value: 20),
        PollutantReading(type: .o3, value: 55),
        PollutantReading(type: .co, value: 3000)
    ])
    .padding()
}
