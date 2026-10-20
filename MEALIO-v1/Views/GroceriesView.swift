import SwiftUI

public struct GroceriesView: View {
    @ObservedObject var store: RecipeStore
    
    public init(store: RecipeStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Groceries.")
                        .font(MealioFont.editorialHero(size: 32))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text("\(store.groceryItems.count) items ready for \(store.groceryDestination).")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                if store.groceryItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "basket")
                            .font(.system(size: 44))
                            .foregroundColor(MealioColors.textTertiary)
                        Text("Your grocery basket is empty")
                            .font(MealioFont.editorialTitle(size: 18))
                            .foregroundColor(MealioColors.textPrimary)
                        Text("Add ingredients from any recipe with a single tap.")
                            .font(.system(size: 13))
                            .foregroundColor(MealioColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    // Grouped list
                    VStack(spacing: 0) {
                        ForEach(store.groceryItems) { item in
                            HStack {
                                Image(systemName: "circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(MealioColors.terracotta)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(MealioColors.textPrimary)
                                    
                                    if let note = item.note {
                                        Text(note)
                                            .font(.system(size: 11))
                                            .foregroundColor(MealioColors.textTertiary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(item.formattedQuantity(forServings: 2, baseServings: 2))
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(MealioColors.textSecondary)
                                
                                Button(action: {
                                    withAnimation {
                                        store.removeGroceryItem(id: item.id)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundColor(MealioColors.textTertiary)
                                        .padding(.leading, 8)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 12)
                            
                            Divider()
                                .background(MealioColors.divider)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                    .frame(height: 80)
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
