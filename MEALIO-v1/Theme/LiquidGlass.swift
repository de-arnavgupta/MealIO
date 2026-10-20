import SwiftUI
import UIKit

// MARK: - Apple Human Interface Guidelines: Liquid Glass System (WhatsApp iOS Style)
// Physically reactive translucent material layer with real-time optical blur,
// ultra-sheer optical clarity, and fluid liquid meniscus texture.

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
                    
                    // Ultra-sheer liquid gossamer wash (WhatsApp iOS style: almost 100% transparent optical clarity)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(isClear ? 0.02 : 0.05))
                    
                    if let tint = tint {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(isClear ? 0.04 : 0.06))
                    }
                    
                    // Living ambient specular sheen: light refraction across curved liquid surface
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isClear ? 0.16 : 0.24),
                                    Color.white.opacity(0.02),
                                    Color.clear
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
                                Color.white.opacity(0.70),
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.70
                    )
            }
            .overlay {
                // 2. Inner specular bevel highlight for authentic crystalline depth
                RoundedRectangle(cornerRadius: max(0, cornerRadius - 1), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.40
                    )
                    .padding(0.6)
            }
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
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
                                        Color.white.opacity(0.30),
                                        Color.white.opacity(0.05),
                                        Color.clear,
                                        Color.black.opacity(0.04)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.05))
                        
                        if let tint = tint {
                            Capsule(style: .continuous)
                                .fill(tint.opacity(0.06))
                        }
                        
                        // Ambient upper light sheen (liquid glass texture)
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.20),
                                        Color.white.opacity(0.02),
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
                                Color.white.opacity(0.70),
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.70
                    )
            }
            .overlay {
                if !isSelected {
                    Capsule(style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.40
                        )
                        .padding(0.6)
                }
            }
            .shadow(
                color: isSelected ? (tint ?? MealioColors.terracotta).opacity(0.22) : Color.black.opacity(0.03),
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
    
    public func liquidGlassCircle(tint: Color? = nil, isClear: Bool = false, isSelected: Bool = false) -> some View {
        self.modifier(LiquidGlassCircleModifier(tint: tint, isClear: isClear, isSelected: isSelected))
    }
    
    public func liquidPressable() -> some View {
        self.buttonStyle(LiquidGlassPressStyle())
    }
}

public struct LiquidGlassCircleModifier: ViewModifier {
    public var tint: Color?
    public var isClear: Bool
    public var isSelected: Bool
    
    public init(tint: Color? = nil, isClear: Bool = false, isSelected: Bool = false) {
        self.tint = tint
        self.isClear = isClear
        self.isSelected = isSelected
    }
    
    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    if isSelected, let tint = tint {
                        Circle()
                            .fill(tint)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.08),
                                        Color.clear,
                                        Color.black.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                        
                        Circle()
                            .fill(Color.white.opacity(isClear ? 0.02 : 0.05))
                        
                        if let tint = tint {
                            Circle()
                                .fill(tint.opacity(isClear ? 0.04 : 0.06))
                        }
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isClear ? 0.16 : 0.24),
                                        Color.white.opacity(0.02),
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
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? [
                                Color.white.opacity(0.70),
                                Color.white.opacity(0.25)
                            ] : [
                                Color.white.opacity(0.70),
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.70
                    )
            }
            .overlay {
                if !isSelected {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.40
                        )
                        .padding(0.6)
                }
            }
            .shadow(
                color: isSelected ? (tint ?? MealioColors.terracotta).opacity(0.30) : Color.black.opacity(0.035),
                radius: isSelected ? 8 : 5,
                x: 0,
                y: isSelected ? 3 : 2
            )
    }
}
