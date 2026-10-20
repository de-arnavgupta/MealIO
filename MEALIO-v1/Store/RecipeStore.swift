import SwiftUI
import Combine

public struct CuisineOverview: Identifiable {
    public var id: String { name }
    public let name: String
    public let emoji: String
    public let count: Int
    public let sampleImage: String
    public let tagline: String
}

public class RecipeStore: ObservableObject {
    @Published public var allRecipes: [Recipe] = []
    @Published public var featuredRecipe: Recipe
    @Published public var savedRecipeIds: Set<UUID>
    @Published public var groceryItems: [Ingredient]
    @Published public var checkedGroceryItemIds: Set<UUID> = []
    
    // Dynamic Rotating Feed States
    @Published public var eveningEditRecipes: [Recipe] = []
    @Published public var lastVisitedRecipes: [Recipe] = []
    @Published public var moodComfortRecipe: Recipe
    @Published public var moodBakeRecipe: Recipe
    @Published public var moodRecipes: [Recipe] = []
    @Published public var quickRecipes: [Recipe] = []
    @Published public var activeWisdom: KitchenWisdom = KitchenWisdom.library[0]
    
    // Search & Filter
    @Published public var selectedCategory: RecipeCategory = .forYou
    @Published public var searchText: String = ""
    @Published public var selectedCuisineFilter: String? = nil
    @Published public var maxTimeFilter: Int? = nil
    @Published public var effortFilter: String? = nil
    @Published public var dietaryFilter: String? = nil
    @Published public var currentServings: Int = 2
    @Published public var groceryDestination: String = "This week's table"
    
    // Active Cooking Session (Live Activity & Dynamic Island)
    @Published public var activeCookingSession: CookingSession? = nil
    
    public init() {
        let initialFeatured = MockData.scallopsRecipe
        self.featuredRecipe = initialFeatured
        self.moodComfortRecipe = MockData.pastaRecipe
        self.moodBakeRecipe = MockData.pearTartRecipe
        self.savedRecipeIds = [initialFeatured.id]
        self.groceryItems = initialFeatured.ingredients.filter { !$0.isInPantry }
        
        loadAllRecipes()
        buildDailyEveningCarousel()
        refreshSessionFeed()
    }
    
