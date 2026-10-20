import SwiftUI

public struct CollectionListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: RecipeStore
    let title: String
    let subtitle: String
    let recipes: [Recipe]
    @Binding var selectedRecipeForNavigation: Recipe?
    
    public init(
        store: RecipeStore,
        title: String,
        subtitle: String,
        recipes: [Recipe],
        selectedRecipeForNavigation: Binding<Recipe?>
    ) {
        self.store = store
        self.title = title
        self.subtitle = subtitle
        self.recipes = recipes
        self._selectedRecipeForNavigation = selectedRecipeForNavigation
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(MealioColors.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(MealioColors.cardLight)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("\(recipes.count) recipes")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(MealioColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Titles
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(MealioFont.editorialHero(size: 32))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                .padding(.horizontal, 20)
                
                // Recipe Cards Grid (100% Uniform RecipeCardView)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                    ForEach(recipes) { recipe in
                        RecipeCardView(
                            recipe: recipe,
                            isSaved: store.isRecipeSaved(recipe.id),
                            onSelect: {
                                store.recordVisitedRecipe(recipe)
                                dismiss()
                                selectedRecipeForNavigation = recipe
                            },
                            onToggleSave: {
                                store.toggleSave(recipe.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
