import SwiftUI

public struct AudioWaveformView: View {
    @ObservedObject var session: CookingSession
    
    public init(session: CookingSession) {
        self.session = session
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Microphone icon
            Image(systemName: "mic.fill")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: 0x98A89E))
            
            // Status text
            VStack(alignment: .leading, spacing: 2) {
                Text("I'm listening")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(MealioColors.textLight)
                
                Text("Voice & air gestures • Offline")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: 0x7E9085))
            }
            
            Spacer()
            
            // Audio Waveform bars
            HStack(spacing: 3) {
                ForEach(0..<session.audioLevels.count, id: \.self) { index in
                    let level = session.audioLevels[index]
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(MealioColors.cookingGlow.opacity(0.85))
                        .frame(width: 2.5, height: max(4, 22 * level))
                        .animation(.easeInOut(duration: 0.15), value: level)
                }
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(MealioColors.cookingSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(MealioColors.cookingBorder.opacity(0.7), lineWidth: 1)
                )
        )
    }
}
