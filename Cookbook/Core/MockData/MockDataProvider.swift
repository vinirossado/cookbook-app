//
//  MockDataProvider.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation

struct MockDataProvider {
    
    static func generateMockRecipes() -> [Recipe] {
        return [
            // Breakfast Recipes
            createMockRecipe(
                title: "Perfect Fluffy Pancakes",
                description: "Light, fluffy pancakes that are perfect for weekend mornings. Serve with maple syrup and fresh berries.",
                category: .breakfast,
                difficulty: .beginner,
                prepTime: 600, // 10 minutes
                cookTime: 900, // 15 minutes
                servings: 4,
                ingredients: [
                    createIngredient("All-purpose flour", 2, .cups, .pantry),
                    createIngredient("Sugar", 2, .tablespoons, .pantry),
                    createIngredient("Baking powder", 2, .teaspoons, .pantry),
                    createIngredient("Salt", 0.5, .teaspoons, .pantry),
                    createIngredient("Milk", 1.75, .cups, .dairy),
                    createIngredient("Egg", 1, .whole, .dairy),
                    createIngredient("Butter", 4, .tablespoons, .dairy),
                    createIngredient("Vanilla extract", 1, .teaspoons, .pantry)
                ],
                instructions: [
                    createInstruction(1, "In a large bowl, whisk together flour, sugar, baking powder, and salt."),
                    createInstruction(2, "In another bowl, whisk together milk, egg, melted butter, and vanilla."),
                    createInstruction(3, "Pour wet ingredients into dry ingredients and stir until just combined. Don't overmix.", duration: 120),
                    createInstruction(4, "Heat a non-stick pan over medium heat.", duration: 180),
                    createInstruction(5, "Pour 1/4 cup batter for each pancake. Cook until bubbles form on surface.", duration: 180),
                    createInstruction(6, "Flip and cook until golden brown on the other side.", duration: 120),
                    createInstruction(7, "Serve hot with maple syrup and fresh fruit.")
                ],
                tags: ["breakfast", "fluffy", "classic", "family-friendly"],
                rating: 4.8,
                country: .unitedStates
            ),
            
            createMockRecipe(
                title: "Avocado Toast with Poached Egg",
                description: "A healthy and delicious breakfast featuring creamy avocado on toasted sourdough topped with a perfectly poached egg.",
                category: .breakfast,
                difficulty: .intermediate,
                prepTime: 300, // 5 minutes
                cookTime: 480, // 8 minutes
                servings: 2,
                ingredients: [
                    createIngredient("Sourdough bread", 2, .slices, .bakery),
                    createIngredient("Ripe avocado", 1, .whole, .produce),
                    createIngredient("Eggs", 2, .whole, .dairy),
                    createIngredient("Lemon juice", 1, .tablespoons, .condiments),
                    createIngredient("Sea salt", 0.25, .teaspoons, .pantry),
                    createIngredient("Black pepper", 0.125, .teaspoons, .spices),
                    createIngredient("Red pepper flakes", 1, .pinch, .spices),
                    createIngredient("Extra virgin olive oil", 1, .teaspoons, .condiments)
                ],
                instructions: [
                    createInstruction(1, "Bring a pot of water to a gentle simmer with a splash of vinegar.", duration: 300),
                    createInstruction(2, "Toast the sourdough slices until golden brown.", duration: 180),
                    createInstruction(3, "Mash avocado with lemon juice, salt, and pepper."),
                    createInstruction(4, "Crack eggs into small bowls, then gently slide into simmering water.", duration: 180),
                    createInstruction(5, "Poach eggs for 3-4 minutes until whites are set.", duration: 240),
                    createInstruction(6, "Spread avocado mixture on toast, top with poached egg."),
                    createInstruction(7, "Drizzle with olive oil and sprinkle with red pepper flakes.")
                ],
                tags: ["healthy", "protein", "avocado", "poached"],
                rating: 4.6,
                country: .australia
            ),
            
            // Lunch Recipes
            createMockRecipe(
                title: "Mediterranean Quinoa Salad",
                description: "Fresh and colorful quinoa salad with Mediterranean flavors. Perfect for meal prep and packed with nutrients.",
                category: .lunch,
                difficulty: .beginner,
                prepTime: 900, // 15 minutes
                cookTime: 900, // 15 minutes
                servings: 6,
                ingredients: [
                    createIngredient("Quinoa", 1.5, .cups, .grains),
                    createIngredient("Cherry tomatoes", 1, .cups, .produce),
                    createIngredient("Cucumber", 1, .whole, .produce),
                    createIngredient("Red onion", 0.25, .cups, .produce),
                    createIngredient("Kalamata olives", 0.5, .cups, .condiments),
                    createIngredient("Feta cheese", 4, .ounces, .dairy),
                    createIngredient("Fresh parsley", 0.25, .cups, .produce),
                    createIngredient("Olive oil", 3, .tablespoons, .condiments),
                    createIngredient("Lemon juice", 2, .tablespoons, .condiments),
                    createIngredient("Oregano", 1, .teaspoons, .spices)
                ],
                instructions: [
                    createInstruction(1, "Rinse quinoa and cook according to package directions.", duration: 900),
                    createInstruction(2, "Let quinoa cool completely.", duration: 1200),
                    createInstruction(3, "Dice cucumber, halve cherry tomatoes, and thinly slice red onion."),
                    createInstruction(4, "Whisk together olive oil, lemon juice, and oregano."),
                    createInstruction(5, "Combine quinoa with vegetables and dressing."),
                    createInstruction(6, "Add crumbled feta, olives, and parsley."),
                    createInstruction(7, "Toss gently and refrigerate for 30 minutes before serving.")
                ],
                tags: ["mediterranean", "quinoa", "salad", "healthy", "meal-prep"],
                rating: 4.7,
                country: .greece
            ),
            
            // Dinner Recipes
            createMockRecipe(
                title: "Herb-Crusted Salmon with Roasted Vegetables",
                description: "Tender salmon fillet with a crispy herb crust, served alongside colorful roasted vegetables.",
                category: .dinner,
                difficulty: .intermediate,
                prepTime: 900, // 15 minutes
                cookTime: 1800, // 30 minutes
                servings: 4,
                ingredients: [
                    createIngredient("Salmon fillets", 4, .pieces, .meat),
                    createIngredient("Fresh dill", 2, .tablespoons, .produce),
                    createIngredient("Fresh parsley", 2, .tablespoons, .produce),
                    createIngredient("Breadcrumbs", 0.5, .cups, .pantry),
                    createIngredient("Asparagus", 1, .pounds, .produce),
                    createIngredient("Bell peppers", 2, .whole, .produce),
                    createIngredient("Zucchini", 2, .whole, .produce),
                    createIngredient("Olive oil", 4, .tablespoons, .condiments),
                    createIngredient("Garlic", 3, .cloves, .produce),
                    createIngredient("Lemon", 1, .whole, .produce)
                ],
                instructions: [
                    createInstruction(1, "Preheat oven to 425°F (220°C).", temperature: Temperature(fahrenheit: 425)),
                    createInstruction(2, "Cut vegetables into bite-sized pieces.", duration: 300),
                    createInstruction(3, "Toss vegetables with 2 tbsp olive oil, salt, and pepper.", duration: 120),
                    createInstruction(4, "Roast vegetables for 15 minutes.", duration: 900),
                    createInstruction(5, "Mix herbs, breadcrumbs, garlic, and remaining oil."),
                    createInstruction(6, "Press herb mixture onto salmon fillets.", duration: 180),
                    createInstruction(7, "Add salmon to oven with vegetables for 12-15 minutes.", duration: 900),
                    createInstruction(8, "Serve with lemon wedges.")
                ],
                tags: ["salmon", "healthy", "roasted", "herbs", "dinner"],
                rating: 4.9,
                country: .norway
            ),
            
            createMockRecipe(
                title: "Creamy Mushroom Risotto",
                description: "Rich and creamy risotto with mixed wild mushrooms. A comforting Italian classic perfect for dinner.",
                category: .dinner,
                difficulty: .advanced,
                prepTime: 600, // 10 minutes
                cookTime: 2100, // 35 minutes
                servings: 4,
                ingredients: [
                    createIngredient("Arborio rice", 1.5, .cups, .grains),
                    createIngredient("Mixed mushrooms", 8, .ounces, .produce),
                    createIngredient("Vegetable broth", 6, .cups, .pantry),
                    createIngredient("White wine", 0.5, .cups, .beverages),
                    createIngredient("Onion", 1, .whole, .produce),
                    createIngredient("Garlic", 3, .cloves, .produce),
                    createIngredient("Parmesan cheese", 1, .cups, .dairy),
                    createIngredient("Butter", 4, .tablespoons, .dairy),
                    createIngredient("Olive oil", 2, .tablespoons, .condiments),
                    createIngredient("Fresh thyme", 1, .tablespoons, .produce)
                ],
                instructions: [
                    createInstruction(1, "Heat broth in a saucepan and keep warm.", duration: 300),
                    createInstruction(2, "Sauté mushrooms in 1 tbsp oil until golden. Set aside.", duration: 480),
                    createInstruction(3, "Sauté diced onion and garlic in remaining oil.", duration: 300),
                    createInstruction(4, "Add rice and stir for 2 minutes until translucent.", duration: 120),
                    createInstruction(5, "Add wine and stir until absorbed.", duration: 180),
                    createInstruction(6, "Add warm broth one ladle at a time, stirring constantly.", duration: 1200),
                    createInstruction(7, "Continue until rice is creamy and al dente (18-20 minutes).", duration: 600),
                    createInstruction(8, "Stir in mushrooms, butter, and Parmesan.", duration: 120),
                    createInstruction(9, "Garnish with thyme and serve immediately.")
                ],
                tags: ["risotto", "mushrooms", "italian", "creamy", "comfort"],
                rating: 4.8,
                country: .italy
            ),
            
            // Dessert Recipes
            createMockRecipe(
                title: "Classic Chocolate Chip Cookies",
                description: "Soft, chewy chocolate chip cookies with crispy edges. The perfect treat for any occasion.",
                category: .dessert,
                difficulty: .beginner,
                prepTime: 900, // 15 minutes
                cookTime: 720, // 12 minutes
                servings: 24,
                ingredients: [
                    createIngredient("All-purpose flour", 2.25, .cups, .pantry),
                    createIngredient("Baking soda", 1, .teaspoons, .pantry),
                    createIngredient("Salt", 1, .teaspoons, .pantry),
                    createIngredient("Butter", 1, .cups, .dairy),
                    createIngredient("Brown sugar", 0.75, .cups, .pantry),
                    createIngredient("White sugar", 0.75, .cups, .pantry),
                    createIngredient("Eggs", 2, .whole, .dairy),
                    createIngredient("Vanilla extract", 2, .teaspoons, .pantry),
                    createIngredient("Chocolate chips", 2, .cups, .pantry)
                ],
                instructions: [
                    createInstruction(1, "Preheat oven to 375°F (190°C).", temperature: Temperature(fahrenheit: 375)),
                    createInstruction(2, "Mix flour, baking soda, and salt in a bowl."),
                    createInstruction(3, "Cream butter and both sugars until fluffy.", duration: 180),
                    createInstruction(4, "Beat in eggs and vanilla.", duration: 60),
                    createInstruction(5, "Gradually mix in flour mixture.", duration: 120),
                    createInstruction(6, "Stir in chocolate chips.", duration: 60),
                    createInstruction(7, "Drop rounded tablespoons onto ungreased baking sheets.", duration: 300),
                    createInstruction(8, "Bake for 9-11 minutes until golden brown.", duration: 600),
                    createInstruction(9, "Cool on baking sheet for 2 minutes before transferring.", duration: 120)
                ],
                tags: ["cookies", "chocolate", "classic", "baking", "sweet"],
                rating: 4.9,
                country: .unitedStates
            ),
            
            createMockRecipe(
                title: "Fresh Berry Parfait",
                description: "Layered parfait with Greek yogurt, fresh berries, and granola. A healthy and delicious dessert or breakfast.",
                category: .dessert,
                difficulty: .beginner,
                prepTime: 600, // 10 minutes
                cookTime: 0,
                servings: 4,
                ingredients: [
                    createIngredient("Greek yogurt", 2, .cups, .dairy),
                    createIngredient("Mixed berries", 2, .cups, .produce),
                    createIngredient("Granola", 1, .cups, .pantry),
                    createIngredient("Honey", 3, .tablespoons, .pantry),
                    createIngredient("Vanilla extract", 1, .teaspoons, .pantry),
                    createIngredient("Fresh mint", 2, .tablespoons, .produce)
                ],
                instructions: [
                    createInstruction(1, "Mix yogurt with honey and vanilla."),
                    createInstruction(2, "Wash and dry berries."),
                    createInstruction(3, "Layer yogurt, berries, and granola in glasses."),
                    createInstruction(4, "Repeat layers as desired."),
                    createInstruction(5, "Top with fresh mint leaves."),
                    createInstruction(6, "Serve immediately or chill for later.")
                ],
                tags: ["healthy", "berries", "yogurt", "parfait", "no-bake"],
                rating: 4.5,
                country: .france
            ),
            
            // Snack Recipes
            createMockRecipe(
                title: "Homemade Hummus with Veggie Sticks",
                description: "Creamy, smooth hummus made from scratch, served with fresh vegetable sticks for a healthy snack.",
                category: .snack,
                difficulty: .beginner,
                prepTime: 900, // 15 minutes
                cookTime: 0,
                servings: 6,
                ingredients: [
                    createIngredient("Chickpeas", 1, .cans, .pantry),
                    createIngredient("Tahini", 3, .tablespoons, .condiments),
                    createIngredient("Lemon juice", 3, .tablespoons, .condiments),
                    createIngredient("Garlic", 2, .cloves, .produce),
                    createIngredient("Olive oil", 2, .tablespoons, .condiments),
                    createIngredient("Cumin", 0.5, .teaspoons, .spices),
                    createIngredient("Carrots", 2, .whole, .produce),
                    createIngredient("Celery", 3, .stalks, .produce),
                    createIngredient("Bell peppers", 1, .whole, .produce),
                    createIngredient("Cucumber", 1, .whole, .produce)
                ],
                instructions: [
                    createInstruction(1, "Drain and rinse chickpeas, reserving liquid."),
                    createInstruction(2, "Add chickpeas, tahini, lemon juice, and garlic to food processor."),
                    createInstruction(3, "Process until smooth, adding reserved liquid as needed.", duration: 120),
                    createInstruction(4, "Add olive oil, cumin, salt, and pepper.", duration: 30),
                    createInstruction(5, "Process until very smooth and creamy.", duration: 60),
                    createInstruction(6, "Cut vegetables into sticks.", duration: 300),
                    createInstruction(7, "Serve hummus with fresh vegetable sticks.")
                ],
                tags: ["hummus", "healthy", "vegetables", "protein", "mediterranean"],
                rating: 4.6,
                country: .lebanon
            ),
            
            // Beverage Recipes
            createMockRecipe(
                title: "Green Goddess Smoothie",
                description: "Nutritious green smoothie packed with spinach, fruits, and healthy fats. Perfect for breakfast or post-workout.",
                category: .beverage,
                difficulty: .beginner,
                prepTime: 300, // 5 minutes
                cookTime: 0,
                servings: 2,
                ingredients: [
                    createIngredient("Fresh spinach", 2, .cups, .produce),
                    createIngredient("Banana", 1, .whole, .produce),
                    createIngredient("Mango", 0.5, .cups, .produce),
                    createIngredient("Coconut milk", 1, .cups, .beverages),
                    createIngredient("Avocado", 0.25, .whole, .produce),
                    createIngredient("Chia seeds", 1, .tablespoons, .pantry),
                    createIngredient("Honey", 1, .tablespoons, .pantry),
                    createIngredient("Lime juice", 1, .tablespoons, .condiments)
                ],
                instructions: [
                    createInstruction(1, "Add all ingredients to blender."),
                    createInstruction(2, "Blend on high until smooth and creamy.", duration: 90),
                    createInstruction(3, "Add more coconut milk if needed for consistency."),
                    createInstruction(4, "Taste and adjust sweetness with honey."),
                    createInstruction(5, "Pour into glasses and serve immediately."),
                    createInstruction(6, "Garnish with extra chia seeds if desired.")
                ],
                tags: ["smoothie", "green", "healthy", "vegan", "breakfast"],
                rating: 4.4,
                country: .brazil
            ),
            
            // Advanced Recipes
            createMockRecipe(
                title: "Beef Wellington",
                description: "Classic British dish featuring tender beef tenderloin wrapped in pâté and puff pastry. An impressive centerpiece for special occasions.",
                category: .dinner,
                difficulty: .professional,
                prepTime: 3600, // 60 minutes
                cookTime: 2400, // 40 minutes
                servings: 6,
                ingredients: [
                    createIngredient("Beef tenderloin", 2, .pounds, .meat),
                    createIngredient("Puff pastry", 1, .packages, .frozen),
                    createIngredient("Mushrooms", 1, .pounds, .produce),
                    createIngredient("Prosciutto", 8, .slices, .meat),
                    createIngredient("Egg yolk", 1, .whole, .dairy),
                    createIngredient("Dijon mustard", 2, .tablespoons, .condiments),
                    createIngredient("Fresh thyme", 2, .tablespoons, .produce),
                    createIngredient("Garlic", 3, .cloves, .produce),
                    createIngredient("Shallots", 2, .whole, .produce),
                    createIngredient("Red wine", 0.25, .cups, .beverages)
                ],
                instructions: [
                    createInstruction(1, "Season beef and sear all sides until golden brown.", duration: 480),
                    createInstruction(2, "Brush with mustard and let cool completely.", duration: 1800),
                    createInstruction(3, "Finely chop mushrooms, shallots, and garlic."),
                    createInstruction(4, "Sauté mushroom mixture until moisture evaporates.", duration: 900),
                    createInstruction(5, "Add wine and thyme, cook until dry.", duration: 300),
                    createInstruction(6, "Let mushroom mixture cool completely.", duration: 900),
                    createInstruction(7, "Lay out prosciutto and spread mushroom mixture."),
                    createInstruction(8, "Wrap beef tightly in prosciutto mixture."),
                    createInstruction(9, "Wrap in puff pastry and seal edges."),
                    createInstruction(10, "Brush with egg wash and refrigerate 30 minutes.", duration: 1800),
                    createInstruction(11, "Bake at 400°F for 25-30 minutes until golden.", duration: 1800, temperature: Temperature(fahrenheit: 400)),
                    createInstruction(12, "Rest for 10 minutes before slicing.", duration: 600)
                ],
                tags: ["beef", "wellington", "advanced", "special-occasion", "pastry"],
                rating: 4.9,
                country: .unitedKingdom
            )
        ]
    }
    
