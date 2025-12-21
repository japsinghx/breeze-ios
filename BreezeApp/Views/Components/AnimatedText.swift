import SwiftUI

struct AnimatedText: View {
    let text: String
    @State private var animatedCharacters: [Bool] = []
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .opacity(animatedCharacters.indices.contains(index) && animatedCharacters[index] ? 1 : 0)
                    .offset(y: animatedCharacters.indices.contains(index) && animatedCharacters[index] ? 0 : 20)
                    .blur(radius: animatedCharacters.indices.contains(index) && animatedCharacters[index] ? 0 : 8)
            }
        }
        .onAppear {
            // Initialize array
            animatedCharacters = Array(repeating: false, count: text.count)
            
            // Animate each character with delay
            for index in text.indices {
                let delay = Double(text.distance(from: text.startIndex, to: index)) * 0.12
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        animatedCharacters[text.distance(from: text.startIndex, to: index)] = true
                    }
                }
            }
        }
    }
}

#Preview {
    AnimatedText(text: "Take a deep breath")
        .font(.title3)
        .foregroundColor(.secondary)
}
