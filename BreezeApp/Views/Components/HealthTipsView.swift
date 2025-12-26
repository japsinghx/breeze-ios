import SwiftUI

struct HealthTipsView: View {
    let tips: [String]
    var aqiColor: Color = .pink
    @State private var showTips = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.pink.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.pink)
                }
                
                Text("What You Can Do")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            // Tips with staggered animation
            VStack(spacing: 14) {
                ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.green)
                        
                        Text(tip)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .opacity(showTips ? 1 : 0)
                    .offset(x: showTips ? 0 : -20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: showTips
                    )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            showTips = true
        }
    }
}

#Preview {
    HealthTipsView(tips: [
        "Air quality meets health standards 👍",
        "Great day for outdoor activities ✨",
        "No special precautions needed 🌬️"
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
}
