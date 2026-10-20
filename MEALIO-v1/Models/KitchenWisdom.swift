import Foundation

public struct KitchenWisdom: Identifiable, Hashable {
    public var id: String { quote }
    public let tag: String
    public let quote: String
    public let principle: String
    public let description: String
    public let iconName: String
    
    public init(tag: String = "A LITTLE KITCHEN WISDOM", quote: String, principle: String, description: String, iconName: String = "sparkles") {
        self.tag = tag
        self.quote = quote
        self.principle = principle
        self.description = description
        self.iconName = iconName
    }
    
    public static let library: [KitchenWisdom] = [
        KitchenWisdom(
            quote: "Good things take butter.",
            principle: "The Power of Emulsion",
            description: "Butter isn't just cooking fat—it's an emulsion of water and milk solids. As butter browns into beurre noisette, it releases hazelnut and toasted brioche aromas that transform simple pan sauces into pure velvet.",
            iconName: "sparkles"
        ),
        KitchenWisdom(
            quote: "Dry scallops, hot pan.",
            principle: "High Heat & Contact",
            description: "Moisture is the enemy of a golden crust. Pat proteins bone-dry with paper towels, let the pan reach shimmering heat, give them space, and resist the urge to move them before they naturally release.",
            iconName: "flame.fill"
        ),
        KitchenWisdom(
            quote: "Pasta water is liquid gold.",
            principle: "Starch Emulsification",
            description: "Never pour cloudy pasta water down the sink. Half a ladle of that salty, starchy water vigorously swirled with fat and grated pecorino creates an instantaneous, restaurant-glossy silk sauce.",
            iconName: "drop.fill"
        ),
        KitchenWisdom(
            quote: "Acid wakes up heavy flavors.",
            principle: "Balancing Richness",
            description: "When a stew, sauce, or braise feels flat or overly rich, it rarely needs more salt. A bright splash of fresh lemon juice, sherry vinegar, or verjus instantly cuts through fat and awakens every note.",
            iconName: "leaf.fill"
        ),
        KitchenWisdom(
            quote: "Toast whole spices first.",
            principle: "Blooming Aromatics",
            description: "Cold ground spices taste chalky. Waking whole cumin, coriander, and mustard seeds in dry cast iron for 60 seconds unlocks volatile essential oils before they ever meet the onions.",
            iconName: "sun.max.fill"
        ),
        KitchenWisdom(
            quote: "Rest meat like it worked a shift.",
            principle: "Juice Redistribution",
            description: "Cutting a steak straight off the skillet dumps all its moisture onto the cutting board. Give meat 5 to 10 minutes resting under loose foil so muscle fibers relax and reabsorb every drop.",
            iconName: "timer"
        )
    ]
}
