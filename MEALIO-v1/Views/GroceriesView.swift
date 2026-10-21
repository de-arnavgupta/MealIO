import SwiftUI
import Combine

public struct GroceriesScrollOffsetKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public class GroceriesViewModel: ObservableObject {
    @Published public var showingAddGrocerySheet: Bool = false
    @Published public var itemName: String = ""
    @Published public var quantity: String = ""
    @Published public var selectedAisle: String = "Produce"
    @Published public var searchText: String = ""
    @Published public var isScrolled: Bool = false
    @Published public var showingClearConfirmDialog: Bool = false
    
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
    
    private var filteredGroceryItems: [Ingredient] {
        let query = vm.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            return store.groceryItems
        }
        return store.groceryItems.filter {
            $0.name.lowercased().contains(query) ||
            $0.aisleCategory.lowercased().contains(query) ||
            ($0.note?.lowercased().contains(query) ?? false)
        }
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Scroll tracker
                GeometryReader { proxy in
                    let minY = proxy.frame(in: .named("groceriesScrollSpace")).minY
                    Color.clear.preference(key: GroceriesScrollOffsetKey.self, value: minY)
                }
                .frame(height: 0)
                
                // Hero Headline (moves up on scroll just like explore page)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Groceries.")
                        .font(MealioFont.editorialHero(size: 26))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text("\(store.groceryItems.count) items ready for \(store.groceryDestination).")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 8)
                
                // Sticky Header: Search Bar + Direct Add Grocery + Direct Trash All
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        if store.groceryItems.isEmpty {
                            emptyState
                        } else if filteredGroceryItems.isEmpty {
                            noSearchResultsState
                        } else {
                            VStack(spacing: 10) {
                                ForEach(filteredGroceryItems) { item in
                                    groceryItemCard(item: item)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                            
                            // Bottom spacing for tab bar
                            Spacer()
                                .frame(height: 80)
                        }
                    }
                } header: {
                    stickyBar
                }
            }
        }
        .coordinateSpace(name: "groceriesScrollSpace")
        .onPreferenceChange(GroceriesScrollOffsetKey.self) { minY in
            let scrolled = minY < -15
            if vm.isScrolled != scrolled {
                withAnimation(.easeInOut(duration: 0.22)) {
                    vm.isScrolled = scrolled
                }
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
        .confirmationDialog(
            "Delete all grocery items?",
            isPresented: $vm.showingClearConfirmDialog,
            titleVisibility: .visible
        ) {
            Button("Delete All Items", role: .destructive) {
                HapticFeedback.medium()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    for item in store.groceryItems {
                        store.removeGroceryItem(id: item.id)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $vm.showingAddGrocerySheet) {
            AddGroceryItemSheet(store: store, vm: vm)
                .presentationDetents([.fraction(0.55), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
        }
    }
    
    // MARK: - Sticky Search Bar & Actions in One Horizontal Line
    private var stickyBar: some View {
        HStack(spacing: 8) {
            searchBar
            addGroceryButton
            if !store.groceryItems.isEmpty {
                trashAllButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, vm.isScrolled ? 10 : 4)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background {
            if vm.isScrolled {
                Rectangle()
                    .fill(Color.clear)
                    .glassEffect(.regular, in: .rect)
                    .ignoresSafeArea(edges: .top)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Search Bar (Liquid Glass)
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
            
            TextField(
                "",
                text: $vm.searchText,
                prompt: Text("Search groceries...").foregroundColor(.black)
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)
            .tint(MealioColors.terracotta)
            
            if !vm.searchText.isEmpty {
                Button(action: {
                    HapticFeedback.light()
                    vm.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(MealioColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(height: 48)
        .liquidGlass(cornerRadius: 24, isClear: vm.isScrolled)
    }
    
    // MARK: - Add Grocery Button (Liquid Glass)
    private var addGroceryButton: some View {
        Button(action: {
            HapticFeedback.light()
            vm.resetInput()
            vm.showingAddGrocerySheet = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(MealioColors.textPrimary)
                .frame(width: 48, height: 48)
                .liquidGlass(cornerRadius: 24, isClear: vm.isScrolled)
        }
        .buttonStyle(LiquidGlassPressStyle())
        .accessibilityLabel("Add grocery item")
    }
    
    // MARK: - Trash All Button (Liquid Glass)
    private var trashAllButton: some View {
        Button(action: {
            HapticFeedback.medium()
            vm.showingClearConfirmDialog = true
        }) {
            Image(systemName: "trash")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(MealioColors.terracotta)
                .frame(width: 48, height: 48)
                .liquidGlass(cornerRadius: 24, isClear: vm.isScrolled)
        }
        .buttonStyle(LiquidGlassPressStyle())
        .accessibilityLabel("Delete all groceries")
    }
    
    // MARK: - Grocery Item Card
    private func groceryItemCard(item: Ingredient) -> some View {
        let isChecked = store.checkedGroceryItemIds.contains(item.id)
        
        return HStack(spacing: 14) {
            Button(action: {
                HapticFeedback.light()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                    store.toggleGroceryItemChecked(id: item.id)
                }
            }) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isChecked ? MealioColors.successGreen : MealioColors.terracotta)
                    .symbolEffect(.bounce, value: isChecked)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .strikethrough(isChecked, color: MealioColors.textTertiary)
                    .foregroundColor(isChecked ? MealioColors.textTertiary : MealioColors.textPrimary)
                
                HStack(spacing: 6) {
                    Text(item.aisleCategory.uppercased())
                        .font(MealioFont.eyebrow(size: 9))
                        .tracking(0.8)
                        .foregroundColor(MealioColors.textOlive)
                    
                    if let note = item.note, !note.isEmpty {
                        Text("•")
                            .font(.system(size: 8))
                            .foregroundColor(MealioColors.textTertiary)
                        Text(note)
                            .font(.system(size: 11))
                            .foregroundColor(MealioColors.textTertiary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Text(item.formattedQuantity(forServings: 2, baseServings: 2))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isChecked ? MealioColors.textTertiary : MealioColors.textSecondary)
            
            Button(action: {
                HapticFeedback.light()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    store.removeGroceryItem(id: item.id)
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MealioColors.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(Color.black.opacity(0.04))
                    .clipShape(Circle())
            }
            .buttonStyle(LiquidGlassPressStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Empty States
    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 40)
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
            
            Spacer().frame(height: 60)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var noSearchResultsState: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 40)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(MealioColors.textTertiary)
            Text("No items matched \"\(vm.searchText)\"")
                .font(MealioFont.editorialTitle(size: 16))
                .foregroundColor(MealioColors.textPrimary)
            Text("Check your spelling or add a new grocery item.")
                .font(.system(size: 13))
                .foregroundColor(MealioColors.textSecondary)
            Spacer().frame(height: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// MARK: - Dedicated Add Grocery Item Sheet (Full Mealio Palette & High Contrast)
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
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Item Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ITEM NAME")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textSecondary)
                        
                        TextField("", text: $vm.itemName, prompt: Text("e.g. Sourdough loaf, Avocados, Oat milk").foregroundColor(MealioColors.textTertiary))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(MealioColors.textPrimary)
                            .tint(MealioColors.terracotta)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: 0xDCD5CB), lineWidth: 1.0)
                            )
                    }
                    
                    // Quantity & Unit
                    VStack(alignment: .leading, spacing: 6) {
                        Text("QUANTITY (OPTIONAL)")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textSecondary)
                        
                        TextField("", text: $vm.quantity, prompt: Text("e.g. 2 pcs, 500g, 1 bunch, 1 bottle").foregroundColor(MealioColors.textTertiary))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(MealioColors.textPrimary)
                            .tint(MealioColors.terracotta)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: 0xDCD5CB), lineWidth: 1.0)
                            )
                    }
                    
                    // Aisle Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AISLE CATEGORY")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
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
                                            .background(
                                                Capsule()
                                                    .fill(isSelected ? MealioColors.terracotta : Color.white)
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(isSelected ? MealioColors.terracotta : Color(hex: 0xDCD5CB), lineWidth: 1.0)
                                            )
                                            .shadow(color: isSelected ? MealioColors.terracotta.opacity(0.25) : Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(LiquidGlassPressStyle())
                                }
                            }
                            .padding(.horizontal, 1)
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // Add Button
                    let isInputEmpty = vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    Button(action: {
                        let trimmed = vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        HapticFeedback.success()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            store.addCustomGroceryItem(name: trimmed, quantity: vm.quantity, aisleCategory: vm.selectedAisle)
                        }
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                            Text("Add to Groceries")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(isInputEmpty ? MealioColors.textTertiary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isInputEmpty ? Color(hex: 0xECE6DC) : MealioColors.terracotta)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isInputEmpty ? Color(hex: 0xDCD5CB) : Color.clear, lineWidth: 1.0)
                        )
                        .shadow(color: isInputEmpty ? Color.clear : MealioColors.terracotta.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isInputEmpty)
                    .buttonStyle(LiquidGlassPressStyle())
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(MealioColors.background.ignoresSafeArea())
            .navigationTitle("Add Grocery Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticFeedback.light()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(MealioColors.textSecondary)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
