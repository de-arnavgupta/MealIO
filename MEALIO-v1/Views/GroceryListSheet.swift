import SwiftUI
import Combine

public class GroceryListViewModel: ObservableObject {
    @Published public var selectedIngredientIds: Set<UUID>
    
    public init(initialSelected: Set<UUID>) {
        self.selectedIngredientIds = initialSelected
    }
}

public struct GroceryListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: RecipeStore
    let recipe: Recipe
    let servings: Int
    @StateObject private var vm: GroceryListViewModel
    
    public init(store: RecipeStore, recipe: Recipe, servings: Int) {
        self.store = store
        self.recipe = recipe
        self.servings = servings
        
        let nonPantry = recipe.ingredients.filter { !$0.isInPantry }
        let initialIds = Set(nonPantry.map { $0.id })
        self._vm = StateObject(wrappedValue: GroceryListViewModel(initialSelected: initialIds))
    }
    
    private var nonPantryIngredients: [Ingredient] {
        recipe.ingredients.filter { !$0.isInPantry }
    }
    
    private var pantryIngredients: [Ingredient] {
        recipe.ingredients.filter { $0.isInPantry }
    }
    
    private var allSelected: Bool {
        vm.selectedIngredientIds.count == nonPantryIngredients.count
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(MealioColors.textTertiary.opacity(0.4))
                .frame(width: 38, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)
            
            // Header with close button
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add to grocery list.")
                        .font(MealioFont.editorialHero(size: 28))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text("For \(recipe.title). A little planning, done.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(MealioColors.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(MealioColors.pillBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // ADD TO selector dropdown card (Interactive Menu)
                    Menu {
                        Button("Weekly Shop • Sunday") {
                            store.groceryDestination = "Weekly Shop • Sunday"
                        }
                        Button("Dinner Party") {
                            store.groceryDestination = "Dinner Party"
                        }
                        Button("Quick Essentials") {
                            store.groceryDestination = "Quick Essentials"
                        }
                        Button("Weekend Market List") {
                            store.groceryDestination = "Weekend Market List"
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "basket")
                                .font(.system(size: 20))
                                .foregroundColor(MealioColors.terracotta)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ADD TO")
                                    .font(MealioFont.eyebrow(size: 10))
                                    .tracking(1.0)
                                    .foregroundColor(MealioColors.textTertiary)
                                
                                Text(store.groceryDestination)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(MealioColors.textPrimary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(MealioColors.textSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(MealioColors.divider, lineWidth: 1)
                                .background(RoundedRectangle(cornerRadius: 16).fill(MealioColors.cardLight))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Selection summary bar: "8 ingredients selected • 2 servings" and "Deselect all"
                    HStack {
                        Text("\(vm.selectedIngredientIds.count) ingredients selected • \(servings) servings")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(MealioColors.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if allSelected {
                                    vm.selectedIngredientIds.removeAll()
                                } else {
                                    vm.selectedIngredientIds = Set(nonPantryIngredients.map { $0.id })
                                }
                            }
                        }) {
                            Text(allSelected ? "Deselect all" : "Select all")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(MealioColors.terracotta)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                    
                    // Ingredients Checklist
                    VStack(spacing: 0) {
                        ForEach(nonPantryIngredients) { item in
                            let isChecked = vm.selectedIngredientIds.contains(item.id)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if isChecked {
                                        vm.selectedIngredientIds.remove(item.id)
                                    } else {
                                        vm.selectedIngredientIds.insert(item.id)
                                    }
                                }
                            }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(isChecked ? MealioColors.terracotta : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(isChecked ? MealioColors.terracotta : MealioColors.divider, lineWidth: 1.5)
                                            )
                                            .frame(width: 22, height: 22)
                                        
                                        if isChecked {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(MealioColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(item.formattedQuantity(forServings: servings, baseServings: recipe.baseServings))
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(MealioColors.textSecondary)
                                }
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            Divider()
                                .background(MealioColors.divider.opacity(0.6))
                        }
                    }
                    
                    // Smart Pantry Notice
                    if !pantryIngredients.isEmpty {
                        let names = pantryIngredients.map { $0.name }.joined(separator: ", ")
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(MealioColors.successGreen)
                                .padding(.top, 2)
                            
                            Text("\(names) are already in your pantry.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(MealioColors.textSecondary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Bottom Action Area
            VStack(spacing: 10) {
                Button(action: {
                    let itemsToAdd = nonPantryIngredients.filter { vm.selectedIngredientIds.contains($0.id) }
                    store.addIngredientsToGroceryList(itemsToAdd)
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Text("Add \(vm.selectedIngredientIds.count) ingredients")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        vm.selectedIngredientIds.isEmpty ?
                            MealioColors.terracotta.opacity(0.4) :
                            MealioColors.terracotta
                    )
                    .cornerRadius(30)
                }
                .disabled(vm.selectedIngredientIds.isEmpty)
                .buttonStyle(.plain)
                
                Text("Neatly grouped by aisle. Ready when you are.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(MealioColors.textTertiary)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .background(MealioColors.background)
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
