import SwiftUI

public struct RecipeCardView: View {
    let recipe: Recipe
    let isSaved: Bool
    let onSelect: () -> Void
    let onToggleSave: () -> Void
    
    @ObservedObject private var paletteExtractor = ImagePaletteExtractor.shared
    
    public init(
        recipe: Recipe,
        isSaved: Bool,
        onSelect: @escaping () -> Void,
        onToggleSave: @escaping () -> Void
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
                // Top Edge-to-Edge Image with soft bottom dissolve
                ZStack(alignment: .topTrailing) {
                    MealioImageView(recipe.cardImageName)
                        .frame(maxWidth: .infinity)
                        .frame(height: 154)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    palette.backgroundColor.opacity(0.15),
                                    palette.backgroundColor
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                    
                    // Bookmark action pill
                    Button(action: onToggleSave) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
                
                // Centered dynamic editorial text area
                VStack(spacing: 6) {
                    Text(recipe.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(palette.textColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
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
                    .foregroundColor(palette.subtleTextColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .frame(height: 92)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 246)
            .background(palette.backgroundColor)
            .cornerRadius(26)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: palette.backgroundColor)
    }
}