    private static func createMockRecipe(
        title: String,
        description: String,
        category: RecipeCategory,
        difficulty: DifficultyLevel,
        prepTime: TimeInterval,
        cookTime: TimeInterval,
        servings: Int,
        ingredients: [Ingredient],
        instructions: [CookingStep],
        tags: [String],
        rating: Double,
        country: Country
    ) -> Recipe {
        let userId = UUID()
        
        // Generate mock nutrition data
        let nutrition = generateMockNutrition(for: category, servings: servings)
        
        // Create recipe-specific images
        let mainImageUrl = getRecipeImageUrl(for: title)
        let secondaryImageUrl = getCategoryImageUrl(for: category)
        print("Creating recipe '\(title)' with mainImageUrl: \(mainImageUrl)")
        print("Secondary image URL: \(secondaryImageUrl)")
        let images = [
            RecipeImage(url: mainImageUrl, isMain: true, order: 0),
            RecipeImage(url: secondaryImageUrl, isMain: false, order: 1)
        ]
        
        // Generate mock reviews
        let reviews = generateMockReviews(count: Int.random(in: 3...8), rating: rating)
        
        return Recipe(
            title: title,
            description: description,
            images: images,
            ingredients: ingredients,
            instructions: instructions,
            category: category,
            difficulty: difficulty,
            cookingTime: cookTime,
            prepTime: prepTime,
            servingSize: servings,
            nutritionalInfo: nutrition,
            tags: tags,
            rating: rating,
            reviews: reviews,
            createdBy: userId,
            isPublic: true,
            isFavorite: false,
            createdAt: Date().addingTimeInterval(-TimeInterval.random(in: 0...2592000)), // Random date within last 30 days
            updatedAt: Date().addingTimeInterval(-TimeInterval.random(in: 0...86400)), // Random date within last day
            countryOfOrigin: country
        )
    }
    
