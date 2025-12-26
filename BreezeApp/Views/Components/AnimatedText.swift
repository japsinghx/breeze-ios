import SwiftUI

struct AnimatedText: View {
    let text: String
    @State private var animatedCharacters: [Bool] = []
    @State private var hasCompleted = false
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .opacity(animatedCharacters.indices.contains(index) && animatedCharacters[index] ? 1 : 0)
                    .offset(y: animatedCharacters.indices.contains(index) && animatedCharacters[index] ? 0 : 15)
                    .blur(radius: animatedCharacters.indices.contains(index) && animatedCharacters[index] ? 0 : 4)
            }
        }
        // Subtle floating animation after text appears
        .offset(y: hasCompleted ? -2 : 0)
        .animation(
            hasCompleted ? .easeInOut(duration: 2.5).repeatForever(autoreverses: true) : .default,
            value: hasCompleted
        )
        .onAppear {
            animatedCharacters = Array(repeating: false, count: text.count)
            
            // Animate each character
            for index in text.indices {
                let delay = Double(text.distance(from: text.startIndex, to: index)) * 0.08
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        animatedCharacters[text.distance(from: text.startIndex, to: index)] = true
                    }
                }
            }
            
            // Start floating after animation completes
            let totalDuration = Double(text.count) * 0.08 + 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                hasCompleted = true
            }
        }
    }
}

#Preview {
    AnimatedText(text: "Take a deep breath")
        .font(.title3)
        .foregroundColor(.secondary)
}
