import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var breatheScale: CGFloat = 1.0
    @State private var messageIndex = 0
    
    private let loadingMessages = [
        "Checking the air around you...",
        "Counting pollen particles...",
        "Measuring the invisible...",
        "Making sense of molecules...",
        "Almost there..."
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Breathing animation - inspired by Apple Watch breathe
            ZStack {
                // Outer breathing circles
                ForEach(0..<6) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.4),
                                    Color.cyan.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .offset(y: breatheScale > 1.0 ? -30 : 0)
                        .rotationEffect(.degrees(Double(index) * 60))
                        .scaleEffect(breatheScale)
                        .opacity(0.6)
                }
                
                // Center icon
                Image(systemName: "wind")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 10)
            }
            .frame(height: 200)
            
            // Loading message with typewriter feel
            VStack(spacing: 12) {
                Text(loadingMessages[messageIndex])
                    .font(.headline)
                    .foregroundColor(.primary)
                    .animation(.easeInOut(duration: 0.3), value: messageIndex)
                    .id(messageIndex) // Force view refresh for animation
                
                // Minimal dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .opacity(isAnimating ? 1.0 : 0.3)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.15),
                                value: isAnimating
                            )
                    }
                }
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            isAnimating = true
            
            // Breathing animation
            withAnimation(
                .easeInOut(duration: 4)
                .repeatForever(autoreverses: true)
            ) {
                breatheScale = 1.3
            }
            
            // Cycle messages
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
                withAnimation(.easeInOut) {
                    messageIndex = (messageIndex + 1) % loadingMessages.count
                }
            }
        }
    }
}

#Preview {
    LoadingView()
        .background(Color(.systemGroupedBackground))
}
