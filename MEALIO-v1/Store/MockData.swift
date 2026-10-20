import Foundation

public struct MockData {
    public static let scallopsRecipe: Recipe = {
        let ingredients: [Ingredient] = [
            Ingredient(name: "Large sea scallops", note: "patted very dry", baseQuantity: 6, unit: "", aisleCategory: "Seafood"),
            Ingredient(name: "Orzo", baseQuantity: 160, unit: "g", aisleCategory: "Grains & Pasta"),
            Ingredient(name: "Vegetable stock", note: "kept warm", baseQuantity: 500, unit: "ml", aisleCategory: "Broths & Sauces"),
            Ingredient(name: "Saffron threads", displayOverride: "1 pinch", aisleCategory: "Spices"),
            Ingredient(name: "Unsalted butter", baseQuantity: 50, unit: "g", aisleCategory: "Dairy"),
            Ingredient(name: "Fresh sage", baseQuantity: 8, unit: "leaves", aisleCategory: "Produce"),
            Ingredient(name: "Lemon", note: "zest & juice", baseQuantity: 1, unit: "", aisleCategory: "Produce"),
            Ingredient(name: "Shallot", note: "finely diced", baseQuantity: 1, unit: "", aisleCategory: "Produce"),
            Ingredient(name: "Olive oil", baseQuantity: 1, unit: "tbsp", isInPantry: true, aisleCategory: "Pantry"),
            Ingredient(name: "Sea salt & black pepper", note: "to taste", displayOverride: "to taste", isInPantry: true, aisleCategory: "Pantry")
        ]
        
        let steps: [CookingStep] = [
            CookingStep(
                stepIndex: 1,
                title: "Set the scene",
                durationMinutes: 5,
                instruction: "Pat the scallops dry and remove the side muscles. Dice the shallot. Steep the saffron in the warm stock; zest the lemon.",
                hasTimer: false,
                petitChefTip: "Scallops must be thoroughly dried on paper towels for that restaurant-grade golden crust!"
            ),
            CookingStep(
                stepIndex: 2,
                title: "Toast the orzo",
                durationMinutes: 3,
                instruction: "Soften the shallot in 10 g butter over medium heat for 2 minutes. Stir in the orzo and toast for 1 minute.",
                hasTimer: true,
                timerDurationSeconds: 120,
                timerSideLabel: "SWEATING SHALLOTS",
                petitChefTip: "Toasting the pasta brings out an incredible nutty fragrance before the stock hits."
            ),
            CookingStep(
                stepIndex: 3,
                title: "Let it turn golden",
                durationMinutes: 12,
                instruction: "Add the saffron stock a ladle at a time, stirring often, until the orzo is tender and silky. Add a splash of water if needed; keep warm.",
                hasTimer: true,
                timerDurationSeconds: 720,
                timerSideLabel: "SIMMERING ORZO",
                petitChefTip: "Take your time with the stock. The starch needs gentle stirring to release its creaminess."
            ),
            CookingStep(
                stepIndex: 4,
                title: "Sear the scallops",
                durationMinutes: 4,
                instruction: "Lay them in the hot, oiled pan. Leave for 90 seconds, then turn.",
                hasTimer: true,
                timerDurationSeconds: 90,
                timerSideLabel: "FIRST SIDE",
                petitChefTip: "Hear that gentle sizzle? Lovely. A golden crust needs a little patience."
            ),
            CookingStep(
                stepIndex: 5,
                title: "The brown butter moment",
                durationMinutes: 2,
                instruction: "Transfer scallops to a warm plate. Lower the heat; add the remaining 40 g butter and sage. Swirl until nutty and amber, then take off the heat.",
                hasTimer: true,
                timerDurationSeconds: 120,
                timerSideLabel: "BROWNING BUTTER",
                petitChefTip: "Watch the butter foam subside into hazelnut brown speckles. Smells heavenly!"
            ),
            CookingStep(
                stepIndex: 6,
                title: "Plate with a little love",
                durationMinutes: 4,
                instruction: "Fold lemon zest and a squeeze of juice into the orzo; season to taste. Divide between warm bowls, add the scallops and spoon over the sage butter.",
                hasTimer: false,
                petitChefTip: "Drizzle that amber sage butter generously over each scallop crown right at the table."
            )
        ]
        
        return Recipe(
            title: "Golden hour scallops",
            subtitle: "Saffron orzo, brown butter & crisp sage.",
            categoryBadge: "TONIGHT'S LITTLE LUXURY",
            collectionTag: "THE EVENING EDIT",
            totalTime: "30 min",
            effort: "A little finesse",
            rating: 4.9,
            homeCooksCount: 128,
            description: "Restaurant magic. Your favorite pan. Sweet scallops meet silky saffron orzo, finished with nutty brown butter and a bright lift of lemon.",
            authorName: "Élise Martin",
            authorSubtitle: "Made to savor, not to rush.",
            authorInitials: "ÉM",
            heroImageName: "ScallopsHero",
            cardImageName: "ScallopsCard",
            platedImageName: "ScallopsPlated",
            chefSecretTitle: "THE SECRET TO A GOOD SEAR",
            chefSecretBody: "Dry scallops, hot pan. Give them space and resist the urge to peek.",
            baseServings: 2,
            ingredients: ingredients,
            steps: steps,
            activeSocialUser: "Eliana Esposito"
        )
    }()
    
