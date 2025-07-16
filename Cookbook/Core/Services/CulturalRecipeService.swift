//
//  CulturalRecipeService.swift
//  CookBook Pro
//
//  Created by GitHub Copilot on 16/07/2025.
//

import Foundation
import SwiftUI

// MARK: - Cultural Recipe Models
struct CulturalRecipeInfo: Codable, Identifiable {
    let id = UUID()
    let recipeId: UUID
    let countryOrigin: Country
    let culturalSignificance: String
    let traditionalOccasions: [CulturalOccasion]
    let historicalBackground: String
    let regionalVariations: [RegionalVariation]
    let culturalTips: [CulturalTip]
    let seasonalInfo: SeasonalInfo?
    let traditionalPairings: [String]
    let cookingTraditions: [CookingTradition]
    
    init(recipeId: UUID, country: Country) {
        self.recipeId = recipeId
        self.countryOrigin = country
        self.culturalSignificance = ""
        self.traditionalOccasions = []
        self.historicalBackground = ""
        self.regionalVariations = []
        self.culturalTips = []
        self.seasonalInfo = nil
        self.traditionalPairings = []
        self.cookingTraditions = []
    }
    
    init(recipeId: UUID, countryOrigin: Country, culturalSignificance: String, traditionalOccasions: [CulturalOccasion], historicalBackground: String, regionalVariations: [RegionalVariation], culturalTips: [CulturalTip], seasonalInfo: SeasonalInfo?, traditionalPairings: [String], cookingTraditions: [CookingTradition]) {
        self.recipeId = recipeId
        self.countryOrigin = countryOrigin
        self.culturalSignificance = culturalSignificance
        self.traditionalOccasions = traditionalOccasions
        self.historicalBackground = historicalBackground
        self.regionalVariations = regionalVariations
        self.culturalTips = culturalTips
        self.seasonalInfo = seasonalInfo
        self.traditionalPairings = traditionalPairings
        self.cookingTraditions = cookingTraditions
    }
}

struct CulturalOccasion: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let season: Season?
    let religiousSignificance: Bool
    let familyTradition: Bool
    let celebrationType: CelebrationType
    
    init(name: String, description: String, season: Season?, religiousSignificance: Bool, familyTradition: Bool, celebrationType: CelebrationType) {
        self.name = name
        self.description = description
        self.season = season
        self.religiousSignificance = religiousSignificance
        self.familyTradition = familyTradition
        self.celebrationType = celebrationType
    }
}

enum CelebrationType: String, Codable, CaseIterable {
    case religious = "Religious"
    case seasonal = "Seasonal"
    case family = "Family"
    case national = "National Holiday"
    case harvest = "Harvest"
    case wedding = "Wedding"
    case funeral = "Memorial"
    case birthday = "Birthday"
    case newYear = "New Year"
    case everyday = "Everyday"
    
    var icon: String {
        switch self {
        case .religious: return "cross"
        case .seasonal: return "leaf"
        case .family: return "house"
        case .national: return "flag"
        case .harvest: return "basket"
        case .wedding: return "heart"
        case .funeral: return "memories"
        case .birthday: return "birthday.cake"
        case .newYear: return "fireworks"
        case .everyday: return "calendar"
        }
    }
}

struct RegionalVariation: Codable, Identifiable {
    let id = UUID()
    let regionName: String
    let differences: String
    let uniqueIngredients: [String]
    let preparationDifferences: String
    let culturalNotes: String
    
    init(regionName: String, differences: String, uniqueIngredients: [String], preparationDifferences: String, culturalNotes: String) {
        self.regionName = regionName
        self.differences = differences
        self.uniqueIngredients = uniqueIngredients
        self.preparationDifferences = preparationDifferences
        self.culturalNotes = culturalNotes
    }
}

struct CulturalTip: Codable, Identifiable {
    let id = UUID()
    let tip: String
    let category: CulturalTipCategory
    let importance: TipImportance
    let explanation: String
    
    init(tip: String, category: CulturalTipCategory, importance: TipImportance, explanation: String) {
        self.tip = tip
        self.category = category
        self.importance = importance
        self.explanation = explanation
    }
}

enum CulturalTipCategory: String, Codable {
    case etiquette = "Dining Etiquette"
    case preparation = "Traditional Preparation"
    case serving = "Serving Style"
    case timing = "Traditional Timing"
    case accompaniments = "Traditional Accompaniments"
    case presentation = "Cultural Presentation"
    case storage = "Traditional Storage"
    