    private static func createIngredient(
        _ name: String,
        _ amount: Double,
        _ unit: MeasurementUnit,
        _ category: IngredientCategory,
        isOptional: Bool = false,
        notes: String? = nil
    ) -> Ingredient {
        return Ingredient(
            name: name,
            amount: amount,
            unit: unit,
            notes: notes,
            isOptional: isOptional,
            allergens: generateAllergens(for: name),
            category: category
        )
    }
    
    private static func createInstruction(
        _ stepNumber: Int,
        _ instruction: String,
        duration: TimeInterval? = nil,
        temperature: Temperature? = nil,
        tips: String? = nil
    ) -> CookingStep {
        return CookingStep(
            stepNumber: stepNumber,
            instruction: instruction,
            duration: duration,
            temperature: temperature,
            tips: tips,
            imageUrl: nil
        )
    }
    
    private static func generateMockNutrition(for category: RecipeCategory, servings: Int) -> NutritionData {
        let baseCalories: Double
        let baseProtein: Double
        let baseCarbs: Double
        let baseFat: Double
        
        switch category {
        case .breakfast:
            baseCalories = 350
            baseProtein = 15
            baseCarbs = 45
            baseFat = 12
        case .lunch:
            baseCalories = 450
            baseProtein = 25
            baseCarbs = 35
            baseFat = 18
        case .dinner:
            baseCalories = 600
            baseProtein = 35
            baseCarbs = 40
            baseFat = 25
        case .dessert:
            baseCalories = 280
            baseProtein = 5
            baseCarbs = 45
            baseFat = 12
        case .snack:
            baseCalories = 150
            baseProtein = 8
            baseCarbs = 15
            baseFat = 6
        case .beverage:
            baseCalories = 120
            baseProtein = 3
            baseCarbs = 25
            baseFat = 2
        }
        
        return NutritionData(
            calories: baseCalories,
            protein: baseProtein,
            carbohydrates: baseCarbs,
            fat: baseFat,
            fiber: Double.random(in: 2...8),
            sugar: Double.random(in: 5...15),
            sodium: Double.random(in: 200...800),
            cholesterol: Double.random(in: 0...60),
            vitaminA: Double.random(in: 100...500),
            vitaminC: Double.random(in: 5...30),
            calcium: Double.random(in: 50...200),
            iron: Double.random(in: 1...5)
        )
    }
    
