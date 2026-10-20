import SwiftUI

// MARK: - Meal-IO Theme Colors
public struct MealioColors {
    // Warm light background & surface colors
    public static let background = Color(hex: 0xFBF9F4)
    public static let backgroundSecondary = Color(hex: 0xF4EFE6)
    public static let cardSand = Color(hex: 0xF0ECE1)
    public static let cardLight = Color(hex: 0xFFFFFF)
    public static let pillBackground = Color(hex: 0xEFEAE1)
    public static let divider = Color(hex: 0xE8E2D6)
    
    // Brand Terracotta Accent
    public static let terracotta = Color(hex: 0xC1532F)
    public static let terracottaDark = Color(hex: 0xA33F1E)
    public static let terracottaLight = Color(hex: 0xFCEFE9)
    public static let terracottaMuted = Color(hex: 0xDC7D5F)
    
    // Mood & Category Card Palette
    public static let sageGreen = Color(hex: 0xDEE8D8)
    public static let sageGreenDark = Color(hex: 0x485842)
    public static let oliveQuote = Color(hex: 0x545B45)
    public static let oliveTint = Color(hex: 0xEEF2E8)
    public static let peachCard = Color(hex: 0xF6E3D8)
    public static let warmBeige = Color(hex: 0xF3E7D7)
    
    // Dark Hands-Free Cooking Mode
    public static let cookingBackground = Color(hex: 0x111C16)
    public static let cookingSurface = Color(hex: 0x18261F)
    public static let cookingBubble = Color(hex: 0x1E3128)
    public static let cookingBorder = Color(hex: 0x274034)
    public static let cookingGlow = Color(hex: 0xE88B60)
    
    // Text colors
    public static let textPrimary = Color(hex: 0x1A1A18)
    public static let textSecondary = Color(hex: 0x6E6B65)
    public static let textTertiary = Color(hex: 0x9F9B94)
    public static let textLight = Color(hex: 0xF9F8F6)
    public static let textOlive = Color(hex: 0x36402E)
    
    // Status
    public static let successGreen = Color(hex: 0x448B57)
    public static let socialPointer = Color(hex: 0x8B5CF6)
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Typography & Editorial Styles (Native San Francisco)
public struct MealioFont {
    public static func brandLogo(size: CGFloat = 26) -> Font {
        Font.system(size: size, weight: .bold, design: .default)
    }
    
    public static func editorialHero(size: CGFloat = 34) -> Font {
        Font.system(size: size, weight: .bold, design: .default)
    }
    
    public static func editorialTitle(size: CGFloat = 24) -> Font {
        Font.system(size: size, weight: .semibold, design: .default)
    }
    
    public static func editorialQuote(size: CGFloat = 20) -> Font {
        Font.system(size: size, weight: .regular, design: .default)
    }
    
    public static func eyebrow(size: CGFloat = 11) -> Font {
        Font.system(size: size, weight: .bold, design: .default)
    }
    
    public static func body(size: CGFloat = 15) -> Font {
        Font.system(size: size, weight: .regular, design: .default)
    }
    
    public static func caption(size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .medium, design: .default)
    }
}