    var icon: String {
        switch self {
        case .etiquette: return "hands.sparkles"
        case .preparation: return "hand.raised"
        case .serving: return "fork.knife"
        case .timing: return "clock"
        case .accompaniments: return "plus.circle"
        case .presentation: return "paintbrush"
        case .storage: return "archivebox"
        }
    }
}

enum TipImportance: String, Codable {
    case essential = "Essential"
    case important = "Important"
    case nice = "Nice to Know"
    
    var color: Color {
        switch self {
        case .essential: return .red
        case .important: return .orange
        case .nice: return .blue
        }
    }
}

struct SeasonalInfo: Codable {
    let preferredSeasons: [Season]
    let seasonalIngredients: [String]
    let seasonalPreparation: String
    let weatherConsiderations: String
    
    init(preferredSeasons: [Season], seasonalIngredients: [String], seasonalPreparation: String, weatherConsiderations: String) {
        self.preferredSeasons = preferredSeasons
        self.seasonalIngredients = seasonalIngredients
        self.seasonalPreparation = seasonalPreparation
        self.weatherConsiderations = weatherConsiderations
    }
}

enum Season: String, Codable, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
    
    var icon: String {
        switch self {
        case .spring: return "leaf"
        case .summer: return "sun.max"
        case .fall: return "leaf.fill"
        case .winter: return "snowflake"
        }
    }
    
    var color: Color {
        switch self {
        case .spring: return .green
        case .summer: return .yellow
        case .fall: return .orange
        case .winter: return .blue
        }
    }
}

struct CookingTradition: Codable, Identifiable {
    let id = UUID()
    let traditionName: String
    let description: String
    let practicalApplication: String
    let modernAdaptation: String?
    let difficulty: DifficultyLevel
    
    init(traditionName: String, description: String, practicalApplication: String, modernAdaptation: String?, difficulty: DifficultyLevel) {
        self.traditionName = traditionName
        self.description = description
        self.practicalApplication = practicalApplication
        self.modernAdaptation = modernAdaptation
        self.difficulty = difficulty
    }
}

// MARK: - Cultural Recipe Discovery Service
@MainActor
class CulturalRecipeService: ObservableObject {
    static let shared = CulturalRecipeService()
    
    @Published var isLoading = false
    @Published var featuredCulturalRecipes: [Recipe] = []
    @Published var culturalInsights: [UUID: CulturalRecipeInfo] = [:]
    
    private var culturalDatabase: [Country: [CulturalRecipeInfo]] = [:]
    
    private init() {
        loadCulturalData()
        setupCulturalDatabase()
    }
    
    // MARK: - Public Methods
    func getCulturalInfo(for recipe: Recipe) async -> CulturalRecipeInfo? {
        if let existing = culturalInsights[recipe.id] {
            return existing
        }
        
        isLoading = true
        let info = await generateCulturalInfo(for: recipe)
        culturalInsights[recipe.id] = info
        saveCulturalData()
        isLoading = false
        
        return info
    }
    
    func getRecipesByCountry(_ country: Country) -> [Recipe] {
        return AppState.shared.recipes.filter { $0.countryOfOrigin == country }
    }
    
    func getRecipesByContinent(_ continent: Continent) -> [Recipe] {
        return AppState.shared.recipes.filter { $0.countryOfOrigin.continent == continent }
    }
    
    func getFeaturedCulturalRecipes() async -> [Recipe] {
        isLoading = true
        
        // Get current season
        let currentSeason = getCurrentSeason()
        
        // Filter recipes by seasonal relevance and cultural significance
        let seasonalRecipes = AppState.shared.recipes.filter { recipe in
            if let culturalInfo = culturalInsights[recipe.id],
               let seasonalInfo = culturalInfo.seasonalInfo {
                return seasonalInfo.preferredSeasons.contains(currentSeason)
            }
            return false
        }
        
        // If no seasonal recipes, get diverse cultural recipes
        let culturalRecipes = seasonalRecipes.isEmpty ? 
            getDiverseCulturalSelection() : 
            Array(seasonalRecipes.prefix(6))
        
        featuredCulturalRecipes = culturalRecipes
        isLoading = false
        
        return culturalRecipes
    }
    
    func searchRecipesByTradition(_ tradition: String) -> [Recipe] {
        return AppState.shared.recipes.filter { recipe in
            if let culturalInfo = culturalInsights[recipe.id] {
                return culturalInfo.cookingTraditions.contains { $0.traditionName.localizedCaseInsensitiveContains(tradition) }
            }
            return false
        }
    }
    
