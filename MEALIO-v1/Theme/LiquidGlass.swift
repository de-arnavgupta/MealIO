import SwiftUI
import UIKit

// MARK: - Apple Human Interface Guidelines: Liquid Glass 2.0 System
// Re-creates the native iOS 26/27 translucent, physically reactive material layer
// with real-time optical blur, double-bevel specular refraction, and fluid press dynamics.

public struct LiquidGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var tint: Color?
    public var isClear: Bool
    
    public init(cornerRadius: CGFloat = 24, tint: Color? = nil, isClear: Bool = false) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.isClear = isClear
    }
    
    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Optical material layer: native ultraThinMaterial provides real-time blur behind element
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Luminous white foundation: adjusted for clarity
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(isClear ? 0.18 : 0.68))
                    
                    if let tint = tint {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(isClear ? 0.08 : 0.10))
                    }
                    
                    // Living ambient specular sheen: light refraction across surface
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isClear ? 0.32 : 0.48),
                                    Color.white.opacity(isClear ? 0.08 : 0.16),
                                    Color.clear,
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay {
                // Double-Bevel Specular Edging:
                // 1. Outer high-contrast refraction boundary
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.50),
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.65)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.85
                    )
            }
            .overlay {
                // 2. Inner specular bevel highlight for authentic crystalline depth
                RoundedRectangle(cornerRadius: max(0, cornerRadius - 1), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.50),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
                    .padding(0.7)
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
                        Capsule(style: .continuous)
                            .fill(tint ?? MealioColors.terracotta)
                        
                        // Subtle specular top sheen for glass depth
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.32),
                                        Color.white.opacity(0.06),
                                        Color.clear,
                                        Color.black.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.72))
                        
                        if let tint = tint {
                            Capsule(style: .continuous)
                                .fill(tint.opacity(0.10))
                        }
                        
                        // Ambient upper light sheen
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.40),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .overlay {
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? [
                                Color.white.opacity(0.65),
                                Color.white.opacity(0.25)
                            ] : [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.50),
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.60)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.85
                    )
            }
            .overlay {
                if !isSelected {
                    Capsule(style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                        .padding(0.7)
                }
            }
            .shadow(
                color: isSelected ? (tint ?? MealioColors.terracotta).opacity(0.24) : Color(hex: 0x4A3B32, alpha: 0.035),
                radius: isSelected ? 6 : 4,
                x: 0,
                y: 2
            )
    }
}

public struct LiquidGlassPressStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? 0.03 : 0.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: configuration.isPressed)
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
    
    public static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

extension View {
    public func liquidGlass(cornerRadius: CGFloat = 24, tint: Color? = nil, isClear: Bool = false) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, tint: tint, isClear: isClear))
    }
    
    public func liquidGlassCapsule(tint: Color? = nil, isSelected: Bool = false) -> some View {
        self.modifier(LiquidGlassCapsuleModifier(tint: tint, isSelected: isSelected))
    }
    
    public func liquidPressable() -> some View {
        self.buttonStyle(LiquidGlassPressStyle())
    }
}