    public static let pastaRecipe = Recipe(
        title: "Sunday kind of pasta",
        subtitle: "Slow braised tomato sugo with hand-torn basil and whipped ricotta.",
        categoryBadge: "COMFORT, ELEVATED",
        collectionTag: "MADE FOR YOUR MOOD",
        totalTime: "25 min",
        effort: "Easy",
        rating: 4.8,
        homeCooksCount: 240,
        description: "A comforting ribbon pasta tossed with rich slow-cooked tomatoes, finished with freshly grated parmesan and basil.",
        authorName: "Marco Bellini",
        authorSubtitle: "Generational Italian comfort.",
        authorInitials: "MB",
        heroImageName: "PastaCard",
        cardImageName: "PastaCard",
        platedImageName: "PastaCard",
        chefSecretTitle: "PASTA WATER IS LIQUID GOLD",
        chefSecretBody: "Always save half a cup of salty starchy water to gloss the sauce onto every single noodle.",
        baseServings: 2,
        ingredients: [
            Ingredient(name: "Campanelle pasta", baseQuantity: 200, unit: "g", aisleCategory: "Grains & Pasta"),
            Ingredient(name: "San Marzano tomatoes", baseQuantity: 400, unit: "g", aisleCategory: "Canned Goods"),
            Ingredient(name: "Fresh basil", displayOverride: "A handful", aisleCategory: "Produce"),
            Ingredient(name: "Parmigiano-Reggiano", baseQuantity: 30, unit: "g", aisleCategory: "Dairy")
        ],
        steps: [
            CookingStep(stepIndex: 1, title: "Boil the water", durationMinutes: 5, instruction: "Bring a large pot of salted water to a rolling boil."),
            CookingStep(stepIndex: 2, title: "Simmer the sauce", durationMinutes: 15, instruction: "Cook down the tomatoes with crushed garlic and olive oil until rich and reduced."),
            CookingStep(stepIndex: 3, title: "Toss and finish", durationMinutes: 5, instruction: "Fold pasta into sauce with reserved starchy cooking water and fresh basil leaves.")
        ]
    )
    
