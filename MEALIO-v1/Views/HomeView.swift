import SwiftUI
import Combine

public class HomeViewModel: ObservableObject {
    @Published public var selectedHeroIndex: Int = 0
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
                .presentationDetents([.fraction(0.85), .large])
        }
        .sheet(isPresented: $vm.showingProfileSheet) {
            UserProfileSheet(store: store)
                .presentationDetents([.fraction(0.65), .large])
        }
        .sheet(isPresented: $vm.showingWisdomSheet) {
            KitchenWisdomSheet(activeWisdom: store.activeWisdom)
                .presentationDetents([.fraction(0.75), .large])
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
                .presentationDetents([.large])
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
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(MealioColors.textTertiary)
            
            TextField("A dish, an ingredient, a craving...", text: $store.searchText)
                .font(.system(size: 14))
                .foregroundColor(MealioColors.textPrimary)
            
            if !store.searchText.isEmpty {
                Button(action: {
                    store.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(MealioColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Button(action: {
                vm.showingFilterSheet = true
            }) {
                ZStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15))
                        .foregroundColor(
                            (store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil) ?
                                MealioColors.terracottaDark : MealioColors.terracotta
                        )
                    
                    if store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil {
                        Circle()
                            .fill(MealioColors.terracotta)
                            .frame(width: 6, height: 6)
                            .offset(x: 8, y: -8)
                    }
                }
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(MealioColors.divider, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 24).fill(MealioColors.cardLight))
        )
    }
    
    // MARK: - Category Filter Pills
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RecipeCategory.allCases) { category in
                    let isSelected = store.selectedCategory == category
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            store.selectedCategory = category
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isSelected ? MealioColors.textPrimary : MealioColors.pillBackground)
                            )
                    }
                    .buttonStyle(.plain)
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
                    vm.activeCollectionTitle = "The Evening Edit"
                    vm.activeCollectionSubtitle = "Curated luxury dinners for tonight's table."
                    vm.activeCollectionRecipes = store.eveningEditRecipes
                }) {
                    HStack(spacing: 2) {
                        Text("Explore")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(MealioColors.terracotta)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            
            let eveningItems = store.eveningEditRecipes
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(eveningItems.enumerated()), id: \.element.id) { index, recipe in
                        Button(action: {
                            store.recordVisitedRecipe(recipe)
                            selectedRecipeForNavigation = recipe
                        }) {
                            ZStack(alignment: .bottomLeading) {
                                MealioImageView(recipe.cardImageName)
                                    .frame(width: 320, height: 270)
                                    .clipped()
                                    .cornerRadius(24)
                                    .overlay(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.black.opacity(0.1),
                                                Color.black.opacity(0.2),
                                                Color.black.opacity(0.85)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .cornerRadius(24)
                                    )
                                
                                // Top floating badge
                                VStack {
                                    HStack {
                                        Text(recipe.categoryBadge)
                                            .font(MealioFont.eyebrow(size: 9))
                                            .tracking(1.0)
                                            .foregroundColor(MealioColors.textPrimary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.white.opacity(0.92))
                                            .clipShape(Capsule())
                                        Spacer()
                                    }
                                    .padding(16)
                                    Spacer()
                                }
                                
                                // Bottom card metadata
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(recipe.title)
                                        .font(MealioFont.editorialHero(size: 26))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack(spacing: 8) {
                                        Text(recipe.totalTime)
                                        Text("•")
                                        Text(recipe.effort)
                                        Text("•")
                                        HStack(spacing: 3) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(MealioColors.cookingGlow)
                                            Text(String(format: "%.1f", recipe.rating))
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.85))
                                }
                                .padding(20)
                            }
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Carousel page indicator dots
            HStack(spacing: 6) {
                Spacer()
                ForEach(0..<min(eveningItems.count, 6), id: \.self) { idx in
                    if idx == vm.selectedHeroIndex {
                        Capsule()
                            .fill(MealioColors.terracotta)
                            .frame(width: 20, height: 4)
                    } else {
                        Circle()
                            .fill(MealioColors.divider)
                            .frame(width: 5, height: 5)
                    }
                }
                Spacer()
            }
            .padding(.top, 2)
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
                    vm.activeCollectionTitle = "Last visited"
                    vm.activeCollectionSubtitle = "Recipes you recently explored."
                    vm.activeCollectionRecipes = store.lastVisitedRecipes
                }) {
                    HStack(spacing: 2) {
                        Text("View all")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(MealioColors.terracotta)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.lastVisitedRecipes) { recipe in
                        Button(action: {
                            store.recordVisitedRecipe(recipe)
                            selectedRecipeForNavigation = recipe
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                MealioImageView(recipe.cardImageName)
                                    .frame(width: 145, height: 95)
                                    .clipped()
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(recipe.title)
                                        .font(MealioFont.editorialTitle(size: 15))
                                        .foregroundColor(MealioColors.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text("\(recipe.totalTime) • \(recipe.effort)")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(MealioColors.textSecondary)
                                }
                            }
                            .padding(10)
                            .frame(width: 165, height: 160)
                            .background(MealioColors.cardLight)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
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
                    vm.activeCollectionTitle = "Short on time. Not taste."
                    vm.activeCollectionSubtitle = "Fast weeknight dinners ready in 20 minutes or less."
                    vm.activeCollectionRecipes = store.quickRecipes
                }) {
                    HStack(spacing: 2) {
                        Text("More")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(MealioColors.terracotta)
                    .contentShape(Rectangle())
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
            
            // Cuisine Quick Sub-Tabs
            let tabs = ["All", "Italian", "French", "Japanese", "Mexican", "Indian", "Mediterranean", "Thai", "Spanish", "American", "Middle Eastern"]
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tabs, id: \.self) { tab in
                        let isSelected = vm.selectedExploreCuisineTab == tab
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                vm.selectedExploreCuisineTab = tab
                                vm.visibleRecipesCount = 16
                            }
                        }) {
                            Text(tab)
                                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? MealioColors.terracotta : MealioColors.pillBackground)
                                )
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
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
                        }
                    )
                }
            }
        }
    }
}
