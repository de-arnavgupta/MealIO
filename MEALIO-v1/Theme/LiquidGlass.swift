import SwiftUI
import UIKit

// MARK: - Apple Liquid Glass Design System
// Reference: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
//
// Apple's Liquid Glass utilizes the .regular variant for controls and navigation
// to ensure perfect luminosity and contrast across all backgrounds (including solid white,
// cream, and scrolling content). It dynamically adjusts internal luminosity, eliminating
// the dark/shadow artifacts of .clear while preserving true optical refraction and
// specular edge highlights.
//
// Chained with .interactive() for fluid real-time touch, tilt, and pointer responsiveness.

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
        if let tint = tint {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        }
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
        if isSelected {
            content
                .glassEffect(.regular.tint(tint ?? MealioColors.terracotta).interactive(), in: .capsule)
        } else if let tint = tint {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: .capsule)
        } else {
            content
                .glassEffect(.regular.interactive(), in: .capsule)
        }
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
        if isSelected, let tint = tint {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: .circle)
        } else if let tint = tint {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: .circle)
        } else {
            content
                .glassEffect(.regular.interactive(), in: .circle)
        }
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