    private static func generateMockReviews(count: Int, rating: Double) -> [Review] {
        let reviewerNames = ["Sarah M.", "John D.", "Emma L.", "Michael R.", "Lisa K.", "David P.", "Anna S.", "Chris B."]
        let reviewComments = [
            "This recipe is absolutely delicious! My family loved it.",
            "Easy to follow instructions and great results.",
            "Perfect for a weeknight dinner. Will make again!",
            "The flavors were amazing. Couldn't stop eating it.",
            "Simple ingredients but tastes like restaurant quality.",
            "My new go-to recipe. Highly recommend!",
            "Kids approved! That's all I need to know.",
            "Exceeded my expectations. Five stars!"
        ]
        
        var reviews: [Review] = []
        for _ in 0..<count {
            let reviewRating = Int.random(in: max(1, Int(rating) - 1)...5)
            let review = Review(
                userId: UUID(),
                userName: reviewerNames.randomElement() ?? "Anonymous",
                rating: reviewRating,
                comment: reviewComments.randomElement() ?? "Great recipe!",
                images: []
            )
            reviews.append(review)
        }
        
        return reviews
    }
    
    private static func generateAllergens(for ingredient: String) -> [Allergen] {
        let ingredientLower = ingredient.lowercased()
        var allergens: [Allergen] = []
        
        if ingredientLower.contains("milk") || ingredientLower.contains("butter") || ingredientLower.contains("cheese") || ingredientLower.contains("yogurt") {
            allergens.append(.milk)
        }
        
        if ingredientLower.contains("egg") {
            allergens.append(.eggs)
        }
        
        if ingredientLower.contains("flour") || ingredientLower.contains("wheat") || ingredientLower.contains("bread") {
            allergens.append(.wheat)
        }
        
        if ingredientLower.contains("salmon") || ingredientLower.contains("fish") {
            allergens.append(.fish)
        }
        
        if ingredientLower.contains("nuts") || ingredientLower.contains("almond") || ingredientLower.contains("walnut") {
            allergens.append(.treeNuts)
        }
        
        if ingredientLower.contains("peanut") {
            allergens.append(.peanuts)
        }
        
        if ingredientLower.contains("soy") || ingredientLower.contains("tofu") {
            allergens.append(.soybeans)
        }
        
        return allergens
    }
    