    func getRecipesForOccasion(_ occasion: CelebrationType) -> [Recipe] {
        return AppState.shared.recipes.filter { recipe in
            if let culturalInfo = culturalInsights[recipe.id] {
                return culturalInfo.traditionalOccasions.contains { $0.celebrationType == occasion }
            }
            return false
        }
    }
    
    func getSeasonalRecommendations() -> [Recipe] {
        let currentSeason = getCurrentSeason()
        
        return AppState.shared.recipes.filter { recipe in
            if let culturalInfo = culturalInsights[recipe.id],
               let seasonalInfo = culturalInfo.seasonalInfo {
                return seasonalInfo.preferredSeasons.contains(currentSeason)
            }
            return false
        }.prefix(8).map { $0 }
    }
    
    func getCulturalLearningPath(for country: Country) -> [Recipe] {
        let countryRecipes = getRecipesByCountry(country)
        
        // Sort by difficulty and cultural significance
        return countryRecipes.sorted { recipe1, recipe2 in
            let info1 = culturalInsights[recipe1.id]
            let info2 = culturalInsights[recipe2.id]
            
            // Prioritize essential cultural dishes first
            let essential1 = info1?.culturalTips.contains { $0.importance == .essential } ?? false
            let essential2 = info2?.culturalTips.contains { $0.importance == .essential } ?? false
            
            if essential1 && !essential2 { return true }
            if !essential1 && essential2 { return false }
            
            // Then sort by difficulty
            return recipe1.difficulty.rawValue < recipe2.difficulty.rawValue
        }
    }
    
    // MARK: - Private Methods
    private func generateCulturalInfo(for recipe: Recipe) async -> CulturalRecipeInfo {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        var info = CulturalRecipeInfo(recipeId: recipe.id, country: recipe.countryOfOrigin)
        
        // Generate cultural information based on country and recipe type
        info = await enrichWithCountrySpecificInfo(info, recipe: recipe)
        info = await addSeasonalInformation(info, recipe: recipe)
        info = await addCulturalTraditions(info, recipe: recipe)
        info = await addRegionalVariations(info, recipe: recipe)
        
        return info
    }
    
