import SwiftUI
import Combine

public class HomeViewModel: ObservableObject {
    @Published public var selectedHeroIndex: Int = 3
    @Published public var showingFilterSheet: Bool = false
    @Published public var showingProfileSheet: Bool = false
    @Published public var showingWisdomSheet: Bool = false
    @Published public var activeCollectionTitle: String? = nil
    @Published public var activeCollectionSubtitle: String = ""
    @Published public var activeCollectionRecipes: [Recipe] = []
    @Published public var selectedExploreCuisineTab: String = "All"
    @Published public var visibleRecipesCount: Int = 16
    
    public init() {}
}

public struct HomeView: View {
    @ObservedObject var store: RecipeStore
    @Binding var selectedRecipeForNavigation: Recipe?
    @StateObject private var vm = HomeViewModel()
    
    public init(store: RecipeStore, selectedRecipeForNavigation: Binding<Recipe?>) {
        self.store = store
        self._selectedRecipeForNavigation = selectedRecipeForNavigation
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header: Wordmark & Avatar
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Hero Headline: "Make tonight something special."
                Text("Make tonight\nsomething special.")
                    .font(MealioFont.editorialHero(size: 34))
                    .foregroundColor(MealioColors.textPrimary)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                // Search & Filter Bar
                searchBar
                    .padding(.horizontal, 20)
                
                // Live Search Results (if user is searching)
                if !store.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    searchResultsSection
                        .padding(.horizontal, 20)
                } else {
                    // Category Filter Pills: "For you", "Quick & lovely", "Seasonal" + Cuisines
                    categoryPills
                    
                    // If a specific category or filter is active, show filtered results
                    if store.selectedCategory != .forYou || store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil {
                        filteredResultsSection
                            .padding(.horizontal, 20)
                    } else {
                        // Section 1: "The evening edit" (Dynamic Carousel with daily rotating luxury dishes)
                        eveningEditSection
                        
                        // Section 2: "Last visited" (Horizontal Shelf)
                        lastVisitedSection
                        
                        // Section 3: "Short on time. Not taste." (Dynamic fast weeknight recipes)
                        shortOnTimeSection
                        
                        // Section 4: "Cuisines of the World" (10 World Cuisines Shelf)
                        cuisinesOfTheWorldSection
                        
                        // Section 5: "Explore All Recipes" (Uniform Grid across all 200 recipes)
                        exploreAllRecipesSection
                            .padding(.horizontal, 20)
                    }
                }
                
