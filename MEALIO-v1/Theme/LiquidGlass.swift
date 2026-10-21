import SwiftUI
import UIKit

// MARK: - Native Apple Liquid Glass System (HIG & Apple Design Award Standard)
// Pure native SwiftUI Material architecture using system optical compositor blur,
// crisp 0.5pt hairline borders, and zero artificial painted gradients.

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
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isClear ? .ultraThinMaterial : .thickMaterial)
                    .overlay {
                        if let tint = tint {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(tint.opacity(0.10))
                        }
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
            }
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
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
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(tint ?? MealioColors.terracotta)
                } else {
                    Capsule(style: .continuous)
                        .fill(.thickMaterial)
                        .overlay {
                            if let tint = tint {
                                Capsule(style: .continuous)
                                    .fill(tint.opacity(0.10))
                            }
                        }
                }
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.18),
                        lineWidth: 0.5
                    )
            }
            .shadow(
                color: isSelected ? (tint ?? MealioColors.terracotta).opacity(0.22) : Color.black.opacity(0.04),
                radius: isSelected ? 6 : 4,
                x: 0,
                y: isSelected ? 3 : 1
            )
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
                if isSelected, let tint = tint {
                    Circle()
                        .fill(tint)
                } else {
                    Circle()
                        .fill(isClear ? .ultraThinMaterial : .thickMaterial)
                        .overlay {
                            if let tint = tint {
                                Circle()
                                    .fill(tint.opacity(0.10))
                            }
                        }
                }
            }
            .overlay {
                Circle()
                    .strokeBorder(
                        isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.18),
                        lineWidth: 0.5
                    )
            }
            .shadow(
                color: isSelected ? (tint ?? MealioColors.terracotta).opacity(0.28) : Color.black.opacity(0.04),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 3 : 1
            )
    }
}

public struct LiquidGlassPressStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
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