    private func enrichWithCountrySpecificInfo(_ info: CulturalRecipeInfo, recipe: Recipe) async -> CulturalRecipeInfo {
        let country = recipe.countryOfOrigin
        
        var occasions: [CulturalOccasion] = []
        var tips: [CulturalTip] = []
        var pairings: [String] = []
        var significance = ""
        var background = ""
        
        switch country {
        case .italy:
            significance = "Italian cuisine represents centuries of regional traditions, emphasizing fresh, high-quality ingredients and time-honored techniques."
            background = "This recipe reflects Italy's rich culinary heritage, where food is central to family gatherings and cultural identity."
            
            occasions = [
                CulturalOccasion(
                    name: "Sunday Family Dinner",
                    description: "Traditional Italian families gather for elaborate Sunday meals",
                    season: nil,
                    religiousSignificance: false,
                    familyTradition: true,
                    celebrationType: .family
                )
            ]
            
            tips = [
                CulturalTip(
                    tip: "Use the freshest ingredients possible",
                    category: .preparation,
                    importance: .essential,
                    explanation: "Italian cooking philosophy emphasizes ingredient quality over complexity"
                ),
                CulturalTip(
                    tip: "Take time to enjoy the meal",
                    category: .etiquette,
                    importance: .important,
                    explanation: "Meals are social events, not just nutrition"
                )
            ]
            
            pairings = ["Fresh bread", "Local wine", "Olive oil", "Parmesan cheese"]
            
        case .japan:
            significance = "Japanese cuisine embodies the principles of seasonality, simplicity, and respect for natural flavors."
            background = "This dish reflects the Japanese philosophy of harmony between taste, texture, appearance, and nutrition."
            
            occasions = [
                CulturalOccasion(
                    name: "Cherry Blossom Season",
                    description: "Special foods prepared during spring celebrations",
                    season: .spring,
                    religiousSignificance: false,
                    familyTradition: true,
                    celebrationType: .seasonal
                )
            ]
            
            tips = [
                CulturalTip(
                    tip: "Present food beautifully",
                    category: .presentation,
                    importance: .essential,
                    explanation: "Visual appeal is as important as taste in Japanese cuisine"
                ),
                CulturalTip(
                    tip: "Use seasonal ingredients",
                    category: .preparation,
                    importance: .important,
                    explanation: "Seasonality is fundamental to Japanese cooking"
                )
            ]
            
            pairings = ["Steamed rice", "Miso soup", "Pickled vegetables", "Green tea"]
            
        case .mexico:
            significance = "Mexican cuisine represents a fusion of indigenous and Spanish influences, celebrating bold flavors and ancient traditions."
            background = "This recipe carries forward traditions from pre-Columbian civilizations, adapted through centuries of cultural exchange."
            
            occasions = [
                CulturalOccasion(
                    name: "Day of the Dead",
                    description: "Traditional foods prepared to honor ancestors",
                    season: .fall,
                    religiousSignificance: true,
                    familyTradition: true,
                    celebrationType: .religious
                )
            ]
            
            tips = [
                CulturalTip(
                    tip: "Toast spices and chiles for maximum flavor",
                    category: .preparation,
                    importance: .essential,
                    explanation: "Toasting releases essential oils and deepens flavors"
                ),
                CulturalTip(
                    tip: "Make tortillas fresh when possible",
                    category: .accompaniments,
                    importance: .important,
                    explanation: "Fresh tortillas are central to the Mexican dining experience"
                )
            ]
            
            pairings = ["Fresh tortillas", "Lime wedges", "Cilantro", "Hot sauce"]
            
        case .india:
            significance = "Indian cuisine represents thousands of years of culinary evolution, with each region contributing unique flavors and techniques."
            background = "This dish reflects India's diverse cultural landscape, where spices tell stories of ancient trade routes and cultural exchanges."
            
            occasions = [
                CulturalOccasion(
                    name: "Diwali",
                    description: "Festival of lights celebrated with special sweets and dishes",
                    season: .fall,
                    religiousSignificance: true,
                    familyTradition: true,
                    celebrationType: .religious
                )
            ]
            
            tips = [
                CulturalTip(
                    tip: "Layer spices gradually",
                    category: .preparation,
                    importance: .essential,
                    explanation: "Building spice layers creates complex, harmonious flavors"
                ),
                CulturalTip(
                    tip: "Serve with various accompaniments",
                    category: .serving,
                    importance: .important,
                    explanation: "Indian meals feature multiple dishes for balanced nutrition and flavors"
                )
            ]
            
            pairings = ["Basmati rice", "Naan bread", "Yogurt", "Pickle (achar)"]
            
        case .france:
            significance = "French cuisine represents the pinnacle of culinary artistry, emphasizing technique, quality ingredients, and cultural refinement."
            background = "This recipe embodies French culinary philosophy, where cooking is elevated to an art form through precise techniques and attention to detail."
            
            occasions = [
                CulturalOccasion(
                    name: "Wine Harvest",
                    description: "Celebration of the grape harvest with traditional meals",
                    season: .fall,
                    religiousSignificance: false,
                    familyTradition: true,
                    celebrationType: .harvest
                )
            ]
            
            tips = [
                CulturalTip(
                    tip: "Master the mother sauces",
                    category: .preparation,
                    importance: .essential,
                    explanation: "French cooking is built on fundamental sauce techniques"
                ),
                CulturalTip(
                    tip: "Pair with appropriate wine",
                    category: .accompaniments,
                    importance: .important,
                    explanation: "Wine pairing is integral to French dining culture"
                )
            ]
            
            pairings = ["French wine", "Artisanal cheese", "Fresh bread", "Seasonal vegetables"]
            
        default:
            significance = "This recipe represents the unique culinary traditions of \(country.rawValue), showcasing local ingredients and time-honored techniques."
            background = "Discover the rich food culture of \(country.rawValue) through this traditional dish."
            
            tips = [
                CulturalTip(
                    tip: "Respect traditional methods",
                    category: .preparation,
                    importance: .important,
                    explanation: "Traditional techniques often yield the best results"
                )
            ]
        }
        
        return CulturalRecipeInfo(
            recipeId: info.recipeId,
            countryOrigin: info.countryOrigin,
            culturalSignificance: significance,
            traditionalOccasions: occasions,
            historicalBackground: background,
            regionalVariations: info.regionalVariations,
            culturalTips: tips,
            seasonalInfo: info.seasonalInfo,
            traditionalPairings: pairings,
            cookingTraditions: info.cookingTraditions
        )
    }
    
