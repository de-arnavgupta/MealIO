import SwiftUI

public struct SavedRecipesView: View {
    @ObservedObject var store: RecipeStore
    @Binding var selectedRecipeForNavigation: Recipe?
    
    public init(store: RecipeStore, selectedRecipeForNavigation: Binding<Recipe?>) {
        self.store = store
        self._selectedRecipeForNavigation = selectedRecipeForNavigation
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved recipes.")
                        .font(MealioFont.editorialHero(size: 32))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text("\(store.savedRecipeIds.count) recipes bookmarked for your table.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Saved Recipes list
                let saved = store.allRecipes.filter { store.isRecipeSaved($0.id) }
                
                VStack(spacing: 16) {
                    ForEach(saved) { recipe in
                        Button(action: {
                            selectedRecipeForNavigation = recipe
                        }) {
                            HStack(spacing: 14) {
                                MealioImageView(recipe.cardImageName)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(16)
                                    .clipped()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.categoryBadge)
                                        .font(MealioFont.eyebrow(size: 9))
                                        .foregroundColor(MealioColors.terracotta)
                                    
                                    Text(recipe.title)
                                        .font(MealioFont.editorialTitle(size: 17))
                                        .foregroundColor(MealioColors.textPrimary)
                                    
                                    HStack(spacing: 6) {
                                        Text(recipe.totalTime)
                                        Text("•")
                                        Text(recipe.effort)
                                    }
                                    .font(.system(size: 12))
                                    .foregroundColor(MealioColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(MealioColors.textTertiary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(MealioColors.divider, lineWidth: 1)
                                    .background(RoundedRectangle(cornerRadius: 20).fill(MealioColors.cardLight))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 80)
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
