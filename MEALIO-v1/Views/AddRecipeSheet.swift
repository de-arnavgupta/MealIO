import SwiftUI
import Combine

public class AddRecipeViewModel: ObservableObject {
    @Published public var title: String = ""
    @Published public var subtitle: String = ""
    @Published public var selectedCuisine: String = "Italian"
    @Published public var selectedDietary: String = "Non-Veg"
    @Published public var prepMinutes: Int = 15
    @Published public var cookMinutes: Int = 25
    @Published public var effort: String = "Medium"
    @Published public var servings: Int = 2
    @Published public var selectedImageIndex: Int = 0
    @Published public var chefSecret: String = ""
    
    // Ingredients
    @Published public var ingredients: [AddIngredientItem] = [
        AddIngredientItem(name: "Extra virgin olive oil", quantity: "2 tbsp"),
        AddIngredientItem(name: "Flaky sea salt & black pepper", quantity: "To taste"),
        AddIngredientItem(name: "Fresh garlic cloves", quantity: "3 cloves, minced")
    ]
    
    // Steps
    @Published public var steps: [AddStepItem] = [
        AddStepItem(instruction: "Prep and arrange all fresh ingredients on the cutting board."),
        AddStepItem(instruction: "Warm a skillet over medium-high heat with olive oil until shimmering.")
    ]
    
    public let availableImages: [(name: String, label: String)] = [
        ("PastaCard", "Artisan Pasta"),
        ("ScallopsCard", "Pan-Seared Scallops"),
        ("SalmonCard", "Crispy Salmon"),
        ("RisottoCard", "Saffron Risotto"),
        ("DuckCard", "Roasted Duck"),
        ("SteakCard", "Cast Iron Steak"),
        ("TartCard", "Rustic Tart"),
        ("TacoCard", "Street Tacos")
    ]
    
    public let cuisines = [
        "Italian", "French", "Japanese", "Mexican", "Indian",
        "Mediterranean", "Thai", "Spanish", "American", "Middle Eastern"
    ]
    
    public let dietaryOptions = ["Non-Veg", "Vegetarian", "Vegan", "Halal"]
    public let effortOptions = ["Easy", "Medium", "Hard"]
    
    public var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public init() {}
    
    public func addIngredient() {
        ingredients.append(AddIngredientItem(name: "", quantity: ""))
    }
    
    public func removeIngredient(at index: Int) {
        guard index >= 0 && index < ingredients.count else { return }
        ingredients.remove(at: index)
    }
    
    public func addStep() {
        steps.append(AddStepItem(instruction: ""))
    }
    
    public func removeStep(at index: Int) {
        guard index >= 0 && index < steps.count else { return }
        steps.remove(at: index)
    }
    