    private func loadAllRecipes() {
        if let url = Bundle.main.url(forResource: "recipes", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Recipe].self, from: data), !decoded.isEmpty {
                self.allRecipes = decoded
                return
            }
        }
        
        self.allRecipes = [
            MockData.scallopsRecipe,
            MockData.pastaRecipe,
            MockData.pearTartRecipe,
            MockData.salmonRecipe
        ]
    }
    
    // MARK: - Daily Seeded Evening Edit Carousel (Consistent for the day, changes daily, scallops not locked)
    public func buildDailyEveningCarousel() {
        guard !allRecipes.isEmpty else { return }
        
        // Luxury dinner pool across all cuisines
        let luxuryPool = allRecipes.filter {
            $0.effort == "A little finesse" || $0.effort == "Worth the wait" || $0.rating >= 4.8
        }
        let pool = luxuryPool.isEmpty ? allRecipes : luxuryPool
        
        // Calculate deterministic seed based on day of year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        // Rotate pool deterministically by day
        var items: [Recipe] = []
        let poolCount = pool.count
        for i in 0..<min(8, poolCount) {
            let index = (dayOfYear * 7 + i * 3) % poolCount
            let recipe = pool[index]
            if !items.contains(where: { $0.id == recipe.id }) {
                items.append(recipe)
            }
        }
        
        // If not enough items, fill with others
        for r in pool where items.count < 7 && !items.contains(where: { $0.id == r.id }) {
            items.append(r)
        }
        
        // Place Golden hour scallops at index 3 (middle of 7 items) for reference consistency
        if let scallops = allRecipes.first(where: { $0.title.lowercased().contains("scallop") }) {
            items.removeAll(where: { $0.id == scallops.id })
            if items.count >= 3 {
                items.insert(scallops, at: 3)
            } else {
                items.append(scallops)
            }
        }
        if items.count > 7 {
            items = Array(items.prefix(7))
        }
        
        self.eveningEditRecipes = items
        if let first = items.first {
            self.featuredRecipe = first
        }
    }
    
    // MARK: - Session-Dynamic Feed Refresh
    public func refreshSessionFeed() {
        guard !allRecipes.isEmpty else { return }
        
        // 1. Randomly pick comfort dish for left bento card
        let comfortCandidates = allRecipes.filter {
            $0.cuisine == "Italian" || $0.cuisine == "Indian" || $0.cuisine == "Mexican" ||
            $0.title.lowercased().contains("pasta") || $0.title.lowercased().contains("curry") ||
            $0.title.lowercased().contains("tacos") || $0.title.lowercased().contains("risotto")
        }
        if let comfort = comfortCandidates.randomElement() {
            self.moodComfortRecipe = comfort
        }
        
        // 2. Randomly pick baking / sweet / rustic dish for bottom right bento card
        let bakeCandidates = allRecipes.filter {
            $0.cuisine == "French" || $0.cuisine == "American" ||
            $0.title.lowercased().contains("tart") || $0.title.lowercased().contains("pie") ||
            $0.title.lowercased().contains("cake") || $0.title.lowercased().contains("pastry") ||
            $0.title.lowercased().contains("bread") || $0.title.lowercased().contains("cornbread")
        }
        if let bake = bakeCandidates.randomElement() {
            self.moodBakeRecipe = bake
        }
        
        // Mood collection for "View all"
        var moodList: [Recipe] = [moodComfortRecipe, moodBakeRecipe]
        for r in (comfortCandidates + bakeCandidates).shuffled() where !moodList.contains(where: { $0.id == r.id }) {
            moodList.append(r)
            if moodList.count >= 8 { break }
        }
        self.moodRecipes = moodList
        
        // 3. Randomly pick Kitchen Wisdom for quote card
        if let randomWisdom = KitchenWisdom.library.randomElement() {
            self.activeWisdom = randomWisdom
        }
        
        // 4. Randomly pick 8 quick weeknight recipes under 20 minutes
        let quickCandidates = allRecipes.filter { $0.totalTimeMinutes <= 20 }.shuffled()
        if !quickCandidates.isEmpty {
            self.quickRecipes = Array(quickCandidates.prefix(8))
        }
        
        // 5. Seed Last Visited recipes if empty (prioritizing Churros con Chocolate matching user preference)
        if lastVisitedRecipes.isEmpty {
            let churros = allRecipes.first { $0.title.lowercased().contains("churros") }
            let initialRecent: [Recipe] = [
                churros ?? allRecipes[0],
                moodComfortRecipe,
                moodBakeRecipe,
                allRecipes.first(where: { $0.title.lowercased().contains("salmon") }) ?? allRecipes[1],
                allRecipes.first(where: { $0.title.lowercased().contains("scallop") }) ?? allRecipes[2],
                allRecipes.first(where: { $0.title.lowercased().contains("cacio") }) ?? allRecipes[3]
            ]
            var unique: [Recipe] = []
            for r in initialRecent where !unique.contains(where: { $0.id == r.id }) {
                unique.append(r)
            }
            self.lastVisitedRecipes = unique
        }
    }
    
    public func recordVisitedRecipe(_ recipe: Recipe) {
        var list = lastVisitedRecipes.filter { $0.id != recipe.id }
        list.insert(recipe, at: 0)
        if list.count > 12 {
            list = Array(list.prefix(12))
        }
        self.lastVisitedRecipes = list
    }
    
    // MARK: - Cuisines Overview (10 World Cuisines)
    public var worldCuisines: [CuisineOverview] {
        [
            CuisineOverview(name: "Italian", emoji: "🇮🇹", count: recipesCount(for: "Italian"), sampleImage: sampleImage(for: "Italian"), tagline: "Handmade pasta, simmered sugo & silky risotto"),
            CuisineOverview(name: "French", emoji: "🇫🇷", count: recipesCount(for: "French"), sampleImage: sampleImage(for: "French"), tagline: "Butter-basted poultry, flaky pastries & rich reductions"),
            CuisineOverview(name: "Japanese", emoji: "🇯🇵", count: recipesCount(for: "Japanese"), sampleImage: sampleImage(for: "Japanese"), tagline: "Umami dashi, crisp katsu & delicate tare glazes"),
            CuisineOverview(name: "Mexican", emoji: "🇲🇽", count: recipesCount(for: "Mexican"), sampleImage: sampleImage(for: "Mexican"), tagline: "Fire-roasted chiles, slow carnitas & handmade masa"),
            CuisineOverview(name: "Indian", emoji: "🇮🇳", count: recipesCount(for: "Indian"), sampleImage: sampleImage(for: "Indian"), tagline: "Slow-tempered aromatics, fragrant biryani & rich gravies"),
            CuisineOverview(name: "Mediterranean", emoji: "🇬🇷", count: recipesCount(for: "Mediterranean"), sampleImage: sampleImage(for: "Mediterranean"), tagline: "Sun-drenched olive oil, wild herbs & seaside grills"),
            CuisineOverview(name: "Thai", emoji: "🇹🇭", count: recipesCount(for: "Thai"), sampleImage: sampleImage(for: "Thai"), tagline: "Lemongrass perfumes, creamy coconut & wok fire"),
            CuisineOverview(name: "Spanish", emoji: "🇪🇸", count: recipesCount(for: "Spanish"), sampleImage: sampleImage(for: "Spanish"), tagline: "Saffron paella, crispy tapas & Basque bakes"),
            CuisineOverview(name: "American", emoji: "🇺🇸", count: recipesCount(for: "American"), sampleImage: sampleImage(for: "American"), tagline: "Cast iron cornbread, coastal seafood & hickory smoke"),
            CuisineOverview(name: "Middle Eastern", emoji: "🇱🇧", count: recipesCount(for: "Middle Eastern"), sampleImage: sampleImage(for: "Middle Eastern"), tagline: "Silky labneh, sumac grills & fragrant saffron jewels")
        ]
    }
    
    public func recipes(forCuisine cuisine: String) -> [Recipe] {
        allRecipes.filter { $0.cuisine.lowercased() == cuisine.lowercased() }
    }
    
    private func recipesCount(for cuisine: String) -> Int {
        allRecipes.filter { $0.cuisine.lowercased() == cuisine.lowercased() }.count
    }
    
    private func sampleImage(for cuisine: String) -> String {
        recipes(forCuisine: cuisine).first?.cardImageName ?? "PastaCard"
    }
    
    // MARK: - Search & Filters
    public var searchResults: [Recipe] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        let query = searchText.lowercased()
        return allRecipes.filter {
            $0.title.lowercased().contains(query) ||
            $0.subtitle.lowercased().contains(query) ||
            $0.cuisine.lowercased().contains(query) ||
            $0.description.lowercased().contains(query) ||
            $0.ingredients.contains { $0.name.lowercased().contains(query) }
        }
    }
    
    public var filteredRecipes: [Recipe] {
        var list = allRecipes
        
        switch selectedCategory {
        case .forYou:
            break
        case .quickAndLovely:
            list = list.filter { $0.totalTimeMinutes <= 25 }
        case .vegetarian:
            list = list.filter { $0.dietaryType == "Vegetarian" || $0.dietaryType == "Vegan" }
        case .highProtein:
            list = list.filter {
                $0.dietaryType == "Non-Veg" ||
                $0.ingredients.contains { ing in
                    let lower = ing.name.lowercased()
                    return lower.contains("egg") || lower.contains("salmon") || lower.contains("chicken") ||
                           lower.contains("lentil") || lower.contains("scallop") || lower.contains("beef") ||
                           lower.contains("tofu") || lower.contains("beans")
                }
            }
        case .seasonal:
            list = list.filter { $0.categoryBadge.contains("SEASONAL") || $0.categoryBadge.contains("HARVEST") || $0.cuisine == "Mediterranean" }
        }
        
        if let cuisine = selectedCuisineFilter, !cuisine.isEmpty {
            list = list.filter { $0.cuisine.lowercased() == cuisine.lowercased() }
        }
        
        if let maxTime = maxTimeFilter {
            list = list.filter { $0.totalTimeMinutes <= maxTime }
        }
        
        if let effort = effortFilter, !effort.isEmpty {
            list = list.filter { $0.effort.lowercased() == effort.lowercased() }
        }
        
        if let dietary = dietaryFilter, !dietary.isEmpty {
            switch dietary {
            case "Vegetarian":
                list = list.filter { $0.dietaryType == "Vegetarian" || $0.dietaryType == "Vegan" }
            case "Vegan":
                list = list.filter { $0.dietaryType == "Vegan" }
            case "Non-Veg":
                list = list.filter { $0.dietaryType == "Non-Veg" }
            case "Halal":
                list = list.filter { $0.isHalal }
            default:
                break
            }
        }
        
        return list
    }
    
    public func isRecipeSaved(_ id: UUID) -> Bool {
        savedRecipeIds.contains(id)
    }
    
    public func toggleSave(_ id: UUID) {
        if savedRecipeIds.contains(id) {
            savedRecipeIds.remove(id)
        } else {
            savedRecipeIds.insert(id)
        }
    }
    
    public func addIngredientsToGroceryList(_ items: [Ingredient]) {
        for item in items {
            if !groceryItems.contains(where: { $0.name == item.name }) {
                groceryItems.append(item)
            }
        }
    }
    
    public func removeGroceryItem(id: UUID) {
        groceryItems.removeAll(where: { $0.id == id })
        checkedGroceryItemIds.remove(id)
    }
    
    public func toggleGroceryItemChecked(id: UUID) {
        if checkedGroceryItemIds.contains(id) {
            checkedGroceryItemIds.remove(id)
        } else {
            checkedGroceryItemIds.insert(id)
        }
    }
    
    public func clearCheckedGroceryItems() {
        groceryItems.removeAll(where: { checkedGroceryItemIds.contains($0.id) })
        checkedGroceryItemIds.removeAll()
    }
    
    public func resetFilters() {
        selectedCuisineFilter = nil
        maxTimeFilter = nil
        effortFilter = nil
        dietaryFilter = nil
    }
    
    public func addCustomRecipe(_ recipe: Recipe) {
        allRecipes.insert(recipe, at: 0)
        savedRecipeIds.insert(recipe.id)
    }
    
    // MARK: - Live Activity Cooking Session
    public func startCookingSession(recipe: Recipe, initialStepIndex: Int? = nil) -> CookingSession {
        if let existing = activeCookingSession, existing.recipe.id == recipe.id {
            if let idx = initialStepIndex {
                existing.currentStepIndex = idx
            }
            return existing
        }
        let session = CookingSession(recipe: recipe, initialStepIndex: initialStepIndex)
        self.activeCookingSession = session
        return session
    }
    
    public func endCookingSession() {
        activeCookingSession?.pauseTimer()
        activeCookingSession = nil
    }
}
