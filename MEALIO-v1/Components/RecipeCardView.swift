import SwiftUI

public struct RecipeCardView: View {
    let recipe: Recipe
    let isSaved: Bool
    let onSelect: () -> Void
    let onToggleSave: () -> Void
    
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
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                // Fixed-height uniform image container
                ZStack(alignment: .topTrailing) {
                    MealioImageView(recipe.cardImageName)
                        .frame(maxWidth: .infinity)
                        .frame(height: 125)
                        .clipped()
                        .cornerRadius(14)
                    
                    Button(action: onToggleSave) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.45))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                }
                
                // Text block with exact rigid vertical alignment
                VStack(alignment: .leading, spacing: 3) {
                    Text(recipe.cuisine.uppercased())
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.terracotta)
                        .frame(height: 12, alignment: .leading)
                    
                    Text(recipe.title)
                        .font(MealioFont.editorialTitle(size: 14))
                        .foregroundColor(MealioColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 38, alignment: .topLeading)
                    
                    HStack(spacing: 4) {
                        Text(recipe.totalTime)
                        Text("•")
                        Text(recipe.effort)
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(MealioColors.cookingGlow)
                            Text(String(format: "%.1f", recipe.rating))
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(MealioColors.textSecondary)
                    .frame(height: 14)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .frame(height: 222) // Exact uniform height for all cards!
            .background(MealioColors.cardLight)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