    // MARK: - Additional Mock Data Generators
    
    static func generateMockUsers() -> [User] {
        return [
            User(name: "John Doe", email: "john@example.com"),
            User(name: "Jane Smith", email: "jane@example.com"),
            User(name: "Mike Johnson", email: "mike@example.com"),
            User(name: "Sarah Wilson", email: "sarah@example.com")
        ]
    }
    
    static func generateMockShoppingCart() -> ShoppingCart {
        var cart = ShoppingCart()
        
        // Add some mock items
        let mockIngredients = [
            createIngredient("Tomatoes", 3, .whole, .produce),
            createIngredient("Onions", 2, .whole, .produce),
            createIngredient("Garlic", 1, .whole, .produce),
            createIngredient("Olive oil", 1, .cups, .condiments),
            createIngredient("Basil", 1, .packages, .produce)
        ]
        
        for ingredient in mockIngredients {
            let mockRecipe = Recipe(
                title: "Mock Recipe",
                description: "",
                images: [],
                ingredients: [ingredient],
                instructions: [],
                category: .dinner,
                difficulty: .beginner,
                cookingTime: 0,
                prepTime: 0,
                servingSize: 1,
                nutritionalInfo: nil,
                tags: [],
                rating: 0,
                reviews: [],
                createdBy: UUID(),
                isPublic: true,
                isFavorite: false,
                createdAt: Date(),
                updatedAt: Date(),
                countryOfOrigin: .greece
            )
            cart.addIngredient(ingredient, from: mockRecipe)
        }
        
        return cart
    }
    
