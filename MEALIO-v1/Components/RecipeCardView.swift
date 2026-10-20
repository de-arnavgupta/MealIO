import SwiftUI

public struct RecipeCardView: View {
    let recipe: Recipe
    var isSaved: Bool = false
    let onSelect: () -> Void
    var onToggleSave: (() -> Void)? = nil
    
    @ObservedObject private var paletteExtractor = ImagePaletteExtractor.shared
    
    public init(
        recipe: Recipe,
        isSaved: Bool = false,
        onSelect: @escaping () -> Void,
        onToggleSave: (() -> Void)? = nil
    ) {
        self.recipe = recipe
        self.isSaved = isSaved
        self.onSelect = onSelect
        self.onToggleSave = onToggleSave
    }
    
    public var body: some View {
        let palette = paletteExtractor.palette(for: recipe.cardImageName)
        
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Top Edge-to-Edge Image with soft organic bottom dissolve
                ZStack(alignment: .bottom) {
                    MealioImageView(recipe.cardImageName)
                        .frame(maxWidth: .infinity)
                        .frame(height: 152)
                        .clipped()
                    
                    LinearGradient(
                        colors: [
                            Color.clear,
                            palette.backgroundColor.opacity(0.15),
                            palette.backgroundColor
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 44)
                }
                
                // Centered dynamic editorial text area with rigid baseline alignment
                VStack(spacing: 0) {
                    // Fixed-height Title area: exactly 42pt centered regardless of 1 or 2 lines
                    Text(recipe.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(palette.textColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42, alignment: .center)
                    
                    Spacer(minLength: 4)
                    
                    // Bottom-pinned metadata row: fixed 16pt height at the exact same vertical baseline
                    HStack(spacing: 4) {
                        Text(recipe.totalTime)
                        Text("·")
                        Text(recipe.effort.lowercased())
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(palette.textColor)
                        Text(String(format: "%.1f", recipe.rating))
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(palette.textColor.opacity(0.92))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 16)
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity)
                .frame(height: 94)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 246)
            .background(palette.backgroundColor)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: palette.backgroundColor)
    }
}
