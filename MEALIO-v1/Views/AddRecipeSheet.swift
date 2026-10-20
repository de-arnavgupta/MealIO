import SwiftUI
import Combine

public class AddRecipeViewModel: ObservableObject {
    @Published public var title: String = ""
    @Published public var subtitle: String = ""
    @Published public var selectedCuisine: String = "Italian"
    @Published public var selectedDietary: String = "Non-Veg"
    @Published public var isHalal: Bool = true
    @Published public var prepMinutes: Int = 15
    @Published public var cookMinutes: Int = 25
    @Published public var effort: String = "MEDIUM"
    @Published public var servings: Int = 2
    @Published public var selectedImageIndex: Int = 0
    @Published public var chefSecret: String = ""
    
    // Ingredients
    @Published public var ingredients: [AddIngredientItem] = [
        AddIngredientItem(name: "Extra virgin olive oil", quantity: "2 tbsp"),
        AddIngredientItem(name: "Flaky sea salt & pepper", quantity: "To taste"),
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
    public let effortOptions = ["EASY", "MEDIUM", "HARD"]
    
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
            effort: effort,
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
                    .foregroundColor(MealioColors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Cover Selector
    private var coverSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COVER PLATE")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textTertiary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(vm.availableImages.enumerated()), id: \.offset) { index, item in
                        let isSelected = vm.selectedImageIndex == index
                        Button(action: {
                            HapticFeedback.selection()
                            vm.selectedImageIndex = index
                        }) {
                            VStack(spacing: 6) {
                                MealioImageView(item.name)
                                    .frame(width: 84, height: 84)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(isSelected ? MealioColors.terracotta : Color.clear, lineWidth: 2.5)
                                    )
                                    .shadow(color: isSelected ? MealioColors.terracotta.opacity(0.30) : Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                
                                Text(item.label)
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                                    .lineLimit(1)
                            }
                            .frame(width: 90)
                        }
                        .buttonStyle(LiquidGlassPressStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Recipe Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("RECIPE DETAILS")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textTertiary)
            
            VStack(spacing: 12) {
                TextField("Recipe title (e.g., Truffle Tagliolini)", text: $vm.title)
                    .font(MealioFont.editorialTitle(size: 18))
                    .foregroundColor(MealioColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(MealioColors.cardLight)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(MealioColors.divider, lineWidth: 0.8)
                    )
                
                TextField("One-liner description / tagline", text: $vm.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(MealioColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(MealioColors.cardLight)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(MealioColors.divider, lineWidth: 0.8)
                    )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Cuisine & Dietary Section
    private var cuisineAndDietarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CUISINE & DIETARY")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textTertiary)
            
            // Cuisines Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vm.cuisines, id: \.self) { cuisine in
                        let isSelected = vm.selectedCuisine == cuisine
                        Button(action: {
                            HapticFeedback.light()
                            vm.selectedCuisine = cuisine
                        }) {
                            Text(cuisine)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                .lineLimit(1)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                        }
                        .buttonStyle(LiquidGlassPressStyle())
                    }
                }
            }
            
            // Dietary Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vm.dietaryOptions, id: \.self) { diet in
                        let isSelected = vm.selectedDietary == diet
                        Button(action: {
                            HapticFeedback.light()
                            vm.selectedDietary = diet
                        }) {
                            Text(diet)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                .lineLimit(1)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                        }
                        .buttonStyle(LiquidGlassPressStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Timing & Portions Section
    private var timingAndPortionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TIMING & PORTIONS")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textTertiary)
            
            HStack(spacing: 12) {
                // Prep Time
                VStack(alignment: .leading, spacing: 4) {
                    Text("PREP")
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.textSecondary)
                    Stepper("\(vm.prepMinutes) min", value: $vm.prepMinutes, in: 5...120, step: 5)
                        .font(.system(size: 13, weight: .semibold))
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(MealioColors.cardLight)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(MealioColors.divider, lineWidth: 0.8))
                
                // Cook Time
                VStack(alignment: .leading, spacing: 4) {
                    Text("COOK")
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.textSecondary)
                    Stepper("\(vm.cookMinutes) min", value: $vm.cookMinutes, in: 5...180, step: 5)
                        .font(.system(size: 13, weight: .semibold))
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(MealioColors.cardLight)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(MealioColors.divider, lineWidth: 0.8))
            }
            