    static func generateMockMealPlan() -> MealPlan {
        let startDate = Calendar.current.startOfWeek(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? Date()
        
        var mealPlan = MealPlan(startDate: startDate, endDate: endDate)
        
        // Add some planned meals for the week
        let recipes = generateMockRecipes()
        let mealTypes: [MealType] = [.breakfast, .lunch, .dinner]
        
        for dayOffset in 0...6 {
            if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate) {
                for mealType in mealTypes {
                    if let recipe = recipes.randomElement() {
                        let meal = PlannedMeal(
                            recipeId: recipe.id,
                            recipeName: recipe.title,
                            mealType: mealType,
                            scheduledDate: date,
                            servings: Int.random(in: 2...4)
                        )
                        mealPlan.addMeal(meal)
                    }
                }
            }
        }
        
        return mealPlan
    }
    
    // MARK: - Helper Functions
    
    private static func getRecipeImageUrl(for title: String) -> String {
        print("bateu nessa porrta")
        // Return real food image URLs from Pexels
        switch title {
        case "Perfect Fluffy Pancakes":
            return "https://images.pexels.com/photos/1351238/pexels-photo-1351238.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Avocado Toast with Poached Egg":
            return "https://images.pexels.com/photos/1351238/pexels-photo-1351238.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Mediterranean Quinoa Salad":
            return "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Herb-Crusted Salmon with Roasted Vegetables":
            return "https://images.pexels.com/photos/725997/pexels-photo-725997.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Creamy Mushroom Risotto":
            return "https://images.pexels.com/photos/1580466/pexels-photo-1580466.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Classic Chocolate Chip Cookies":
            return "https://images.pexels.com/photos/230325/pexels-photo-230325.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Fresh Berry Parfait":
            return "https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Homemade Hummus with Veggie Sticks":
            return "https://images.pexels.com/photos/1640774/pexels-photo-1640774.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Green Goddess Smoothie":
            return "https://images.pexels.com/photos/1310522/pexels-photo-1310522.jpeg?auto=compress&cs=tinysrgb&w=800"
        case "Beef Wellington":
            return "https://images.pexels.com/photos/299347/pexels-photo-299347.jpeg?auto=compress&cs=tinysrgb&w=800"
        default:
            // Fallback to category-based images
            return getCategoryImageUrl(for: .dinner)
        }
    }
    
    private static func getCategoryImageUrl(for category: RecipeCategory) -> String {
        // Return category-specific food image URLs from Pexels
        switch category {
        case .breakfast:
            return "https://images.pexels.com/photos/103124/pexels-photo-103124.jpeg?auto=compress&cs=tinysrgb&w=800"
        case .lunch:
            return "https://images.pexels.com/photos/1640772/pexels-photo-1640772.jpeg?auto=compress&cs=tinysrgb&w=800"
        case .dinner:
            return "https://images.pexels.com/photos/2641886/pexels-photo-2641886.jpeg?auto=compress&cs=tinysrgb&w=800"
        case .dessert:
            return "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=800"
        case .snack:
            return "https://images.pexels.com/photos/1640771/pexels-photo-1640771.jpeg?auto=compress&cs=tinysrgb&w=800"
        case .beverage:
            return "https://images.pexels.com/photos/544961/pexels-photo-544961.jpeg?auto=compress&cs=tinysrgb&w=800"
        }
    }
}
