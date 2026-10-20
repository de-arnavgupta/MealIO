import SwiftUI

public struct CircularTimerView: View {
    @ObservedObject var session: CookingSession
    
    public init(session: CookingSession) {
        self.session = session
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Circular countdown ring
            ZStack {
                // Background track
                Circle()
                    .stroke(MealioColors.cookingBorder.opacity(0.6), lineWidth: 4)
                    .frame(width: 220, height: 220)
                
                // Progress stroke with glow
                Circle()
                    .trim(from: 0.0, to: session.progressFraction)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                MealioColors.cookingGlow,
                                MealioColors.terracotta,
                                MealioColors.terracottaLight
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                    .animation(.linear(duration: 1.0), value: session.progressFraction)
                    .shadow(color: MealioColors.cookingGlow.opacity(0.4), radius: 6, x: 0, y: 0)
                
                // Inside timer content
                VStack(spacing: 6) {
                    Text(session.currentStep.timerSideLabel)
                        .font(MealioFont.eyebrow(size: 11))
                        .tracking(1.5)
                        .foregroundColor(Color(hex: 0x98A89E))
                    
                    Text(session.timerFormatted)
                        .font(.system(size: 52, weight: .light, design: .default))
                        .monospacedDigit()
                        .foregroundColor(MealioColors.textLight)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            session.toggleTimer()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: session.isTimerRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text(session.isTimerRunning ? "Pause timer" : "Resume timer")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(MealioColors.cookingGlow)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(MealioColors.cookingSurface.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 230, height: 230)
            
            // Adjustments: + 15 sec | Reset
            HStack(spacing: 24) {
                Button(action: {
                    withAnimation {
                        session.add15Seconds()
                    }
                }) {
                    Text("+ 15 sec")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: 0x98A89E))
                }
                .buttonStyle(.plain)
                
                Rectangle()
                    .fill(MealioColors.cookingBorder)
                    .frame(width: 1, height: 14)
                
                Button(action: {
                    withAnimation {
                        session.resetTimer()
                    }
                }) {
                    Text("Reset")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: 0x98A89E))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
    }
}
