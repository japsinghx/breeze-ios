import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated wind icon
            Image(systemName: "wind")
                .font(.system(size: 60))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text("Loading air quality data...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Skeleton cards
            VStack(spacing: 16) {
                SkeletonCard(height: 200)
                
                HStack(spacing: 12) {
                    SkeletonCard(height: 100)
                    SkeletonCard(height: 100)
                }
                
                HStack(spacing: 12) {
                    SkeletonCard(height: 100)
                    SkeletonCard(height: 100)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct SkeletonCard: View {
    let height: CGFloat
    @State private var isShimmering = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.secondary.opacity(0.1))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isShimmering ? 300 : -300)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isShimmering = true
                }
            }
    }
}

#Preview {
    LoadingView()
}