    private func addSeasonalInformation(_ info: CulturalRecipeInfo, recipe: Recipe) async -> CulturalRecipeInfo {
        let seasonalInfo: SeasonalInfo?
        
        switch recipe.category {
        case .dessert:
            seasonalInfo = SeasonalInfo(
                preferredSeasons: [.winter, .fall],
                seasonalIngredients: ["Cinnamon", "Nutmeg", "Apples", "Pumpkin"],
                seasonalPreparation: "Perfect for cold weather comfort",
                weatherConsiderations: "Warm desserts are especially comforting in cold seasons"
            )
        case .beverage:
            seasonalInfo = SeasonalInfo(
                preferredSeasons: [.summer],
                seasonalIngredients: ["Fresh fruits", "Mint", "Ice", "Citrus"],
                seasonalPreparation: "Refreshing drinks for hot weather",
                weatherConsiderations: "Serve chilled during warm months"
            )
        case .breakfast:
            seasonalInfo = SeasonalInfo(
                preferredSeasons: Season.allCases,
                seasonalIngredients: ["Seasonal fruits", "Fresh herbs"],
                seasonalPreparation: "Adapt to seasonal ingredients",
                weatherConsiderations: "Light in summer, hearty in winter"
            )
        default:
            seasonalInfo = SeasonalInfo(
                preferredSeasons: Season.allCases,
                seasonalIngredients: ["Local seasonal produce"],
                seasonalPreparation: "Best with fresh, seasonal ingredients",
                weatherConsiderations: "Enjoy year-round with seasonal adaptations"
            )
        }
        
        return CulturalRecipeInfo(
            recipeId: info.recipeId,
            countryOrigin: info.countryOrigin,
            culturalSignificance: info.culturalSignificance,
            traditionalOccasions: info.traditionalOccasions,
            historicalBackground: info.historicalBackground,
            regionalVariations: info.regionalVariations,
            culturalTips: info.culturalTips,
            seasonalInfo: seasonalInfo,
            traditionalPairings: info.traditionalPairings,
            cookingTraditions: info.cookingTraditions
        )
    }
    
    private func addCulturalTraditions(_ info: CulturalRecipeInfo, recipe: Recipe) async -> CulturalRecipeInfo {
        var traditions: [CookingTradition] = []
        
        switch info.countryOrigin {
        case .italy:
            traditions = [
                CookingTradition(
                    traditionName: "Al Dente",
                    description: "Cooking pasta to the perfect texture - firm to the bite",
                    practicalApplication: "Test pasta frequently in the last few minutes of cooking",
                    modernAdaptation: "Use a timer but trust your taste",
                    difficulty: .beginner
                ),
                CookingTradition(
                    traditionName: "Soffritto",
                    description: "Base of onions, celery, and carrots for sauces",
                    practicalApplication: "Slowly cook vegetables until soft and aromatic",
                    modernAdaptation: "Can be prepared in advance and frozen",
                    difficulty: .beginner
                )
            ]
        case .japan:
            traditions = [
                CookingTradition(
                    traditionName: "Kaiseki",
                    description: "Traditional multi-course dining emphasizing seasonality",
                    practicalApplication: "Consider color, texture, and temperature in each dish",
                    modernAdaptation: "Apply principles to everyday meals for balance",
                    difficulty: .advanced
                ),
                CookingTradition(
                    traditionName: "Umami",
                    description: "The fifth taste - savory depth of flavor",
                    practicalApplication: "Layer ingredients like miso, mushrooms, and seaweed",
                    modernAdaptation: "Use umami-rich ingredients to enhance any cuisine",
                    difficulty: .intermediate
                )
            ]
        case .france:
            traditions = [
                CookingTradition(
                    traditionName: "Mise en Place",
                    description: "Everything in its place - organized preparation",
                    practicalApplication: "Prepare all ingredients before cooking begins",
                    modernAdaptation: "Essential for stress-free home cooking",
                    difficulty: .beginner
                ),
                CookingTradition(
                    traditionName: "Mother Sauces",
                    description: "Five fundamental sauces in French cuisine",
                    practicalApplication: "Master these techniques for sauce variations",
                    modernAdaptation: "Learn one at a time, practice regularly",
                    difficulty: .advanced
                )
            ]
        default:
            traditions = [
                CookingTradition(
                    traditionName: "Traditional Techniques",
                    description: "Time-honored methods passed down through generations",
                    practicalApplication: "Follow traditional steps for authentic results",
                    modernAdaptation: "Combine traditional methods with modern tools",
                    difficulty: .intermediate
                )
            ]
        }
        
        return CulturalRecipeInfo(
            recipeId: info.recipeId,
            countryOrigin: info.countryOrigin,
            culturalSignificance: info.culturalSignificance,
            traditionalOccasions: info.traditionalOccasions,
            historicalBackground: info.historicalBackground,
            regionalVariations: info.regionalVariations,
            culturalTips: info.culturalTips,
            seasonalInfo: info.seasonalInfo,
            traditionalPairings: info.traditionalPairings,
            cookingTraditions: traditions
        )
    }
    
