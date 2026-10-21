import SwiftUI
import Combine

// MARK: - Section Header Liquid Glass Arrow Button
public struct SectionHeaderArrowButton: View {
    var action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            ZStack {
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(width: 36, height: 36)
            .liquidGlassCircle(isClear: false)
            .contentShape(Rectangle())
            .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(LiquidGlassPressStyle())
        .accessibilityLabel("View collection")
    }
}

public struct HomeScrollOffsetKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public struct ActiveLetterInfo: Equatable {
    public let letter: String
    public let minY: CGFloat
    public init(letter: String, minY: CGFloat) {
        self.letter = letter
        self.minY = minY
    }
}

public struct ActiveLetterPreferenceKey: PreferenceKey {
    public static var defaultValue: [ActiveLetterInfo] = []
    public static func reduce(value: inout [ActiveLetterInfo], nextValue: () -> [ActiveLetterInfo]) {
        value.append(contentsOf: nextValue())
    }
}

public class HomeViewModel: ObservableObject {
    @Published public var selectedHeroIndex: Int = 3
    @Published public var showingFilterSheet: Bool = false
    @Published public var showingProfileSheet: Bool = false
    @Published public var showingWisdomSheet: Bool = false
    @Published public var showingSavedSheet: Bool = false
    @Published public var isScrolled: Bool = false
    @Published public var activeCollectionTitle: String? = nil
    @Published public var activeCollectionSubtitle: String = ""
    @Published public var activeCollectionRecipes: [Recipe] = []
    @Published public var selectedExploreCuisineTab: String = "All"
    @Published public var selectedExploreLetterTab: String = "All"
    @Published public var visibleRecipesCount: Int = 16
    @Published public var activeScrubLetter: String? = nil
    @Published public var currentVisibleLetter: String = "A"
    
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
        ScrollViewReader { scrollProxy in
            ZStack(alignment: .trailing) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // Scroll tracker
                        GeometryReader { proxy in
                            let minY = proxy.frame(in: .named("homeScrollSpace")).minY
                            Color.clear
                                .preference(key: HomeScrollOffsetKey.self, value: minY)
                        }
                        .frame(height: 0)
                        
                        // Hero Headline
                        Text("Cook something unforgettable.")
                            .font(MealioFont.editorialHero(size: 26))
                            .foregroundColor(MealioColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.80)
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                            .padding(.bottom, 8)
                        
                        // Pinned Section: Sticky Search Bar + Save in One Line
                        Section {
                            VStack(alignment: .leading, spacing: 24) {
                                // Live Search Results (if user is searching)
                                if !store.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    searchResultsSection
                                        .padding(.horizontal, 20)
                                } else {
                                    // Category Filter Pills: "For you", "Quick & easy", "Vegetarian", "High protein", "Seasonal"
                                    categoryPills
                                    
                                    // If a specific category or filter is active, show filtered results
                                    if store.selectedCategory != .forYou || store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil || store.dietaryFilter != nil {
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
                                        
                                        // Section 5: "Explore All Recipes" (With Alphabetical Cuisine Filter & Contacts Scroller)
                                        exploreAllRecipesSection
                                    }
                                }
                                
                                // Bottom spacing for tab bar
                                Spacer()
                                    .frame(height: 80)
                            }
                            .padding(.top, 14)
                        } header: {
                            stickySearchAndSaveBar
                        }
                    }
                }
                .coordinateSpace(name: "homeScrollSpace")
                .onPreferenceChange(HomeScrollOffsetKey.self) { minY in
                    let scrolled = minY < -15
                    if vm.isScrolled != scrolled {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            vm.isScrolled = scrolled
                        }
                    }
                }
                .onPreferenceChange(ActiveLetterPreferenceKey.self) { preferences in
                    guard vm.activeScrubLetter == nil else { return }
                    let visible = preferences.filter { $0.minY <= 220 }
                    if let best = visible.max(by: { $0.minY < $1.minY }) {
                        if vm.currentVisibleLetter != best.letter {
                            vm.currentVisibleLetter = best.letter
                        }
                    } else if let first = preferences.min(by: { $0.minY < $1.minY }) {
                        if vm.currentVisibleLetter != first.letter {
                            vm.currentVisibleLetter = first.letter
                        }
                    }
                }
                .background(MealioColors.background.ignoresSafeArea())
                .refreshable {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        store.refreshSessionFeed()
                    }
                }
                
                // Floating Side Alphabet Scroller (pinned to right edge, moves highlight as recipes scroll)
                if shouldShowAlphabetScroller {
                    floatingAlphabetScroller(availableLetters: availableLettersSet, scrollProxy: scrollProxy)
                        .padding(.trailing, 4)
                        .padding(.bottom, 60)
                        .transition(.opacity)
                }
                
                // Floating Alphabet Magnifier HUD during scrubbing
                if let letter = vm.activeScrubLetter {
                    ZStack {
                        Circle()
                            .fill(.thickMaterial)
                        
                        Circle()
                            .strokeBorder(MealioColors.terracotta, lineWidth: 1.5)
                        
                        Text(letter)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(MealioColors.terracotta)
                    }
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                    .padding(.trailing, 75)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                    .allowsHitTesting(false)
                }
            }
        }
        .sheet(isPresented: $vm.showingFilterSheet) {
            FilterSheetView(store: store)
                .presentationDetents([.fraction(0.65), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.65)))
        }
        .sheet(isPresented: $vm.showingWisdomSheet) {
            KitchenWisdomSheet(activeWisdom: store.activeWisdom)
                .presentationDetents([.fraction(0.72), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $vm.showingSavedSheet) {
            SavedRecipesView(store: store, selectedRecipeForNavigation: $selectedRecipeForNavigation)
                .presentationDetents([.fraction(0.88), .large])
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
    
    // MARK: - Sticky Search Bar & Save in One Horizontal Line
    private var stickySearchAndSaveBar: some View {
        HStack(spacing: 10) {
            searchBar
            savedButton
        }
        .padding(.horizontal, 20)
        .padding(.top, vm.isScrolled ? 10 : 4)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background {
            if vm.isScrolled {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(.thickMaterial)
                        .ignoresSafeArea(edges: .top)
                    
                    Rectangle()
                        .fill(MealioColors.divider)
                        .frame(height: 0.5)
                }
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
                text: $store.searchText,
                prompt: Text("Search dishes, cravings...").foregroundColor(.black)
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)
            .tint(MealioColors.terracotta)
            
            if !store.searchText.isEmpty {
                Button(action: {
                    HapticFeedback.light()
                    store.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(MealioColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            
            Button(action: {
                HapticFeedback.light()
                vm.showingFilterSheet = true
            }) {
                let hasActiveFilter = store.selectedCuisineFilter != nil || store.maxTimeFilter != nil || store.effortFilter != nil || store.dietaryFilter != nil
                ZStack {
                    Circle()
                        .fill(hasActiveFilter ? MealioColors.terracotta : Color.white.opacity(0.25))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.40), lineWidth: 0.6)
                        )
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(hasActiveFilter ? .white : MealioColors.textPrimary)
                    
                    if hasActiveFilter {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 5, height: 5)
                            .offset(x: 8, y: -8)
                    }
                }
            }
            .buttonStyle(LiquidGlassPressStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(height: 48)
        .liquidGlass(cornerRadius: 24, isClear: vm.isScrolled)
    }
    
    // MARK: - Saved Button (Liquid Glass)
    private var savedButton: some View {
        Button(action: {
            HapticFeedback.light()
            vm.showingSavedSheet = true
        }) {
            HStack(spacing: 5) {
                Image(systemName: store.savedRecipeIds.isEmpty ? "bookmark" : "bookmark.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(store.savedRecipeIds.isEmpty ? MealioColors.textSecondary : MealioColors.terracotta)
                    .symbolEffect(.bounce, value: store.savedRecipeIds.count)
                
                if !store.savedRecipeIds.isEmpty {
                    Text("\(store.savedRecipeIds.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(MealioColors.terracotta)
                }
            }
            .padding(.horizontal, store.savedRecipeIds.isEmpty ? 14 : 13)
            .frame(height: 48)
            .liquidGlass(
                cornerRadius: 24,
                tint: store.savedRecipeIds.isEmpty ? nil : MealioColors.terracottaLight.opacity(0.4),
                isClear: vm.isScrolled
            )
        }
        .buttonStyle(LiquidGlassPressStyle())
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
            HStack(alignment: .center) {
                Text("The evening edit")
                    .font(MealioFont.editorialTitle(size: 22))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                SectionHeaderArrowButton {
                    vm.activeCollectionTitle = "The Evening Edit"
                    vm.activeCollectionSubtitle = "Curated luxury dinners for tonight's table."
                    vm.activeCollectionRecipes = store.eveningEditRecipes
                }
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
                
                // Bottom content: Recipe metadata + Centered pagination indicators cleanly stacked
                VStack(spacing: 10) {
                    if eveningItems.indices.contains(vm.selectedHeroIndex) {
                        let currentRecipe = eveningItems[vm.selectedHeroIndex]
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentRecipe.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .shadow(color: Color.black.opacity(0.65), radius: 3, x: 0, y: 1)
                                .id("title-\(currentRecipe.id)")
                                .transition(.opacity)
                            
                            HStack(spacing: 6) {
                                Text(currentRecipe.totalTime)
                                Text("·")
                                Text(currentRecipe.effort)
                                Text("·")
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(MealioColors.terracotta)
                                    Text(String(format: "%.1f", currentRecipe.rating))
                                        .font(.system(size: 12, weight: .semibold))
                                }
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.92))
                            .lineLimit(1)
                            .shadow(color: Color.black.opacity(0.55), radius: 2, x: 0, y: 1)
                            .id("meta-\(currentRecipe.id)")
                            .transition(.opacity)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .allowsHitTesting(false)
                    }
                    
                    // Centered, highly visible Liquid Glass Pagination Pill
                    HStack(spacing: 6) {
                        ForEach(0..<min(totalItems, 7), id: \.self) { dotIdx in
                            let isSelected = dotIdx == vm.selectedHeroIndex
                            Capsule()
                                .fill(isSelected ? Color.white : Color.white.opacity(0.45))
                                .frame(width: isSelected ? 18 : 6, height: 6)
                                .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
                                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: vm.selectedHeroIndex)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    HapticFeedback.light()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        vm.selectedHeroIndex = dotIdx
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.35))
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                    )
                    .shadow(color: Color.black.opacity(0.20), radius: 6, x: 0, y: 2)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity)
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
                
                SectionHeaderArrowButton {
                    vm.activeCollectionTitle = "Last visited"
                    vm.activeCollectionSubtitle = "Recipes you recently explored."
                    vm.activeCollectionRecipes = store.lastVisitedRecipes
                }
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
                
                SectionHeaderArrowButton {
                    vm.activeCollectionTitle = "Short on time. Not taste."
                    vm.activeCollectionSubtitle = "Fast weeknight dinners ready in 20 minutes or less."
                    vm.activeCollectionRecipes = store.quickRecipes
                }
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
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cuisines of the world")
                        .font(MealioFont.editorialTitle(size: 22))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("Explore 10 authentic culinary traditions")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
                
                SectionHeaderArrowButton {
                    vm.activeCollectionTitle = "World Cuisines"
                    vm.activeCollectionSubtitle = "Explore recipes across 10 authentic culinary traditions."
                    vm.activeCollectionRecipes = store.allRecipes
                }
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
    
    private var exploreSourceRecipes: [Recipe] {
        let base = (vm.selectedExploreCuisineTab == "All")
            ? store.allRecipes
            : store.recipes(forCuisine: vm.selectedExploreCuisineTab)
        return base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
    
    private var availableLettersSet: Set<String> {
        Set(exploreSourceRecipes.map { String($0.title.prefix(1)).uppercased() })
    }
    
    private var shouldShowAlphabetScroller: Bool {
        store.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        store.selectedCategory == .forYou &&
        store.selectedCuisineFilter == nil &&
        store.maxTimeFilter == nil &&
        store.effortFilter == nil &&
        store.dietaryFilter == nil
    }
    
    // MARK: - Section 5: Explore All Recipes (Alphabetical Cuisine Filters + Contacts Side Scroller)
    private var exploreAllRecipesSection: some View {
        let cuisineTabs = ["All", "American", "French", "Indian", "Italian", "Japanese", "Mediterranean", "Mexican", "Middle Eastern", "Spanish", "Thai"]
        
        let sourceRecipes = exploreSourceRecipes
        
        // Group by first character of recipe title
        var dict = [String: [Recipe]]()
        for recipe in sourceRecipes {
            let letter = String(recipe.title.prefix(1)).uppercased()
            dict[letter, default: []].append(recipe)
        }
        let groupedByLetter: [(letter: String, recipes: [Recipe])] = dict.keys.sorted().map { letter in
            (letter: letter, recipes: dict[letter]!)
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Explore all recipes")
                        .font(MealioFont.editorialTitle(size: 22))
                        .foregroundColor(MealioColors.textPrimary)
                    Text("\(sourceRecipes.count) recipes organized alphabetically")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Alphabetical Cuisine Sub-Tabs (Liquid Glass)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(cuisineTabs, id: \.self) { cuisine in
                        let isSelected = vm.selectedExploreCuisineTab == cuisine
                        Button(action: {
                            HapticFeedback.light()
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                                vm.selectedExploreCuisineTab = cuisine
                            }
                        }) {
                            Text(cuisine)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
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
            
            // Grouped 2-Column Grid (Standard VStack guarantees all letter anchors exist in view tree)
            VStack(alignment: .leading, spacing: 22) {
                ForEach(groupedByLetter, id: \.letter) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        // Alphabet Section Header with scroll anchor and position tracker
                        HStack(spacing: 8) {
                            Text(group.letter)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(MealioColors.terracotta)
                            
                            Rectangle()
                                .fill(MealioColors.divider)
                                .frame(height: 1)
                        }
                        .background(
                            GeometryReader { geo in
                                let frame = geo.frame(in: .named("homeScrollSpace"))
                                Color.clear.preference(
                                    key: ActiveLetterPreferenceKey.self,
                                    value: [ActiveLetterInfo(letter: group.letter, minY: frame.minY)]
                                )
                            }
                        )
                        .id("explore-letter-\(group.letter)")
                        .padding(.top, 4)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
                            ForEach(group.recipes) { recipe in
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
            .padding(.leading, 20)
            .padding(.trailing, 28)
        }
    }
    
    // MARK: - Side Alphabet Index Scroller (Native iOS Contacts Style)
    private func floatingAlphabetScroller(availableLetters: Set<String>, scrollProxy: ScrollViewProxy) -> some View {
        let allLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let itemHeight: CGFloat = 11.5
        let activeLetter = vm.activeScrubLetter ?? vm.currentVisibleLetter
        
        return VStack(spacing: 1.0) {
            ForEach(allLetters, id: \.self) { letter in
                let hasRecipes = availableLetters.contains(letter)
                let isSelected = (activeLetter == letter)
                
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(MealioColors.terracotta)
                            .frame(width: 14, height: 14)
                            .transition(.scale)
                    }
                    
                    Text(letter)
                        .font(.system(size: isSelected ? 9.5 : 8.5, weight: isSelected ? .heavy : (hasRecipes ? .bold : .regular)))
                        .foregroundColor(
                            isSelected
                                ? .white
                                : (hasRecipes ? MealioColors.terracotta : MealioColors.textTertiary.opacity(0.35))
                        )
                }
                .frame(width: 16, height: itemHeight)
                .contentShape(Rectangle())
                .onTapGesture {
                    HapticFeedback.selection()
                    vm.activeScrubLetter = letter
                    jumpToLetter(letter, available: availableLetters, scrollProxy: scrollProxy, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        if vm.activeScrubLetter == letter {
                            withAnimation { vm.activeScrubLetter = nil }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 3)
        .background(
            Capsule(style: .continuous)
                .fill(.thickMaterial)
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let step = itemHeight + 1.0
                    let totalHeight = CGFloat(allLetters.count) * step
                    let clampedY = min(max(0, value.location.y), totalHeight - 1)
                    let index = min(max(0, Int(clampedY / step)), allLetters.count - 1)
                    let letter = allLetters[index]
                    if vm.activeScrubLetter != letter {
                        vm.activeScrubLetter = letter
                        HapticFeedback.selection()
                        jumpToLetter(letter, available: availableLetters, scrollProxy: scrollProxy, animated: false)
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        vm.activeScrubLetter = nil
                    }
                }
        )
    }
    
    private func jumpToLetter(_ target: String, available: Set<String>, scrollProxy: ScrollViewProxy, animated: Bool) {
        let destinationId: String? = {
            if available.contains(target) {
                return "explore-letter-\(target)"
            } else if let next = available.sorted().first(where: { $0 > target }) {
                return "explore-letter-\(next)"
            } else if let last = available.sorted().last {
                return "explore-letter-\(last)"
            }
            return nil
        }()
        
        guard let id = destinationId else { return }
        
        if animated {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                scrollProxy.scrollTo(id, anchor: .top)
            }
        } else {
            scrollProxy.scrollTo(id, anchor: .top)
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
