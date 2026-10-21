import SwiftUI
import Combine

public enum RecipeDetailTab: String, CaseIterable {
    case overview = "Overview"
    case ingredients = "Ingredients"
    case method = "Method"
}

public class RecipeDetailViewModel: ObservableObject {
    @Published public var selectedTab: RecipeDetailTab = .overview
    @Published public var servings: Int
    @Published public var checkedIngredients: Set<UUID> = []
    @Published public var showingGrocerySheet: Bool = false
    @Published public var showingHandsFreeCooking: Bool = false
    @Published public var cookingInitialStep: Int? = nil
    @Published public var showingAuthorSheet: Bool = false
    
    public init(baseServings: Int) {
        self.servings = baseServings
    }
}

public struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: RecipeStore
    let recipe: Recipe
    @StateObject private var vm: RecipeDetailViewModel
    
    public init(store: RecipeStore, recipe: Recipe) {
        self.store = store
        self.recipe = recipe
        self._vm = StateObject(wrappedValue: RecipeDetailViewModel(baseServings: recipe.baseServings))
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Hero Section
                    heroSection
                    
                    // Sliding Sheet Container (Warm Ivory)
                    VStack(alignment: .leading, spacing: 20) {
                        // Grabber handle
                        HStack {
                            Spacer()
                            Capsule()
                                .fill(MealioColors.textTertiary.opacity(0.4))
                                .frame(width: 36, height: 4)
                            Spacer()
                        }
                        .padding(.top, 12)
                        
                        // Segmented tabs: Overview | Ingredients | Method
                        tabsRow
                        
                        // Tab Content
                        switch vm.selectedTab {
                        case .overview:
                            overviewContent
                        case .ingredients:
                            ingredientsContent
                            methodContent
                        case .method:
                            methodContent
                        }
                        
                        Spacer()
                            .frame(height: 100) // Padding for sticky bottom CTA
                    }
                    .padding(.horizontal, 20)
                    .background(
                        MealioColors.background
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
                            .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: -4)
                    )
                    .offset(y: -24)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Sticky Bottom CTA Bar
            stickyBottomBar
        }
        .background(MealioColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $vm.showingGrocerySheet) {
            GroceryListSheet(store: store, recipe: recipe, servings: vm.servings)
                .presentationDetents([.fraction(0.55), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.55)))
        }
        .fullScreenCover(isPresented: $vm.showingHandsFreeCooking) {
            HandsFreeCookingView(
                session: store.startCookingSession(recipe: recipe, initialStepIndex: vm.cookingInitialStep)
            )
        }
        .alert("From the kitchen of \(recipe.authorName)", isPresented: $vm.showingAuthorSheet) {
            Button("Close", role: .cancel) {}
        } message: {
            Text("\(recipe.authorSubtitle)\n\nPassionate culinary creator curating authentic \(recipe.cuisine) flavors and everyday kitchen wisdom on Meal-IO.")
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .top) {
            MealioImageView(recipe.heroImageName)
                .frame(maxWidth: .infinity)
                .frame(height: 480)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.6),
                            Color.clear,
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .liquidGlassCircle(isClear: false)
                    }
                    .buttonStyle(LiquidGlassPressStyle())
                    
                    Spacer()
                    
                    Text(recipe.collectionTag)
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.5)
                        .foregroundColor(Color.white.opacity(0.85))
                    
                    Spacer()
                    
                    Button(action: {
                        HapticFeedback.light()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
                            store.toggleSave(recipe.id)
                        }
                    }) {
                        Image(systemName: store.isRecipeSaved(recipe.id) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(store.isRecipeSaved(recipe.id) ? MealioColors.terracottaLight : .white)
                            .symbolEffect(.bounce, value: store.isRecipeSaved(recipe.id))
                            .frame(width: 40, height: 40)
                            .liquidGlassCircle(isClear: false)
                    }
                    .buttonStyle(LiquidGlassPressStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                
                Spacer()
                
                if let socialUser = recipe.activeSocialUser {
                    HStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: "location.north.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(-45))
                            
                            Text(socialUser)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(MealioColors.socialPointer)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundColor(MealioColors.terracotta)
                        
                        Text(recipe.categoryBadge)
                            .font(MealioFont.eyebrow(size: 10))
                            .tracking(1.5)
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                    
                    Text(recipe.title)
                        .font(MealioFont.editorialHero(size: 38))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
                    
                    Text(recipe.subtitle)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.9))
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(MealioColors.cookingGlow)
                            }
                        }
                        
                        Text(String(format: "%.1f", recipe.rating))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("•  \(recipe.homeCooksCount) home cooks")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Spacer()
                        
                        ShareLink(
                            item: "\(recipe.title) • \(recipe.subtitle)\nCook this tonight on Meal-IO!",
                            subject: Text(recipe.title),
                            message: Text("Check out this recipe for \(recipe.title) on Meal-IO!")
                        ) {
                            HStack(spacing: 4) {
                                Text("Share")
                                    .font(.system(size: 13, weight: .medium))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(Color.white.opacity(0.95))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Tabs Row
    private var tabsRow: some View {
        HStack(spacing: 24) {
            ForEach(RecipeDetailTab.allCases, id: \.self) { tab in
                let isSelected = vm.selectedTab == tab
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                        
                        Rectangle()
                            .fill(isSelected ? MealioColors.terracotta : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .overlay(
            Rectangle()
                .fill(MealioColors.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Overview Content
    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL TIME")
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.0)
                        .foregroundColor(MealioColors.textTertiary)
                    Text(recipe.totalTime)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(MealioColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("SERVES")
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.0)
                        .foregroundColor(MealioColors.textTertiary)
                    Text("\(vm.servings) people")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(MealioColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("EFFORT")
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.0)
                        .foregroundColor(MealioColors.textTertiary)
                    Text(recipe.effort)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(MealioColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 4)
            
            Text(recipe.description)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(MealioColors.textSecondary)
                .lineSpacing(5)
            
            Button(action: {
                vm.showingAuthorSheet = true
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(MealioColors.peachCard)
                            .frame(width: 44, height: 44)
                        
                        Text(recipe.authorInitials)
                            .font(MealioFont.brandLogo(size: 14))
                            .foregroundColor(MealioColors.terracotta)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("From the kitchen of \(recipe.authorName)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(MealioColors.textPrimary)
                        
                        Text(recipe.authorSubtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(MealioColors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(MealioColors.textTertiary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Button(action: {
                vm.showingHandsFreeCooking = true
            }) {
                HStack(spacing: 10) {
                    Text("Let's get cooking")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "fork.knife")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(MealioColors.terracotta)
                .cornerRadius(30)
                .shadow(color: MealioColors.terracotta.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    vm.selectedTab = .ingredients
                }
            }) {
                HStack(spacing: 6) {
                    Spacer()
                    Text("Explore ingredients & method")
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                }
                .foregroundColor(MealioColors.terracotta)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Ingredients Content
    private var ingredientsContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("A few good things.")
                        .font(MealioFont.editorialHero(size: 26))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text("\(recipe.ingredients.count) ingredients. A little everyday magic.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.top, 8)
            
            HStack {
                Text("For \(vm.servings) people")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                ServingsStepper(servings: $vm.servings)
            }
            
            VStack(spacing: 0) {
                ForEach(recipe.ingredients) { item in
                    let isChecked = vm.checkedIngredients.contains(item.id)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isChecked {
                                vm.checkedIngredients.remove(item.id)
                            } else {
                                vm.checkedIngredients.insert(item.id)
                            }
                        }
                    }) {
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(isChecked ? MealioColors.terracotta : MealioColors.divider, lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(isChecked ? MealioColors.terracotta : Color.clear)
                                    )
                                
                                if isChecked {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isChecked ? MealioColors.textTertiary : MealioColors.textPrimary)
                                    .strikethrough(isChecked)
                                
                                if let note = item.note {
                                    Text(note)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(MealioColors.textTertiary)
                                }
                            }
                            
                            Spacer()
                            
                            Text(item.formattedQuantity(forServings: vm.servings, baseServings: recipe.baseServings))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(MealioColors.textSecondary)
                        }
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .background(MealioColors.divider.opacity(0.6))
                }
            }
            
            Button(action: {
                vm.showingGrocerySheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "basket")
                        .font(.system(size: 14))
                    Text("Add to grocery list")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(MealioColors.terracotta)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .stroke(MealioColors.terracotta, lineWidth: 1.5)
                        .background(Capsule().fill(MealioColors.cardLight))
                )
            }
            .buttonStyle(.plain)
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(MealioColors.oliveQuote)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.chefSecretTitle)
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.0)
                        .foregroundColor(MealioColors.oliveQuote)
                    
                    Text(recipe.chefSecretBody)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(MealioColors.textPrimary)
                        .lineSpacing(3)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(MealioColors.oliveTint)
            )
        }
    }
    
    // MARK: - Method Content
    private var methodContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Make a little magic.")
                    .font(MealioFont.editorialHero(size: 26))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                Text("\(recipe.steps.count) steps")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(MealioColors.textTertiary)
            }
            .padding(.top, 14)
            
            VStack(spacing: 16) {
                ForEach(recipe.steps) { step in
                    Button(action: {
                        vm.cookingInitialStep = max(0, step.stepIndex - 1)
                        vm.showingHandsFreeCooking = true
                    }) {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(step.stepIndex == 4 ? MealioColors.terracotta : MealioColors.peachCard)
                                    .frame(width: 28, height: 28)
                                
                                Text(String(format: "%02d", step.stepIndex))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(step.stepIndex == 4 ? .white : MealioColors.terracotta)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(step.title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(MealioColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    if step.hasTimer {
                                        HStack(spacing: 3) {
                                            Image(systemName: "timer")
                                                .font(.system(size: 10))
                                            Text("\(step.durationMinutes) min")
                                                .font(.system(size: 11, weight: .semibold))
                                        }
                                        .foregroundColor(MealioColors.terracotta)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(MealioColors.terracottaLight)
                                        .cornerRadius(6)
                                    } else {
                                        Text("\(step.durationMinutes) min")
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundColor(MealioColors.textTertiary)
                                    }
                                }
                                
                                Text(step.instruction)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(MealioColors.textSecondary)
                                    .lineSpacing(3)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            MealioImageView(recipe.platedImageName)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .cornerRadius(18)
                .clipped()
                .padding(.top, 8)
        }
    }
    
    // MARK: - Sticky Bottom Bar
    @ViewBuilder
    private var stickyBottomBar: some View {
        if vm.selectedTab != .overview {
            VStack(spacing: 6) {
                Button(action: {
                    vm.showingHandsFreeCooking = true
                }) {
                    HStack(spacing: 8) {
                        Text("Start hands-free cooking")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "mic.fill")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(MealioColors.terracotta)
                    .cornerRadius(30)
                    .shadow(color: MealioColors.terracotta.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                Text("Recipe saved for offline cooking • Your kitchen, uninterrupted.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(MealioColors.textTertiary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(
                Rectangle()
                    .fill(.regularMaterial)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
