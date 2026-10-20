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
                        .frame(height: 154)
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
                    .frame(height: 48)
                }
                
                // Centered dynamic editorial text area matching reference
                VStack(spacing: 8) {
                    Text(recipe.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(palette.textColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack(spacing: 5) {
                        Text(recipe.totalTime)
                        Text("·")
                        Text(recipe.effort.lowercased())
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(palette.textColor)
                        Text(String(format: "%.1f", recipe.rating))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(palette.textColor.opacity(0.92))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 94)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 248)
            .background(palette.backgroundColor)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: palette.backgroundColor)
    }
}
