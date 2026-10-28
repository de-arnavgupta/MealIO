import SwiftUI

public struct StartScreenView: View {
    @Binding var isPresented: Bool
    
    @State private var chefScale: CGFloat = 0.72
    @State private var chefOpacity: Double = 0.0
    @State private var chefFloatingOffset: CGFloat = 0.0
    @State private var haloScale: CGFloat = 0.85
    @State private var haloOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 12
    @State private var steamOffset: CGFloat = 0.0
    @State private var steamOpacity: Double = 0.0
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            // Warm organic linen background
            MealioColors.background
                .ignoresSafeArea()
            
            // Soft ambient warm radial glow
            RadialGradient(
                colors: [
                    MealioColors.peachCard.opacity(0.40),
                    MealioColors.terracottaLight.opacity(0.18),
                    MealioColors.background.opacity(0.0)
                ],
                center: .center,
                startRadius: 40,
                endRadius: 280
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Petit Chef Mascot with animated halo & gentle bobbing
                ZStack {
                    // Soft glowing ambient halo
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    MealioColors.peachCard.opacity(0.55),
                                    MealioColors.cardSand.opacity(0.25),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(haloScale)
                        .opacity(haloOpacity)
                    
                    // Circular dish / pedestal base
                    Circle()
                        .fill(MealioColors.cardSand.opacity(0.55))
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle()
                                .stroke(MealioColors.divider.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: MealioColors.textPrimary.opacity(0.04), radius: 16, x: 0, y: 8)
                    
                    // Steam aroma accents
                    HStack(spacing: 12) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(MealioColors.terracotta.opacity(0.32))
                                .frame(width: 5 + CGFloat(i * 2), height: 5 + CGFloat(i * 2))
                                .offset(y: -70 + steamOffset - CGFloat(i * 6))
                                .opacity(steamOpacity)
                        }
                    }
                    
                    // The Lil Chef Icon
                    Image("PetitChef")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 85, height: 120)
                        .offset(y: chefFloatingOffset)
                        .shadow(color: MealioColors.terracotta.opacity(0.12), radius: 10, x: 0, y: 6)
                }
                .scaleEffect(chefScale)
                .opacity(chefOpacity)
                
                // App Brand Title
                Text("mealio")
                    .font(MealioFont.brandLogo(size: 38))
                    .foregroundColor(MealioColors.textPrimary)
                .padding(.top, 24)
                .opacity(textOpacity)
                .offset(y: textOffset)
                
                // Editorial Tagline
                Text("Cook something unforgettable.")
                    .font(MealioFont.editorialQuote(size: 16))
                    .foregroundColor(MealioColors.textSecondary)
                    .padding(.top, 8)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                
                Spacer()
                
                // Kitchen readiness indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(MealioColors.terracotta)
                        .frame(width: 5, height: 5)
                    Text("Prepping your kitchen")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(MealioColors.textTertiary)
                }
                .opacity(textOpacity)
                .padding(.bottom, 48)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissWithAnimation()
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // 1. Chef entrance with organic spring
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
            chefScale = 1.0
            chefOpacity = 1.0
            haloScale = 1.0
            haloOpacity = 1.0
        }
        
        // 2. Text fade-in
        withAnimation(.easeOut(duration: 0.6).delay(0.25)) {
            textOpacity = 1.0
            textOffset = 0
        }
        
        // 3. Gentle steam aroma
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.35)) {
            steamOffset = -8
            steamOpacity = 0.8
        }
        
        // 4. Subtle continuous floating bob for the lil chef
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.5)) {
            chefFloatingOffset = -6
            haloScale = 1.08
        }
        
        // 5. Automatic transition into main app after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismissWithAnimation()
        }
    }
    
    private func dismissWithAnimation() {
        guard isPresented else { return }
        HapticFeedback.light()
        withAnimation(.easeInOut(duration: 0.45)) {
            isPresented = false
        }
    }
}