    public static let pearTartRecipe = Recipe(
        title: "Pear & almond tart",
        subtitle: "Crisp flaky butter pastry filled with almond frangipane and poached winter pears.",
        categoryBadge: "SWEET HARVEST",
        collectionTag: "MADE FOR YOUR MOOD",
        totalTime: "50 min",
        effort: "Worth the wait",
        rating: 4.9,
        homeCooksCount: 94,
        description: "Golden brown frangipane baked inside tender crust, crowned with glazed sliced conference pears.",
        authorName: "Claire Dupont",
        authorSubtitle: "Pastry chef at Atelier Rose.",
        authorInitials: "CD",
        heroImageName: "PearTartCard",
        cardImageName: "PearTartCard",
        platedImageName: "PearTartCard",
        chefSecretTitle: "COLD BUTTER, HOT OVEN",
        chefSecretBody: "Keep the pastry chilled right up until it meets the scorching oven rack.",
        baseServings: 4,
        ingredients: [
            Ingredient(name: "Ripe pears", baseQuantity: 2, unit: "", aisleCategory: "Produce"),
            Ingredient(name: "Almond flour", baseQuantity: 100, unit: "g", aisleCategory: "Baking"),
            Ingredient(name: "Pure butter pastry sheet", baseQuantity: 1, unit: "", aisleCategory: "Bakery"),
            Ingredient(name: "Golden honey", baseQuantity: 2, unit: "tbsp", aisleCategory: "Pantry")
        ],
        steps: [
            CookingStep(stepIndex: 1, title: "Line tart tin", durationMinutes: 10, instruction: "Press cold puff pastry into tart mould and prick base with fork."),
            CookingStep(stepIndex: 2, title: "Frangipane filling", durationMinutes: 10, instruction: "Whisk butter, sugar, egg and almond meal until pale and fluffy. Spread evenly."),
            CookingStep(stepIndex: 3, title: "Bake to gold", durationMinutes: 30, instruction: "Fan sliced pears on top. Bake at 190°C until edges are caramelized.")
        ]
    )
    
    public static let salmonRecipe = Recipe(
        title: "Lemon & herb salmon",
        subtitle: "Crisp skin wild salmon over tender asparagus spears and dill butter.",
        categoryBadge: "THE 20-MINUTE CLUB",
        collectionTag: "SHORT ON TIME. NOT TASTE.",
        totalTime: "20 min",
        effort: "Easy",
        rating: 4.7,
        homeCooksCount: 310,
        description: "Pan-seared salmon fillet with crispy golden skin, served alongside blanched green asparagus and a fragrant lemon-dill emulsified butter.",
        authorName: "Soren Lind",
        authorSubtitle: "Nordic coastal kitchen.",
        authorInitials: "SL",
        heroImageName: "SalmonCard",
        cardImageName: "SalmonCard",
        platedImageName: "SalmonCard",
        chefSecretTitle: "SKIN-SIDE DOWN FIRST",
        chefSecretBody: "Press gently with a spatula during the first 30 seconds to guarantee ultra-crisp skin without curling.",
        baseServings: 2,
        ingredients: [
            Ingredient(name: "Salmon fillets", baseQuantity: 2, unit: "", aisleCategory: "Seafood"),
            Ingredient(name: "Baby asparagus bunch", baseQuantity: 1, unit: "", aisleCategory: "Produce"),
            Ingredient(name: "Fresh dill", displayOverride: "Small bunch", aisleCategory: "Produce"),
            Ingredient(name: "Unsalted butter", baseQuantity: 25, unit: "g", aisleCategory: "Dairy")
        ],
        steps: [
            CookingStep(stepIndex: 1, title: "Prep the fish", durationMinutes: 3, instruction: "Score skin gently and season generously with flaky sea salt."),
            CookingStep(stepIndex: 2, title: "Crisp the skin", durationMinutes: 6, instruction: "Sear skin-side down in a hot skillet for 5-6 minutes until super crunchy."),
            CookingStep(stepIndex: 3, title: "Butter baste", durationMinutes: 3, instruction: "Flip, toss in butter, dill, and lemon juice. Spoon foamy butter over fillet.")
        ]
    )
}
