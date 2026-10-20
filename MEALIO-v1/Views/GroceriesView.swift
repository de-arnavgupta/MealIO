import SwiftUI

public struct GroceriesView: View {
    @ObservedObject var store: RecipeStore
    
    public init(store: RecipeStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Groceries.")
                        .font(MealioFont.editorialHero(size: 32))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text("\(store.groceryItems.count) items ready for \(store.groceryDestination).")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
                
                if !store.groceryItems.isEmpty {
                    Menu {
                        if !store.checkedGroceryItemIds.isEmpty {
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    store.clearCheckedGroceryItems()
                                    HapticFeedback.light()
                                }
                            }) {
                                Label("Remove Checked Items (\(store.checkedGroceryItemIds.count))", systemImage: "checkmark.circle")
                            }
                        }
                        
                        Button(role: .destructive, action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                for item in store.groceryItems {
                                    store.removeGroceryItem(id: item.id)
                                }
                                HapticFeedback.medium()
                            }
                        }) {
                            Label("Clear All Items", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 22))
                            .foregroundColor(MealioColors.textSecondary)
                            .padding(8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            if store.groceryItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "basket")
                        .font(.system(size: 46))
                        .foregroundColor(MealioColors.textTertiary)
                    Text("Your grocery basket is empty")
                        .font(MealioFont.editorialTitle(size: 18))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Add ingredients from any recipe with a single tap.")
                        .font(.system(size: 13))
                        .foregroundColor(MealioColors.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(store.groceryItems) { item in
                        let isChecked = store.checkedGroceryItemIds.contains(item.id)
                        
                        Button(action: {
                            HapticFeedback.light()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                store.toggleGroceryItemChecked(id: item.id)
                            }
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(isChecked ? MealioColors.successGreen : MealioColors.terracotta)
                                    .symbolEffect(.bounce, value: isChecked)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .strikethrough(isChecked, color: MealioColors.textTertiary)
                                        .foregroundColor(isChecked ? MealioColors.textTertiary : MealioColors.textPrimary)
                                    
                                    if let note = item.note {
                                        Text(note)
                                            .font(.system(size: 11))
                                            .foregroundColor(MealioColors.textTertiary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(item.formattedQuantity(forServings: 2, baseServings: 2))
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(isChecked ? MealioColors.textTertiary : MealioColors.textSecondary)
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(MealioColors.background)
                        .listRowSeparatorTint(MealioColors.divider)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                HapticFeedback.light()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    store.toggleGroceryItemChecked(id: item.id)
                                }
                            } label: {
                                Label(
                                    isChecked ? "Uncheck" : "Check Off",
                                    systemImage: isChecked ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                            .tint(MealioColors.successGreen)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                HapticFeedback.medium()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    store.removeGroceryItem(id: item.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 80) // bottom inset for floating tab bar dock
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