    private func addRegionalVariations(_ info: CulturalRecipeInfo, recipe: Recipe) async -> CulturalRecipeInfo {
        var variations: [RegionalVariation] = []
        
        switch info.countryOrigin {
        case .italy:
            variations = [
                RegionalVariation(
                    regionName: "Northern Italy",
                    differences: "Uses more butter, cream, and rice",
                    uniqueIngredients: ["Arborio rice", "Gorgonzola", "Prosciutto"],
                    preparationDifferences: "Longer cooking times, creamy textures",
                    culturalNotes: "Influenced by neighboring countries"
                ),
                RegionalVariation(
                    regionName: "Southern Italy",
                    differences: "Emphasizes olive oil, tomatoes, and seafood",
                    uniqueIngredients: ["San Marzano tomatoes", "Mozzarella di bufala", "Fresh herbs"],
                    preparationDifferences: "Quick cooking, bright flavors",
                    culturalNotes: "Mediterranean influence, ancient traditions"
                )
            ]
        case .india:
            variations = [
                RegionalVariation(
                    regionName: "North India",
                    differences: "Heavier use of dairy, wheat-based breads",
                    uniqueIngredients: ["Paneer", "Naan", "Garam masala"],
                    preparationDifferences: "Rich gravies, tandoor cooking",
                    culturalNotes: "Mughal influence, colder climate adaptations"
                ),
                RegionalVariation(
                    regionName: "South India",
                    differences: "Rice-based, coconut, curry leaves",
                    uniqueIngredients: ["Coconut", "Curry leaves", "Tamarind"],
                    preparationDifferences: "Steaming, fermenting, lighter curries",
                    culturalNotes: "Ancient Dravidian traditions, tropical ingredients"
                )
            ]
        default:
            break
        }
        
        return CulturalRecipeInfo(
            recipeId: info.recipeId,
            countryOrigin: info.countryOrigin,
            culturalSignificance: info.culturalSignificance,
            traditionalOccasions: info.traditionalOccasions,
            historicalBackground: info.historicalBackground,
            regionalVariations: variations,
            culturalTips: info.culturalTips,
            seasonalInfo: info.seasonalInfo,
            traditionalPairings: info.traditionalPairings,
            cookingTraditions: info.cookingTraditions
        )
    }
    
    private func getCurrentSeason() -> Season {
        let month = Calendar.current.component(.month, from: Date())
        
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .fall
        default: return .winter
        }
    }
    
    private func getDiverseCulturalSelection() -> [Recipe] {
        let allRecipes = AppState.shared.recipes
        let continents = Continent.allCases
        
        var selectedRecipes: [Recipe] = []
        
        // Get one recipe from each continent
        for continent in continents {
            if let recipe = allRecipes.first(where: { $0.countryOfOrigin.continent == continent }) {
                selectedRecipes.append(recipe)
            }
        }
        
        // Fill remaining slots with diverse selections
        let remaining = allRecipes.filter { !selectedRecipes.contains($0) }
        selectedRecipes.append(contentsOf: Array(remaining.prefix(6 - selectedRecipes.count)))
        
        return selectedRecipes
    }
    
    private func setupCulturalDatabase() {
        // Initialize cultural database with basic information
        for country in Country.allCases.prefix(10) { // Start with top 10 countries
            culturalDatabase[country] = []
        }
    }
    
    // MARK: - Persistence
    private func loadCulturalData() {
        if let data = UserDefaults.standard.data(forKey: "culturalInsights"),
           let insights = try? JSONDecoder().decode([UUID: CulturalRecipeInfo].self, from: data) {
            culturalInsights = insights
        }
    }
    
    private func saveCulturalData() {
        if let data = try? JSONEncoder().encode(culturalInsights) {
            UserDefaults.standard.set(data, forKey: "culturalInsights")
        }
    }
}