                // Bottom spacing for tab bar
                Spacer()
                    .frame(height: 80)
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
        .refreshable {
            withAnimation(.easeInOut(duration: 0.3)) {
                store.refreshSessionFeed()
            }
        }
        .sheet(isPresented: $vm.showingFilterSheet) {
            FilterSheetView(store: store)
                .presentationDetents([.fraction(0.52), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.52)))
        }
        .sheet(isPresented: $vm.showingProfileSheet) {
            UserProfileSheet(store: store)
                .presentationDetents([.fraction(0.65), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $vm.showingWisdomSheet) {
            KitchenWisdomSheet(activeWisdom: store.activeWisdom)
                .presentationDetents([.fraction(0.72), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: Binding<Bool>(
            get: { vm.activeCollectionTitle != nil },
            set: { if !$0 { vm.activeCollectionTitle = nil } }
        )) {
            if let title = vm.activeCollectionTitle {
                CollectionListView(
                    store: store,
                    title: title,
                    subtitle: vm.activeCollectionSubtitle,
                    recipes: vm.activeCollectionRecipes,
                    selectedRecipeForNavigation: $selectedRecipeForNavigation
                )
                .presentationDetents([.fraction(0.88), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Meal-IO")
                .font(MealioFont.brandLogo(size: 28))
                .foregroundColor(MealioColors.textPrimary)
            
            Spacer()
            
            Button(action: {
                vm.showingProfileSheet = true
            }) {
                HStack(spacing: 10) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("A little inspiration for")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(MealioColors.textSecondary)
                        Text("your kitchen, Alex")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(MealioColors.textPrimary)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(MealioColors.peachCard)
                            .frame(width: 36, height: 36)
                        
                        Text("A")
                            .font(MealioFont.brandLogo(size: 16))
                            .foregroundColor(MealioColors.terracotta)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Search Bar (Liquid Glass)
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(MealioColors.textSecondary)
            
            TextField("A dish, an ingredient, a craving...", text: $store.searchText)
                .font(.system(size: 15))
                .foregroundColor(MealioColors.textPrimary)
            
            if !store.searchText.isEmpty {
                Button(action: {
                    HapticFeedback.light()
                    store.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(MealioColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Button(action: {
                HapticFeedback.light()
                vm.showingFilterSheet = true
            }) {
                ZStack {
                    Circle()
                        .fill(
                            (store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil) ?
                            MealioColors.terracotta : Color.white.opacity(0.65)
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(
                            (store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil) ?
                            .white : MealioColors.textPrimary
                        )
                    
                    if store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .offset(x: 9, y: -9)
                    }
                }
            }
            .buttonStyle(LiquidGlassPressStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Category Filter Pills (Liquid Glass)
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RecipeCategory.allCases) { category in
                    let isSelected = store.selectedCategory == category
                    Button(action: {
                        HapticFeedback.selection()
                        withAnimation(.spring(response: 0.30, dampingFraction: 0.74)) {
                            store.selectedCategory = category
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .liquidGlassCapsule(isSelected: isSelected)
                    }
                    .buttonStyle(LiquidGlassPressStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Section 1: The Evening Edit (Dynamic Carousel with daily rotating luxury dishes)
    private var eveningEditSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("The evening edit")
                    .font(MealioFont.editorialTitle(size: 22))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    vm.activeCollectionTitle = "The Evening Edit"
                    vm.activeCollectionSubtitle = "Curated luxury dinners for tonight's table."
                    vm.activeCollectionRecipes = store.eveningEditRecipes
                }) {
                    HStack(spacing: 3) {
                        Text("Explore")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(MealioColors.terracotta)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .liquidGlassCapsule()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            
            let eveningItems = Array(store.eveningEditRecipes.prefix(7))
            let totalItems = eveningItems.count
            
            // Fixed Window Carousel: Window frame remains rock-solid stationary, only the photo & content change inside
            ZStack(alignment: .bottomLeading) {
                // Photo paging inside the fixed window
                TabView(selection: $vm.selectedHeroIndex) {
                    ForEach(Array(eveningItems.enumerated()), id: \.offset) { index, recipe in
                        MealioImageView(recipe.cardImageName)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.recordVisitedRecipe(recipe)
                                selectedRecipeForNavigation = recipe
                            }
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Vignette gradient overlay pinned to the window
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.18),
                        Color.black.opacity(0.85)
                    ]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
                
                // Top floating badge: "TODAY'S SPECIAL" pinned to the window
                VStack {
                    HStack {
                        Text("TODAY'S SPECIAL")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(0.6)
                            .foregroundColor(MealioColors.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.88))
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                .allowsHitTesting(false)
                
                // Bottom card metadata pinned to the window, dynamically updating with selected photo
                if eveningItems.indices.contains(vm.selectedHeroIndex) {
                    let currentRecipe = eveningItems[vm.selectedHeroIndex]
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(currentRecipe.title)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .id("title-\(currentRecipe.id)")
                            .transition(.opacity)
                        
                        HStack(spacing: 4) {
                            Text(currentRecipe.totalTime)
                            Text("·")
                            Text(currentRecipe.effort)
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white)
                                Text(String(format: "%.1f", currentRecipe.rating))
                                    .font(.system(size: 12, weight: .semibold))
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.92))
                        .lineLimit(1)
                        .id("meta-\(currentRecipe.id)")
                        .transition(.opacity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                    .allowsHitTesting(false)
                }
                
                // Centered tapered pagination dots pinned to the window
                HStack(spacing: 5) {
                    ForEach(0..<min(totalItems, 7), id: \.self) { dotIdx in
                        let distance = abs(dotIdx - vm.selectedHeroIndex)
                        let diameter: CGFloat = distance == 0 ? 7.5 : (distance == 1 ? 5.5 : (distance == 2 ? 4.5 : 3.5))
                        let opacity: Double = distance == 0 ? 1.0 : (distance == 1 ? 0.6 : (distance == 2 ? 0.4 : 0.25))
                        
                        Circle()
                            .fill(Color.white.opacity(opacity))
                            .frame(width: diameter, height: diameter)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    vm.selectedHeroIndex = dotIdx
                                }
                            }
                    }
                }
                .offset(x: 20)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 270)
            .cornerRadius(28)
            .padding(.horizontal, 20)
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
            .onAppear {
                if totalItems > 0 && (vm.selectedHeroIndex >= totalItems || vm.selectedHeroIndex == 0) {
                    vm.selectedHeroIndex = min(3, totalItems - 1)
                }
            }
        }
    }
    
    // MARK: - Section 2: Last Visited (Horizontal Shelf)
    private var lastVisitedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last visited")
                        .font(MealioFont.editorialTitle(size: 22))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Pick up right where you left off")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    vm.activeCollectionTitle = "Last visited"
                    vm.activeCollectionSubtitle = "Recipes you recently explored."
                    vm.activeCollectionRecipes = store.lastVisitedRecipes
                }) {
                    HStack(spacing: 3) {
                        Text("View all")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(MealioColors.terracotta)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .liquidGlassCapsule()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.lastVisitedRecipes) { recipe in
                        RecipeCardView(
                            recipe: recipe,
                            isSaved: store.isRecipeSaved(recipe.id),
                            onSelect: {
                                store.recordVisitedRecipe(recipe)
                                selectedRecipeForNavigation = recipe
                            },
                            onToggleSave: {
                                store.toggleSave(recipe.id)
                            },
                            onAddToGroceries: {
                                store.addIngredientsToGroceryList(recipe.ingredients.filter { !$0.isInPantry })
                            }
                        )
                        .frame(width: 175)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Section 3: Short On Time. Not Taste. (Default Explore Rectangular Card, Horizontal Scroll)
    private var shortOnTimeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Short on time. Not taste.")
                        .font(MealioFont.editorialTitle(size: 22))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Fast weeknight dinners ready in 20 minutes or less")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    vm.activeCollectionTitle = "Short on time. Not taste."
                    vm.activeCollectionSubtitle = "Fast weeknight dinners ready in 20 minutes or less."
                    vm.activeCollectionRecipes = store.quickRecipes
                }) {
                    HStack(spacing: 3) {
                        Text("More")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(MealioColors.terracotta)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .liquidGlassCapsule()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.quickRecipes) { recipe in
                        RecipeCardView(
                            recipe: recipe,
                            isSaved: store.isRecipeSaved(recipe.id),
                            onSelect: {
                                store.recordVisitedRecipe(recipe)
                                selectedRecipeForNavigation = recipe
                            },
                            onToggleSave: {
                                store.toggleSave(recipe.id)
                            },
                            onAddToGroceries: {
                                store.addIngredientsToGroceryList(recipe.ingredients.filter { !$0.isInPantry })
                            }
                        )
                        .frame(width: 175)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Section 4: Cuisines of the World (Card Style previously in Short On Time)
    private var cuisinesOfTheWorldSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cuisines of the world")
                        .font(MealioFont.editorialTitle(size: 22))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Explore 10 authentic culinary traditions")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.worldCuisines) { cuisine in
                        Button(action: {
                            vm.activeCollectionTitle = "\(cuisine.name) Cuisine"
                            vm.activeCollectionSubtitle = cuisine.tagline
                            vm.activeCollectionRecipes = store.recipes(forCuisine: cuisine.name)
                        }) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 6) {
                                        Text(cuisine.emoji)
                                            .font(.system(size: 14))
                                        Text("\(cuisine.count) RECIPES")
                                            .font(MealioFont.eyebrow(size: 9))
                                            .tracking(0.8)
                                            .foregroundColor(MealioColors.textOlive)
                                    }
                                    
                                    Text(cuisine.name)
                                        .font(MealioFont.editorialTitle(size: 18))
                                        .foregroundColor(MealioColors.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text(cuisine.tagline)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(MealioColors.textSecondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                MealioImageView(cuisine.sampleImage)
                                    .frame(width: 75, height: 75)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .padding(14)
                            .frame(width: 260, height: 115)
                            .background(MealioColors.sageGreen)
                            .cornerRadius(20)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Section 5: Explore All Recipes (100% Uniform Card Dimensions)
    private var exploreAllRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Explore all recipes")
                        .font(MealioFont.editorialTitle(size: 22))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("All \(store.allRecipes.count) recipes across 10 cuisines")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
            }
            
            // Cuisine Quick Sub-Tabs (Liquid Glass)
            let tabs = ["All", "Italian", "French", "Japanese", "Mexican", "Indian", "Mediterranean", "Thai", "Spanish", "American", "Middle Eastern"]
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tabs, id: \.self) { tab in
                        let isSelected = vm.selectedExploreCuisineTab == tab
                        Button(action: {
                            HapticFeedback.light()
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                                vm.selectedExploreCuisineTab = tab
                                vm.visibleRecipesCount = 16
                            }
                        }) {
                            Text(tab)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                        }
                        .buttonStyle(LiquidGlassPressStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            
            let sourceList: [Recipe] = {
                if vm.selectedExploreCuisineTab == "All" {
                    return store.allRecipes
                } else {
                    return store.recipes(forCuisine: vm.selectedExploreCuisineTab)
                }
            }()
            
            let displayed = Array(sourceList.prefix(vm.visibleRecipesCount))
            
            // 2-Column Grid with Strict Geometric Uniformity
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                ForEach(displayed) { recipe in
                    RecipeCardView(
                        recipe: recipe,
                        isSaved: store.isRecipeSaved(recipe.id),
                        onSelect: {
                            store.recordVisitedRecipe(recipe)
                            selectedRecipeForNavigation = recipe
                        },
                        onToggleSave: {
                            store.toggleSave(recipe.id)
                        },
                        onAddToGroceries: {
                            store.addIngredientsToGroceryList(recipe.ingredients.filter { !$0.isInPantry })
                        }
                    )
                }
            }
            
            if displayed.count < sourceList.count {
                Button(action: {
                    withAnimation {
                        vm.visibleRecipesCount += 16
                    }
                }) {
                    Text("Load more (\(sourceList.count - displayed.count) remaining)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MealioColors.terracotta)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .stroke(MealioColors.terracotta, lineWidth: 1.5)
                                .background(Capsule().fill(MealioColors.cardLight))
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Live Search Results Section
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let results = store.searchResults
            HStack {
                Text("Search Results")
                    .font(MealioFont.editorialTitle(size: 20))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                Text("\(results.count) found")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(MealioColors.textSecondary)
            }
            
            if results.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(MealioColors.textTertiary)
                    Text("No recipes matched \"\(store.searchText)\"")
                        .font(MealioFont.editorialTitle(size: 16))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Try searching for ingredients like 'scallops', 'salmon', or 'pasta'.")
                        .font(.system(size: 13))
                        .foregroundColor(MealioColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                    ForEach(results) { recipe in
                        RecipeCardView(
                            recipe: recipe,
                            isSaved: store.isRecipeSaved(recipe.id),
                            onSelect: {
                                selectedRecipeForNavigation = recipe
                            },
                            onToggleSave: {
                                store.toggleSave(recipe.id)
                            },
                            onAddToGroceries: {
                                store.addIngredientsToGroceryList(recipe.ingredients.filter { !$0.isInPantry })
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Filtered Results Section
    private var filteredResultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let list = store.filteredRecipes
            HStack {
                Text("\(store.selectedCategory.rawValue) Recipes")
                    .font(MealioFont.editorialTitle(size: 20))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                Text("\(list.count) recipes")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(MealioColors.textSecondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                ForEach(list) { recipe in
                    RecipeCardView(
                        recipe: recipe,
                        isSaved: store.isRecipeSaved(recipe.id),
                        onSelect: {
                            store.recordVisitedRecipe(recipe)
                            selectedRecipeForNavigation = recipe
                        },
                        onToggleSave: {
                            store.toggleSave(recipe.id)
                        },
                        onAddToGroceries: {
                            store.addIngredientsToGroceryList(recipe.ingredients.filter { !$0.isInPantry })
                        }
                    )
                }
            }
        }
    }
}
