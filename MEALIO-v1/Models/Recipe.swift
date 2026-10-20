import Foundation

public enum RecipeCategory: String, CaseIterable, Identifiable, Codable {
    case forYou = "For you"
    case quickAndLovely = "Quick & easy"
    case vegetarian = "Vegetarian"
    case highProtein = "High protein"
    case seasonal = "Seasonal"
    
    public var id: String { rawValue }
}

public struct Recipe: Identifiable, Hashable, Codable {
    public var id: UUID
    public var title: String
    public var subtitle: String
    public var cuisine: String
    public var categoryBadge: String
    public var collectionTag: String
    public var totalTime: String
    public var totalTimeMinutes: Int
    public var effort: String
    public var rating: Double
    public var homeCooksCount: Int
    public var description: String
    
    // Author
    public var authorName: String
    public var authorSubtitle: String
    public var authorInitials: String
    
    // Images (asset catalog name or https:// unsplash URL)
    public var heroImageName: String
    public var cardImageName: String
    public var platedImageName: String
    
    // Kitchen secret
    public var chefSecretTitle: String
    public var chefSecretBody: String
    
    // Recipe Data
    public var baseServings: Int
    public var ingredients: [Ingredient]
    public var steps: [CookingStep]
    
    // Collaborative indicator
    public var activeSocialUser: String?
    
    // Dynamic Dietary Classification
    public var dietaryType: String {
        let meatWords = ["beef", "pork", "prosciutto", "pancetta", "bacon", "chicken", "scallop", "salmon", "shrimp", "duck", "lamb", "veal", "anchov", "chorizo", "steak", "tuna", "crab", "lobster", "meat", "fish", "clam"]
        let dairyWords = ["butter", "cream", "cheese", "parmesan", "pecorino", "ricotta", "milk", "egg", "yogurt", "mascarpone", "ghee", "honey", "mozzarella"]
        
        let ingredientNames = ingredients.map { $0.name.lowercased() }
        let titleLower = title.lowercased()
        let descLower = description.lowercased()
        
        let containsMeat = ingredientNames.contains { name in meatWords.contains { name.contains($0) } } ||
                           meatWords.contains { titleLower.contains($0) || descLower.contains($0) }
        
        if containsMeat {
            return "Non-Veg"
        }
        
        let containsDairy = ingredientNames.contains { name in dairyWords.contains { name.contains($0) } }
        if containsDairy {
            return "Vegetarian"
        }
        
        return "Vegan"
    }
    