            HStack(spacing: 12) {
                // Effort
                HStack {
                    Text("EFFORT")
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.textSecondary)
                    Spacer()
                    ForEach(vm.effortOptions, id: \.self) { eff in
                        let isSel = vm.effort == eff
                        Button(action: {
                            HapticFeedback.light()
                            vm.effort = eff
                        }) {
                            Text(String(eff.prefix(1)))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(isSel ? .white : MealioColors.textPrimary)
                                .frame(width: 28, height: 28)
                                .background(isSel ? MealioColors.terracotta : MealioColors.cardSand)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(MealioColors.cardLight)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(MealioColors.divider, lineWidth: 0.8))
                
                // Servings
                VStack(alignment: .leading, spacing: 4) {
                    Text("SERVINGS")
                        .font(MealioFont.eyebrow(size: 9))
                        .foregroundColor(MealioColors.textSecondary)
                    Stepper("\(vm.servings) people", value: $vm.servings, in: 1...12)
                        .font(.system(size: 13, weight: .semibold))
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(MealioColors.cardLight)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(MealioColors.divider, lineWidth: 0.8))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("INGREDIENTS")
                    .font(MealioFont.eyebrow(size: 11))
                    .tracking(1.0)
                    .foregroundColor(MealioColors.textTertiary)
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    vm.addIngredient()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(MealioColors.terracotta)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(Array(vm.ingredients.indices), id: \.self) { idx in
                    HStack(spacing: 8) {
                        TextField("Ingredient (e.g. Fresh Basil)", text: $vm.ingredients[idx].name)
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(MealioColors.cardLight)
                            .cornerRadius(12)
                        
                        TextField("Amount", text: $vm.ingredients[idx].quantity)
                            .font(.system(size: 14))
                            .frame(width: 90)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(MealioColors.cardLight)
                            .cornerRadius(12)
                        
                        Button(action: {
                            HapticFeedback.light()
                            vm.removeIngredient(at: idx)
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 18))
                                .foregroundColor(MealioColors.textTertiary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Steps Section
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("COOKING STEPS")
                    .font(MealioFont.eyebrow(size: 11))
                    .tracking(1.0)
                    .foregroundColor(MealioColors.textTertiary)
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    vm.addStep()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Step")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(MealioColors.terracotta)
                }
            }
            
            VStack(spacing: 10) {
                ForEach(Array(vm.steps.indices), id: \.self) { idx in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(idx + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(MealioColors.terracotta)
                            .frame(width: 24, height: 24)
                            .background(MealioColors.terracottaLight)
                            .clipShape(Circle())
                            .padding(.top, 4)
                        
                        TextField("Step instructions...", text: $vm.steps[idx].instruction, axis: .vertical)
                            .font(.system(size: 14))
                            .lineLimit(2...4)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(MealioColors.cardLight)
                            .cornerRadius(12)
                        
                        Button(action: {
                            HapticFeedback.light()
                            vm.removeStep(at: idx)
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 18))
                                .foregroundColor(MealioColors.textTertiary)
                                .padding(.top, 8)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Chef Secret Section
    private var chefSecretSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CHEF'S SECRET TIP (OPTIONAL)")
                .font(MealioFont.eyebrow(size: 11))
                .tracking(1.0)
                .foregroundColor(MealioColors.textTertiary)
            
            TextField("A special tip to make this dish exceptional...", text: $vm.chefSecret, axis: .vertical)
                .font(.system(size: 14))
                .lineLimit(2...3)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(MealioColors.cardLight)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(MealioColors.divider, lineWidth: 0.8))
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
            .background(vm.isValid ? MealioColors.terracotta : MealioColors.textTertiary.opacity(0.4))
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
