import SwiftUI

// MARK: - Apple Design Award: Live Activity / Dynamic Island Floating Cooking Bar
// Keeps the active cooking session, step, and timer visible across the entire app
// with real-time countdown, play/pause controls, and instant 1-tap expansion.

public struct CookingLiveActivityBar: View {
    @ObservedObject var session: CookingSession
    let onExpand: () -> Void
    let onDismiss: () -> Void
    
    public init(session: CookingSession, onExpand: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.session = session
        self.onExpand = onExpand
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Recipe Image Thumbnail with Live Glow
            Button(action: onExpand) {
                ZStack(alignment: .bottomTrailing) {
                    MealioImageView(session.recipe.cardImageName)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    Circle()
                        .fill(session.isTimerRunning ? MealioColors.terracotta : Color(hex: 0x5CD18B))
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)
            
            // Step & Title Info (Tap expands)
            Button(action: onExpand) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("STEP \(session.currentStep.stepIndex) OF \(session.recipe.steps.count)")
                            .font(MealioFont.eyebrow(size: 9))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.terracotta)
                        
                        Text("•")
                            .font(.system(size: 9))
                            .foregroundColor(MealioColors.textTertiary)
                        
                        Text(session.recipe.title)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(MealioColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Text(session.currentStep.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MealioColors.textPrimary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            
            // Timer / Play-Pause Quick Controls
            if session.currentStep.hasTimer {
                Button(action: {
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        session.toggleTimer()
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: session.isTimerRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 10, weight: .bold))
                            .symbolEffect(.bounce, value: session.isTimerRunning)
                        
                        Text(session.timerFormatted)
                            .font(.system(size: 12, weight: .semibold))
                            .monospacedDigit()
                    }
                    .foregroundColor(session.isTimerRunning ? .white : MealioColors.terracotta)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .liquidGlassCapsule(tint: session.isTimerRunning ? MealioColors.terracotta : nil, isSelected: session.isTimerRunning)
                }
                .buttonStyle(LiquidGlassPressStyle())
            }
            
            // Dismiss Session Button
            Button(action: {
                HapticFeedback.light()
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(MealioColors.textSecondary)
                    .frame(width: 26, height: 26)
                    .glassEffect(.clear.interactive(), in: .circle)
            }
            .buttonStyle(LiquidGlassPressStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .liquidGlass(cornerRadius: 28, isClear: false)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
    }
}
