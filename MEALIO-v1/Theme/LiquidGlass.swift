import SwiftUI
import UIKit

// MARK: - Apple Human Interface Guidelines: Liquid Glass System
// Re-creates the native iOS translucent, physically reactive material layer
// with real-time optical blur, luminous crystalline refraction, and specular edge lensing.

public struct LiquidGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var tint: Color?
    
    public init(cornerRadius: CGFloat = 24, tint: Color? = nil) {
        self.cornerRadius = cornerRadius
        self.tint = tint
    }
    
    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Optical material layer: native ultraThinMaterial provides real-time blur behind element
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Luminous white tint: brightens the material so it blends cleanly with warm ivory (#FBF9F4)
                    // without becoming murky or dark grey.
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(0.68))
                    
                    if let tint = tint {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(0.12))
                    }
                    
                    // Ambient specular sheen: subtle upper light reflection
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.40),
                                    Color.white.opacity(0.10),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay {
                // Precision glass refraction rim / specular highlight border
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.92),
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.60)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.85
                    )
            }
            .shadow(color: Color(hex: 0x4A3B32, alpha: 0.04), radius: 12, x: 0, y: 3)
    }
}

public struct LiquidGlassCapsuleModifier: ViewModifier {
    public var tint: Color?
    public var isSelected: Bool
    
    public init(tint: Color? = nil, isSelected: Bool = false) {
        self.tint = tint
        self.isSelected = isSelected
    }
    
    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    if isSelected {
                        // Radiant culinary terracotta glass when selected - harmonious & bright, never harsh black
                        Capsule(style: .continuous)
                            .fill(tint ?? MealioColors.terracotta)
                        
                        // Subtle specular top sheen for glass depth
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.28),
                                        Color.clear,
                                        Color.black.opacity(0.06)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        // Luminous crystalline frosted base
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.70))
                        
                        if let tint = tint {
                            Capsule(style: .continuous)
                                .fill(tint.opacity(0.10))
                        }
                    }
                }
            }
            .overlay {
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.20)
                            ] : [
                                Color.white.opacity(0.92),
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.85
                    )
            }
            .shadow(
                color: isSelected ? (tint ?? MealioColors.terracotta).opacity(0.22) : Color(hex: 0x4A3B32, alpha: 0.03),
                radius: isSelected ? 6 : 4,
                x: 0,
                y: 2
            )
    }
}

public struct HapticFeedback {
    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    public static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

extension View {
    public func liquidGlass(cornerRadius: CGFloat = 24, tint: Color? = nil) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, tint: tint))
    }
    
    public func liquidGlassCapsule(tint: Color? = nil, isSelected: Bool = false) -> some View {
        self.modifier(LiquidGlassCapsuleModifier(tint: tint, isSelected: isSelected))
    }
}
