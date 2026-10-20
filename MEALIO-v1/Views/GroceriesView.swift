import SwiftUI
import Combine

public class GroceriesViewModel: ObservableObject {
    @Published public var showingAddGrocerySheet: Bool = false
    @Published public var itemName: String = ""
    @Published public var quantity: String = ""
    @Published public var selectedAisle: String = "Produce"
    
    public init() {}
    
    public func resetInput() {
        itemName = ""
        quantity = ""
        selectedAisle = "Produce"
    }
}

public struct GroceriesView: View {
    @ObservedObject var store: RecipeStore
    @StateObject private var vm = GroceriesViewModel()
    
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
                
                HStack(spacing: 8) {
                    // Direct Add Grocery Item Button
                    Button(action: {
                        HapticFeedback.light()
                        vm.resetInput()
                        vm.showingAddGrocerySheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(MealioColors.terracotta)
                            .clipShape(Circle())
                            .shadow(color: MealioColors.terracotta.opacity(0.32), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(LiquidGlassPressStyle())
                    .accessibilityLabel("Add grocery item")
                    
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
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            if store.groceryItems.isEmpty {
                VStack(spacing: 14) {
                    Spacer()
                    Image(systemName: "basket")
                        .font(.system(size: 46))
                        .foregroundColor(MealioColors.textTertiary)
                    Text("Your grocery basket is empty")
                        .font(MealioFont.editorialTitle(size: 18))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Add ingredients from recipes or add custom items directly.")
                        .font(.system(size: 13))
                        .foregroundColor(MealioColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        HapticFeedback.light()
                        vm.resetInput()
                        vm.showingAddGrocerySheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Add Item")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(MealioColors.terracotta)
                        .clipShape(Capsule())
                        .shadow(color: MealioColors.terracotta.opacity(0.30), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(LiquidGlassPressStyle())
                    .padding(.top, 4)
                    
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
        .sheet(isPresented: $vm.showingAddGrocerySheet) {
            AddGroceryItemSheet(store: store, vm: vm)
                .presentationDetents([.fraction(0.55), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
        }
    }
}

// MARK: - Dedicated Add Grocery Item Sheet
public struct AddGroceryItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: RecipeStore
    @ObservedObject var vm: GroceriesViewModel
    
    private let aisles = ["Produce", "Dairy", "Bakery", "Meat & Seafood", "Pantry", "Spices", "Grains & Pasta", "Other"]
    
    public init(store: RecipeStore, vm: GroceriesViewModel) {
        self.store = store
        self.vm = vm
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Item Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ITEM NAME")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                            .foregroundColor(MealioColors.textSecondary)
                        
                        TextField("e.g. Sourdough loaf, Avocados, Oat milk", text: $vm.itemName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(MealioColors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(MealioColors.cardLight)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(MealioColors.divider, lineWidth: 1)
                            )
                    }
                    
                    // Quantity & Unit
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QUANTITY (OPTIONAL)")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                            .foregroundColor(MealioColors.textSecondary)
                        
                        TextField("e.g. 2 pcs, 500g, 1 bunch, 1 bottle", text: $vm.quantity)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(MealioColors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(MealioColors.cardLight)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(MealioColors.divider, lineWidth: 1)
                            )
                    }
                    
                    // Aisle Category
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AISLE CATEGORY")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                            .foregroundColor(MealioColors.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(aisles, id: \.self) { aisle in
                                    let isSelected = vm.selectedAisle == aisle
                                    Button(action: {
                                        HapticFeedback.light()
                                        vm.selectedAisle = aisle
                                    }) {
                                        Text(aisle)
                                            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                            .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                                    }
                                    .buttonStyle(LiquidGlassPressStyle())
                                }
                            }
                        }
                    }
                    
                    // Add Button
                    Button(action: {
                        let trimmed = vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        HapticFeedback.medium()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            store.addCustomGroceryItem(name: trimmed, quantity: vm.quantity, aisleCategory: vm.selectedAisle)
                        }
                        dismiss()
                    }) {
                        Text("Add to Groceries")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? MealioColors.textTertiary.opacity(0.4) : MealioColors.terracotta)
                            )
                            .shadow(color: vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.clear : MealioColors.terracotta.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .disabled(vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(LiquidGlassPressStyle())
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(MealioColors.background.ignoresSafeArea())
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(MealioColors.terracotta)
                }
            }
        }
    }
}