    public var isHalal: Bool {
        let nonHalal = ["pork", "prosciutto", "pancetta", "bacon", "wine", "alcohol", "beer", "rum", "chorizo"]
        let ingredientNames = ingredients.map { $0.name.lowercased() }
        let titleLower = title.lowercased()
        return !ingredientNames.contains { name in nonHalal.contains { name.contains($0) } } &&
               !nonHalal.contains { titleLower.contains($0) }
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        cuisine: String = "Italian",
        categoryBadge: String,
        collectionTag: String,
        totalTime: String,
        totalTimeMinutes: Int = 30,
        effort: String,
        rating: Double,
        homeCooksCount: Int,
        description: String,
        authorName: String,
        authorSubtitle: String,
        authorInitials: String,
        heroImageName: String,
        cardImageName: String,
        platedImageName: String,
        chefSecretTitle: String,
        chefSecretBody: String,
        baseServings: Int = 2,
        ingredients: [Ingredient],
        steps: [CookingStep],
        activeSocialUser: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.cuisine = cuisine
        self.categoryBadge = categoryBadge
        self.collectionTag = collectionTag
        self.totalTime = totalTime
        self.totalTimeMinutes = totalTimeMinutes
        self.effort = effort
        self.rating = rating
        self.homeCooksCount = homeCooksCount
        self.description = description
        self.authorName = authorName
        self.authorSubtitle = authorSubtitle
        self.authorInitials = authorInitials
        self.heroImageName = heroImageName
        self.cardImageName = cardImageName
        self.platedImageName = platedImageName
        self.chefSecretTitle = chefSecretTitle
        self.chefSecretBody = chefSecretBody
        self.baseServings = baseServings
        self.ingredients = ingredients
        self.steps = steps
        self.activeSocialUser = activeSocialUser
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, cuisine, categoryBadge, collectionTag, totalTime, totalTimeMinutes
        case effort, rating, homeCooksCount, description, authorName, authorSubtitle, authorInitials
        case heroImageName, cardImageName, platedImageName, chefSecretTitle, chefSecretBody
        case baseServings, activeSocialUser, ingredients, steps
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let uuidStr = try? c.decode(String.self, forKey: .id), let u = UUID(uuidString: uuidStr) {
            self.id = u
        } else {
            self.id = UUID()
        }
        self.title = try c.decode(String.self, forKey: .title)
        self.subtitle = (try? c.decodeIfPresent(String.self, forKey: .subtitle)) ?? ""
        self.cuisine = (try? c.decodeIfPresent(String.self, forKey: .cuisine)) ?? "Italian"
        self.categoryBadge = (try? c.decodeIfPresent(String.self, forKey: .categoryBadge)) ?? "FEATURED"
        self.collectionTag = (try? c.decodeIfPresent(String.self, forKey: .collectionTag)) ?? "THE EVENING EDIT"
        self.totalTime = (try? c.decodeIfPresent(String.self, forKey: .totalTime)) ?? "30 min"
        self.totalTimeMinutes = (try? c.decodeIfPresent(Int.self, forKey: .totalTimeMinutes)) ?? 30
        let decodedEffort = (try? c.decodeIfPresent(String.self, forKey: .effort)) ?? "Easy"
        if decodedEffort.lowercased().contains("finesse") || decodedEffort.lowercased() == "medium" {
            self.effort = "Medium"
        } else if decodedEffort.lowercased().contains("wait") || decodedEffort.lowercased() == "hard" {
            self.effort = "Hard"
        } else {
            self.effort = "Easy"
        }
        self.rating = (try? c.decodeIfPresent(Double.self, forKey: .rating)) ?? 4.8
        self.homeCooksCount = (try? c.decodeIfPresent(Int.self, forKey: .homeCooksCount)) ?? 100
        self.description = (try? c.decodeIfPresent(String.self, forKey: .description)) ?? ""
        self.authorName = (try? c.decodeIfPresent(String.self, forKey: .authorName)) ?? "Chef"
        self.authorSubtitle = (try? c.decodeIfPresent(String.self, forKey: .authorSubtitle)) ?? "Home Kitchen"
        self.authorInitials = (try? c.decodeIfPresent(String.self, forKey: .authorInitials)) ?? "CH"
        self.heroImageName = (try? c.decodeIfPresent(String.self, forKey: .heroImageName)) ?? "ScallopsHero"
        self.cardImageName = (try? c.decodeIfPresent(String.self, forKey: .cardImageName)) ?? "ScallopsCard"
        self.platedImageName = (try? c.decodeIfPresent(String.self, forKey: .platedImageName)) ?? "ScallopsPlated"
        self.chefSecretTitle = (try? c.decodeIfPresent(String.self, forKey: .chefSecretTitle)) ?? "CHEF SECRET"
        self.chefSecretBody = (try? c.decodeIfPresent(String.self, forKey: .chefSecretBody)) ?? ""
        self.baseServings = (try? c.decodeIfPresent(Int.self, forKey: .baseServings)) ?? 2
        self.activeSocialUser = try? c.decodeIfPresent(String.self, forKey: .activeSocialUser)
        self.ingredients = (try? c.decodeIfPresent([Ingredient].self, forKey: .ingredients)) ?? []
        self.steps = (try? c.decodeIfPresent([CookingStep].self, forKey: .steps)) ?? []
    }
}
