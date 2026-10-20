import SwiftUI

public struct SavedRecipesView: View {
    @ObservedObject var store: RecipeStore
    @Binding var selectedRecipeForNavigation: Recipe?
    
    public init(store: RecipeStore, selectedRecipeForNavigation: Binding<Recipe?>) {
        self.store = store
        self._selectedRecipeForNavigation = selectedRecipeForNavigation
    }
    
    public var body: some View {
        let saved = store.allRecipes.filter { store.isRecipeSaved($0.id) }
        
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Saved recipes.")
                    .font(MealioFont.editorialHero(size: 32))
                    .foregroundColor(MealioColors.textPrimary)
                
                Text("\(saved.count) recipes bookmarked for your table.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(MealioColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            if saved.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 46))
                        .foregroundColor(MealioColors.textTertiary)
                    Text("No saved recipes yet")
                        .font(MealioFont.editorialTitle(size: 18))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Bookmark recipes from Discover or your search to build your weekly cookbook.")
                        .font(.system(size: 13))
                        .foregroundColor(MealioColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(saved) { recipe in
                        Button(action: {
                            HapticFeedback.light()
                            selectedRecipeForNavigation = recipe
                        }) {
                            HStack(spacing: 14) {
                                MealioImageView(recipe.cardImageName)
                                    .frame(width: 76, height: 76)
                                    .cornerRadius(16)
                                    .clipped()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.categoryBadge)
                                        .font(MealioFont.eyebrow(size: 9))
                                        .foregroundColor(MealioColors.terracotta)
                                    
                                    Text(recipe.title)
                                        .font(MealioFont.editorialTitle(size: 16))
                                        .foregroundColor(MealioColors.textPrimary)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 6) {
                                        Text(recipe.totalTime)
                                        Text("•")
                                        Text(recipe.effort.lowercased())
                                        Text("•")
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(MealioColors.terracotta)
                                        Text(String(format: "%.1f", recipe.rating))
                                    }
                                    .font(.system(size: 12))
                                    .foregroundColor(MealioColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(MealioColors.textTertiary)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(MealioColors.divider, lineWidth: 0.8)
                                    .background(RoundedRectangle(cornerRadius: 18).fill(MealioColors.cardLight))
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(MealioColors.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                HapticFeedback.success()
                                store.addIngredientsToGroceryList(recipe.ingredients.filter { !$0.isInPantry })
                            } label: {
                                Label("Add to Groceries", systemImage: "basket")
                            }
                            .tint(MealioColors.terracotta)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                HapticFeedback.medium()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    store.toggleSave(recipe.id)
                                }
                            } label: {
                                Label("Remove", systemImage: "bookmark.slash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                HapticFeedback.light()
                                store.toggleSave(recipe.id)
                            } label: {
                                Label("Remove from Saved", systemImage: "bookmark.slash")
                            }
                            
                            Button {
                                HapticFeedback.light()
                                store.addIngredientsToGroceryList(recipe.ingredients.filter { !$0.isInPantry })
                            } label: {
                                Label("Add Ingredients to Groceries", systemImage: "basket")
                            }
                            
                            ShareLink(
                                item: "Check out \(recipe.title) on Meal-IO: \(recipe.subtitle)",
                                subject: Text(recipe.title),
                                message: Text("Ready in \(recipe.totalTime) · \(recipe.effort.capitalized) · ★ \(String(format: "%.1f", recipe.rating))")
                            ) {
                                Label("Share Recipe", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 80) // Tab bar clearance
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