    public func buildRecipe() -> Recipe {
        let totalTimeMinutes = prepMinutes + cookMinutes
        let totalTimeDisplay = "\(totalTimeMinutes) min"
        
        let builtIngredients: [Ingredient] = ingredients
            .filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { item in
                Ingredient(
                    name: item.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    unit: item.quantity.trimmingCharacters(in: .whitespacesAndNewlines),
                    isInPantry: false,
                    isSelectedForGrocery: true,
                    aisleCategory: "Pantry"
                )
            }
        
        let builtSteps: [CookingStep] = steps
            .enumerated()
            .filter { !$0.element.instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { index, item in
                CookingStep(
                    stepIndex: index + 1,
                    title: "Step \(index + 1)",
                    durationMinutes: max(3, totalTimeMinutes / max(1, steps.count)),
                    instruction: item.instruction.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        
        let selectedCover = availableImages[selectedImageIndex].name
        
        return Recipe(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            subtitle: subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Chef's Kitchen Creation" : subtitle.trimmingCharacters(in: .whitespacesAndNewlines),
            cuisine: selectedCuisine,
            categoryBadge: "KITCHEN ORIGINAL",
            collectionTag: "Original Recipes",
            totalTime: totalTimeDisplay,
            totalTimeMinutes: totalTimeMinutes,
            effort: effort.uppercased(),
            rating: 5.0,
            homeCooksCount: 1,
            description: subtitle.isEmpty ? "A custom handcrafted recipe created in your kitchen." : subtitle,
            authorName: "You",
            authorSubtitle: "Home Chef",
            authorInitials: "ME",
            heroImageName: selectedCover,
            cardImageName: selectedCover,
            platedImageName: selectedCover,
            chefSecretTitle: chefSecret.isEmpty ? "Cook's Instinct" : "Chef's Secret",
            chefSecretBody: chefSecret.isEmpty ? "Taste and season at every stage of cooking." : chefSecret,
            baseServings: servings,
            ingredients: builtIngredients.isEmpty ? [
                Ingredient(name: "Fresh ingredients", unit: "As needed")
            ] : builtIngredients,
            steps: builtSteps.isEmpty ? [
                CookingStep(stepIndex: 1, title: "Prepare & Cook", durationMinutes: totalTimeMinutes, instruction: "Prepare fresh ingredients and cook to perfection.")
            ] : builtSteps
        )
    }
}

public struct AddIngredientItem: Identifiable, Hashable {
    public let id = UUID()
    public var name: String
    public var quantity: String
    
    public init(name: String, quantity: String) {
        self.name = name
        self.quantity = quantity
    }
}

public struct AddStepItem: Identifiable, Hashable {
    public let id = UUID()
    public var instruction: String
    
    public init(instruction: String) {
        self.instruction = instruction
    }
}

public struct AddRecipeSheet: View {
    @ObservedObject var store: RecipeStore
    var onCreated: ((Recipe) -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddRecipeViewModel()
    
    public init(store: RecipeStore, onCreated: ((Recipe) -> Void)? = nil) {
        self.store = store
        self.onCreated = onCreated
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    coverSelector
                    detailsSection
                    cuisineAndDietarySection
                    timingAndPortionsSection
                    ingredientsSection
                    stepsSection
                    chefSecretSection
                    saveButton
                }
                .padding(.top, 16)
            }
            .background(MealioColors.background.ignoresSafeArea())
            .navigationTitle("New Recipe")
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
    
    // MARK: - Cover Selector (Fast, Zero-Lag)
    private var coverSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COVER PLATE")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textSecondary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(vm.availableImages.enumerated()), id: \.offset) { index, item in
                        let isSelected = vm.selectedImageIndex == index
                        Button(action: {
                            HapticFeedback.selection()
                            vm.selectedImageIndex = index
                        }) {
                            VStack(spacing: 6) {
                                Image(item.name)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 82, height: 82)
                                    .clipped()
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isSelected ? MealioColors.terracotta : Color(hex: 0xDCD5CB), lineWidth: isSelected ? 2.5 : 1.0)
                                    )
                                    .shadow(color: isSelected ? MealioColors.terracotta.opacity(0.35) : Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                                
                                Text(item.label)
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textPrimary)
                                    .lineLimit(1)
                            }
                            .frame(width: 86)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Recipe Details Section (High Contrast, Crisp Borders)
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECIPE DETAILS")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textSecondary)
            
            VStack(spacing: 10) {
                // Title Field
                VStack(alignment: .leading, spacing: 4) {
                    Text("TITLE")
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.textTertiary)
                    
                    TextField("", text: $vm.title, prompt: Text("e.g., Truffle Tagliolini").foregroundColor(MealioColors.textTertiary))
                        .font(MealioFont.editorialTitle(size: 18))
                        .foregroundColor(MealioColors.textPrimary)
                        .tint(MealioColors.terracotta)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: 0xDCD5CB), lineWidth: 1.2)
                )
                
                // Description Field
                VStack(alignment: .leading, spacing: 4) {
                    Text("TAGLINE / SUBTITLE")
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.textTertiary)
                    
                    TextField("", text: $vm.subtitle, prompt: Text("A short, mouthwatering one-liner").foregroundColor(MealioColors.textTertiary))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(MealioColors.textPrimary)
                        .tint(MealioColors.terracotta)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: 0xDCD5CB), lineWidth: 1.2)
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Cuisine & Dietary Section (High Contrast Chips)
    private var cuisineAndDietarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CUISINE & DIETARY")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textSecondary)
            
            // Cuisines Row
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(vm.cuisines, id: \.self) { cuisine in
                        let isSelected = vm.selectedCuisine == cuisine
                        Button(action: {
                            HapticFeedback.light()
                            vm.selectedCuisine = cuisine
                        }) {
                            Text(cuisine)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                .lineLimit(1)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? MealioColors.terracotta : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected ? MealioColors.terracotta : Color(hex: 0xDCD5CB), lineWidth: 1.2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Dietary Row
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(vm.dietaryOptions, id: \.self) { diet in
                        let isSelected = vm.selectedDietary == diet
                        Button(action: {
                            HapticFeedback.light()
                            vm.selectedDietary = diet
                        }) {
                            Text(diet)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                .lineLimit(1)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? MealioColors.terracotta : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected ? MealioColors.terracotta : Color(hex: 0xDCD5CB), lineWidth: 1.2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Timing & Portions Section (Custom Steppers & Segmented Effort)
    private var timingAndPortionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIMING & PORTIONS")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textSecondary)
            
            HStack(spacing: 12) {
                // Prep Time
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PREP TIME")
                            .font(MealioFont.eyebrow(size: 9))
                            .foregroundColor(MealioColors.textTertiary)
                        Text("\(vm.prepMinutes) min")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MealioColors.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Button(action: {
                            HapticFeedback.light()
                            vm.prepMinutes = max(5, vm.prepMinutes - 5)
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(MealioColors.textPrimary)
                                .frame(width: 28, height: 28)
                                .background(MealioColors.cardSand)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            HapticFeedback.light()
                            vm.prepMinutes = min(180, vm.prepMinutes + 5)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(MealioColors.terracotta)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.2))
                
                // Cook Time
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("COOK TIME")
                            .font(MealioFont.eyebrow(size: 9))
                            .foregroundColor(MealioColors.textTertiary)
                        Text("\(vm.cookMinutes) min")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MealioColors.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Button(action: {
                            HapticFeedback.light()
                            vm.cookMinutes = max(5, vm.cookMinutes - 5)
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(MealioColors.textPrimary)
                                .frame(width: 28, height: 28)
                                .background(MealioColors.cardSand)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            HapticFeedback.light()
                            vm.cookMinutes = min(240, vm.cookMinutes + 5)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(MealioColors.terracotta)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.2))
            }
            
            // Effort & Servings Row
            HStack(spacing: 12) {
                // Effort Level (3 Segmented Buttons)
                VStack(alignment: .leading, spacing: 6) {
                    Text("EFFORT")
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.textTertiary)
                    
                    HStack(spacing: 6) {
                        ForEach(vm.effortOptions, id: \.self) { eff in
                            let isSel = vm.effort == eff
                            Button(action: {
                                HapticFeedback.light()
                                vm.effort = eff
                            }) {
                                Text(eff)
                                    .font(.system(size: 11, weight: isSel ? .bold : .medium))
                                    .foregroundColor(isSel ? .white : MealioColors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(isSel ? MealioColors.terracotta : MealioColors.cardSand.opacity(0.7))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.2))
                
                // Servings
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SERVINGS")
                            .font(MealioFont.eyebrow(size: 9))
                            .foregroundColor(MealioColors.textTertiary)
                        Text("\(vm.servings) \(vm.servings == 1 ? "cook" : "cooks")")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MealioColors.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Button(action: {
                            HapticFeedback.light()
                            vm.servings = max(1, vm.servings - 1)
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(MealioColors.textPrimary)
                                .frame(width: 28, height: 28)
                                .background(MealioColors.cardSand)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            HapticFeedback.light()
                            vm.servings = min(12, vm.servings + 1)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(MealioColors.terracotta)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.2))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Ingredients Section (Clear Contrast & Placeholders)
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("INGREDIENTS")
                    .font(MealioFont.eyebrow(size: 11))
                    .tracking(1.0)
                    .foregroundColor(MealioColors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    vm.addIngredient()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add item")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(MealioColors.terracotta)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(Array(vm.ingredients.indices), id: \.self) { idx in
                    HStack(spacing: 8) {
                        TextField("", text: $vm.ingredients[idx].name, prompt: Text("e.g. Fresh Basil").foregroundColor(MealioColors.textTertiary))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MealioColors.textPrimary)
                            .tint(MealioColors.terracotta)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.0))
                        
                        TextField("", text: $vm.ingredients[idx].quantity, prompt: Text("Amount").foregroundColor(MealioColors.textTertiary))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MealioColors.textPrimary)
                            .tint(MealioColors.terracotta)
                            .frame(width: 90)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.0))
                        
                        Button(action: {
                            HapticFeedback.light()
                            vm.removeIngredient(at: idx)
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(MealioColors.textTertiary)
                                .frame(width: 32, height: 32)
                                .background(MealioColors.cardSand.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Steps Section (Clear Contrast & Numbering)
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("COOKING STEPS")
                    .font(MealioFont.eyebrow(size: 11))
                    .tracking(1.0)
                    .foregroundColor(MealioColors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    vm.addStep()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add step")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(MealioColors.terracotta)
                }
            }
            
            VStack(spacing: 10) {
                ForEach(Array(vm.steps.indices), id: \.self) { idx in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(idx + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(MealioColors.terracotta)
                            .clipShape(Circle())
                            .padding(.top, 8)
                        
                        TextField("", text: $vm.steps[idx].instruction, prompt: Text("Describe this step...").foregroundColor(MealioColors.textTertiary), axis: .vertical)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MealioColors.textPrimary)
                            .tint(MealioColors.terracotta)
                            .lineLimit(2...4)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.0))
                        
                        Button(action: {
                            HapticFeedback.light()
                            vm.removeStep(at: idx)
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(MealioColors.textTertiary)
                                .frame(width: 32, height: 32)
                                .background(MealioColors.cardSand.opacity(0.6))
                                .clipShape(Circle())
                                .padding(.top, 6)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Chef Secret Section
    private var chefSecretSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CHEF'S SECRET TIP (OPTIONAL)")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textSecondary)
            
            TextField("", text: $vm.chefSecret, prompt: Text("A pro tip or finish that makes this dish sing...").foregroundColor(MealioColors.textTertiary), axis: .vertical)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(MealioColors.textPrimary)
                .tint(MealioColors.terracotta)
                .lineLimit(2...3)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xDCD5CB), lineWidth: 1.2))
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Save CTA Button
    private var saveButton: some View {
        Button(action: {
            guard vm.isValid else { return }
            HapticFeedback.success()
            let newRecipe = vm.buildRecipe()
            store.addCustomRecipe(newRecipe)
            onCreated?(newRecipe)
            dismiss()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("Save to My Kitchen")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(vm.isValid ? MealioColors.terracotta : MealioColors.textTertiary.opacity(0.45))
            .cornerRadius(30)
            .shadow(color: vm.isValid ? MealioColors.terracotta.opacity(0.35) : Color.clear, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(LiquidGlassPressStyle())
        .disabled(!vm.isValid)
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 30)
    }
}
