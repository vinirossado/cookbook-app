//
//  AIRecipeAnalyzer.swift
//  CookBook Pro
//
//  Created by GitHub Copilot on 16/07/2025.
//

import Foundation
import SwiftUI

// MARK: - AI Recipe Analysis Models
struct RecipeAnalysis: Codable {
    let recipeId: UUID
    let difficultyAssessment: DifficultyAssessment
    let nutritionOptimization: NutritionOptimization
    let ingredientSubstitutions: [IngredientSubstitution]
    let cookingTips: [CookingTip]
    let timeOptimization: TimeOptimization
    let skillRequirements: [CookingSkill]
    let analysisDate: Date
    
    init(recipeId: UUID) {
        self.recipeId = recipeId
        self.difficultyAssessment = DifficultyAssessment()
        self.nutritionOptimization = NutritionOptimization()
        self.ingredientSubstitutions = []
        self.cookingTips = []
        self.timeOptimization = TimeOptimization()
        self.skillRequirements = []
        self.analysisDate = Date()
    }
    
    init(recipeId: UUID, difficultyAssessment: DifficultyAssessment, nutritionOptimization: NutritionOptimization, ingredientSubstitutions: [IngredientSubstitution], cookingTips: [CookingTip], timeOptimization: TimeOptimization, skillRequirements: [CookingSkill], analysisDate: Date) {
        self.recipeId = recipeId
        self.difficultyAssessment = difficultyAssessment
        self.nutritionOptimization = nutritionOptimization
        self.ingredientSubstitutions = ingredientSubstitutions
        self.cookingTips = cookingTips
        self.timeOptimization = timeOptimization
        self.skillRequirements = skillRequirements
        self.analysisDate = analysisDate
    }
}

struct DifficultyAssessment: Codable {
    let suggestedDifficulty: DifficultyLevel
    let complexityFactors: [ComplexityFactor]
    let simplificationSuggestions: [String]
    let advancementSuggestions: [String]
    
    init() {
        self.suggestedDifficulty = .beginner
        self.complexityFactors = []
        self.simplificationSuggestions = []
        self.advancementSuggestions = []
    }
    
    init(suggestedDifficulty: DifficultyLevel, complexityFactors: [ComplexityFactor], simplificationSuggestions: [String], advancementSuggestions: [String]) {
        self.suggestedDifficulty = suggestedDifficulty
        self.complexityFactors = complexityFactors
        self.simplificationSuggestions = simplificationSuggestions
        self.advancementSuggestions = advancementSuggestions
    }
}

struct ComplexityFactor: Codable, Identifiable {
    let id = UUID()
    let factor: String
    let impact: ComplexityImpact
    let explanation: String
    
    init(factor: String, impact: ComplexityImpact, explanation: String) {
        self.factor = factor
        self.impact = impact
        self.explanation = explanation
    }
}

enum ComplexityImpact: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct NutritionOptimization: Codable {
    let healthScore: Double // 0-100
    let recommendations: [NutritionRecommendation]
    let macroBalance: MacroBalance
    let allergenWarnings: [Allergen]
    
    init() {
        self.healthScore = 0
        self.recommendations = []
        self.macroBalance = MacroBalance()
        self.allergenWarnings = []
    }
    
    init(healthScore: Double, recommendations: [NutritionRecommendation], macroBalance: MacroBalance, allergenWarnings: [Allergen]) {
        self.healthScore = healthScore
        self.recommendations = recommendations
        self.macroBalance = macroBalance
        self.allergenWarnings = allergenWarnings
    }
}

struct NutritionRecommendation: Codable, Identifiable {
    let id = UUID()
    let type: RecommendationType
    let suggestion: String
    let impact: String
    let priority: RecommendationPriority
    
    init(type: RecommendationType, suggestion: String, impact: String, priority: RecommendationPriority) {
        self.type = type
        self.suggestion = suggestion
        self.impact = impact
        self.priority = priority
    }
}

enum RecommendationType: String, Codable {
    case reduceCalories = "Reduce Calories"
    case increaseProtein = "Increase Protein"
    case reduceSodium = "Reduce Sodium"
    case addFiber = "Add Fiber"
    case healthierFats = "Healthier Fats"
    case reduceSubstitution = "Ingredient Substitution"
    case addVegetables = "Add Vegetables"
    case portionControl = "Portion Control"
}

enum RecommendationPriority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct MacroBalance: Codable {
    let proteinPercentage: Double
    let carbsPercentage: Double
    let fatPercentage: Double
    let isBalanced: Bool
    let recommendations: String
    
    init() {
        self.proteinPercentage = 0
        self.carbsPercentage = 0
        self.fatPercentage = 0
        self.isBalanced = false
        self.recommendations = ""
    }
    
    init(proteinPercentage: Double, carbsPercentage: Double, fatPercentage: Double, isBalanced: Bool, recommendations: String) {
        self.proteinPercentage = proteinPercentage
        self.carbsPercentage = carbsPercentage
        self.fatPercentage = fatPercentage
        self.isBalanced = isBalanced
        self.recommendations = recommendations
    }
}

struct IngredientSubstitution: Codable, Identifiable {
    let id = UUID()
    let originalIngredient: String
    let substitutes: [SubstituteOption]
    let reason: SubstitutionReason
    let conversionRatio: Double
    let nutritionalImpact: String
    
    init(originalIngredient: String, substitutes: [SubstituteOption], reason: SubstitutionReason, conversionRatio: Double, nutritionalImpact: String) {
        self.originalIngredient = originalIngredient
        self.substitutes = substitutes
        self.reason = reason
        self.conversionRatio = conversionRatio
        self.nutritionalImpact = nutritionalImpact
    }
}

struct SubstituteOption: Codable, Identifiable {
    let id = UUID()
    let name: String
    let conversionRatio: Double
    let nutritionalChange: String
    let flavorImpact: FlavorImpact
    let availability: IngredientAvailability
    let dietaryBenefits: [DietaryRestriction]
    
    init(name: String, conversionRatio: Double, nutritionalChange: String, flavorImpact: FlavorImpact, availability: IngredientAvailability, dietaryBenefits: [DietaryRestriction]) {
        self.name = name
        self.conversionRatio = conversionRatio
        self.nutritionalChange = nutritionalChange
        self.flavorImpact = flavorImpact
        self.availability = availability
        self.dietaryBenefits = dietaryBenefits
    }
}

enum SubstitutionReason: String, Codable {
    case allergyFree = "Allergy-Free Alternative"
    case healthier = "Healthier Option"
    case lowerCalorie = "Lower Calorie"
    case vegan = "Vegan Alternative"
    case glutenFree = "Gluten-Free"
    case availability = "More Available"
    case budget = "Budget-Friendly"
    case seasonal = "Seasonal Alternative"
}

enum FlavorImpact: String, Codable {
    case minimal = "Minimal Change"
    case slight = "Slight Difference"
    case noticeable = "Noticeable Change"
    case significant = "Significant Change"
    
    var color: Color {
        switch self {
        case .minimal: return .green
        case .slight: return .yellow
        case .noticeable: return .orange
        case .significant: return .red
        }
    }
}

enum IngredientAvailability: String, Codable {
    case common = "Commonly Available"
    case seasonal = "Seasonal"
    case specialty = "Specialty Store"
    case rare = "Hard to Find"
    
    var color: Color {
        switch self {
        case .common: return .green
        case .seasonal: return .orange
        case .specialty: return .blue
        case .rare: return .red
        }
    }
}

struct CookingTip: Codable, Identifiable {
    let id = UUID()
    let category: TipCategory
    let tip: String
    let explanation: String
    let difficulty: DifficultyLevel
    let estimatedTimeSaved: TimeInterval?
    
    init(category: TipCategory, tip: String, explanation: String, difficulty: DifficultyLevel, estimatedTimeSaved: TimeInterval? = nil) {
        self.category = category
        self.tip = tip
        self.explanation = explanation
        self.difficulty = difficulty
        self.estimatedTimeSaved = estimatedTimeSaved
    }
}

enum TipCategory: String, Codable {
    case preparation = "Preparation"
    case cooking = "Cooking Technique"
    case timing = "Timing"
    case equipment = "Equipment"
    case storage = "Storage"
    case presentation = "Presentation"
    case safety = "Food Safety"
    
    var icon: String {
        switch self {
        case .preparation: return "hand.raised"
        case .cooking: return "flame"
        case .timing: return "timer"
        case .equipment: return "wrench.and.screwdriver"
        case .storage: return "archivebox"
        case .presentation: return "paintbrush"
        case .safety: return "shield.checkered"
        }
    }
}

struct TimeOptimization: Codable {
    let estimatedTotalTime: TimeInterval
    let actualAverageTime: TimeInterval
    let batchCookingSuggestions: [String]
    let prepAheadSteps: [PrepAheadStep]
    let parallelSteps: [ParallelStep]
    
    init() {
        self.estimatedTotalTime = 0
        self.actualAverageTime = 0
        self.batchCookingSuggestions = []
        self.prepAheadSteps = []
        self.parallelSteps = []
    }
    
    init(estimatedTotalTime: TimeInterval, actualAverageTime: TimeInterval, batchCookingSuggestions: [String], prepAheadSteps: [PrepAheadStep], parallelSteps: [ParallelStep]) {
        self.estimatedTotalTime = estimatedTotalTime
        self.actualAverageTime = actualAverageTime
        self.batchCookingSuggestions = batchCookingSuggestions
        self.prepAheadSteps = prepAheadSteps
        self.parallelSteps = parallelSteps
    }
}

struct PrepAheadStep: Codable, Identifiable {
    let id = UUID()
    let step: String
    let maxAdvanceDays: Int
    let storageInstructions: String
    
    init(step: String, maxAdvanceDays: Int, storageInstructions: String) {
        self.step = step
        self.maxAdvanceDays = maxAdvanceDays
        self.storageInstructions = storageInstructions
    }
}

struct ParallelStep: Codable, Identifiable {
    let id = UUID()
    let primaryStep: String
    let parallelStep: String
    let timeSaved: TimeInterval
    
    init(primaryStep: String, parallelStep: String, timeSaved: TimeInterval) {
        self.primaryStep = primaryStep
        self.parallelStep = parallelStep
        self.timeSaved = timeSaved
    }
}

struct CookingSkill: Codable, Identifiable {
    let id = UUID()
    let skill: String
    let difficulty: DifficultyLevel
    let isRequired: Bool
    let tutorialAvailable: Bool
    let description: String
    
    init(skill: String, difficulty: DifficultyLevel, isRequired: Bool, tutorialAvailable: Bool, description: String) {
        self.skill = skill
        self.difficulty = difficulty
        self.isRequired = isRequired
        self.tutorialAvailable = tutorialAvailable
        self.description = description
    }
}

// MARK: - AI Recipe Analyzer Service
@MainActor
class AIRecipeAnalyzer: ObservableObject {
    static let shared = AIRecipeAnalyzer()
    
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    
    private var analysisCache: [UUID: RecipeAnalysis] = [:]
    
    private init() {
        loadCachedAnalyses()
    }
    
    // MARK: - Public Methods
    func analyzeRecipe(_ recipe: Recipe) async -> RecipeAnalysis {
        if let cachedAnalysis = analysisCache[recipe.id] {
            return cachedAnalysis
        }
        
        isAnalyzing = true
        analysisProgress = 0.0
        
        let analysis = await performFullAnalysis(recipe)
        
        analysisCache[recipe.id] = analysis
        saveCachedAnalyses()
        
        isAnalyzing = false
        analysisProgress = 1.0
        
        return analysis
    }
    
    func getQuickSuggestions(_ recipe: Recipe) async -> [String] {
        let quickTips = await generateQuickTips(recipe)
        return quickTips.map { $0.tip }
    }
    
    func suggestIngredientSubstitutions(for ingredient: Ingredient, in recipe: Recipe) async -> [SubstituteOption] {
        return await generateSubstitutions(for: ingredient, recipe: recipe)
    }
    
    func assessRecipeDifficulty(_ recipe: Recipe) async -> DifficultyAssessment {
        return await analyzeDifficulty(recipe)
    }
    
    func optimizeNutrition(_ recipe: Recipe) async -> NutritionOptimization {
        return await analyzeNutrition(recipe)
    }
    
    // MARK: - Private Analysis Methods
    private func performFullAnalysis(_ recipe: Recipe) async -> RecipeAnalysis {
        var analysis = RecipeAnalysis(recipeId: recipe.id)
        
        // Update progress incrementally
        await updateProgress(0.1)
        
        // Analyze difficulty
        analysis = RecipeAnalysis(
            recipeId: recipe.id,
            difficultyAssessment: await analyzeDifficulty(recipe),
            nutritionOptimization: analysis.nutritionOptimization,
            ingredientSubstitutions: analysis.ingredientSubstitutions,
            cookingTips: analysis.cookingTips,
            timeOptimization: analysis.timeOptimization,
            skillRequirements: analysis.skillRequirements,
            analysisDate: analysis.analysisDate
        )
        await updateProgress(0.3)
        
        // Analyze nutrition
        let nutritionOpt = await analyzeNutrition(recipe)
        analysis = RecipeAnalysis(
            recipeId: recipe.id,
            difficultyAssessment: analysis.difficultyAssessment,
            nutritionOptimization: nutritionOpt,
            ingredientSubstitutions: analysis.ingredientSubstitutions,
            cookingTips: analysis.cookingTips,
            timeOptimization: analysis.timeOptimization,
            skillRequirements: analysis.skillRequirements,
            analysisDate: analysis.analysisDate
        )
        await updateProgress(0.5)
        
        // Generate substitutions
        let substitutions = await generateAllSubstitutions(recipe)
        analysis = RecipeAnalysis(
            recipeId: recipe.id,
            difficultyAssessment: analysis.difficultyAssessment,
            nutritionOptimization: analysis.nutritionOptimization,
            ingredientSubstitutions: substitutions,
            cookingTips: analysis.cookingTips,
            timeOptimization: analysis.timeOptimization,
            skillRequirements: analysis.skillRequirements,
            analysisDate: analysis.analysisDate
        )
        await updateProgress(0.7)
        
        // Generate cooking tips
        let tips = await generateCookingTips(recipe)
        analysis = RecipeAnalysis(
            recipeId: recipe.id,
            difficultyAssessment: analysis.difficultyAssessment,
            nutritionOptimization: analysis.nutritionOptimization,
            ingredientSubstitutions: analysis.ingredientSubstitutions,
            cookingTips: tips,
            timeOptimization: analysis.timeOptimization,
            skillRequirements: analysis.skillRequirements,
            analysisDate: analysis.analysisDate
        )
        await updateProgress(0.9)
        
        // Optimize timing
        let timeOpt = await analyzeTimeOptimization(recipe)
        analysis = RecipeAnalysis(
            recipeId: recipe.id,
            difficultyAssessment: analysis.difficultyAssessment,
            nutritionOptimization: analysis.nutritionOptimization,
            ingredientSubstitutions: analysis.ingredientSubstitutions,
            cookingTips: analysis.cookingTips,
            timeOptimization: timeOpt,
            skillRequirements: await analyzeSkillRequirements(recipe),
            analysisDate: analysis.analysisDate
        )
        await updateProgress(1.0)
        
        return analysis
    }
    
    private func analyzeDifficulty(_ recipe: Recipe) async -> DifficultyAssessment {
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        var complexityFactors: [ComplexityFactor] = []
        var simplifications: [String] = []
        var advancements: [String] = []
        
        // Analyze cooking techniques
        for instruction in recipe.instructions {
            if instruction.instruction.localizedCaseInsensitiveContains("julienne") ||
               instruction.instruction.localizedCaseInsensitiveContains("brunoise") ||
               instruction.instruction.localizedCaseInsensitiveContains("chiffonade") {
                complexityFactors.append(ComplexityFactor(
                    factor: "Advanced Knife Skills",
                    impact: .high,
                    explanation: "Requires precise knife techniques"
                ))
            }
            
            if instruction.instruction.localizedCaseInsensitiveContains("fold") &&
               instruction.instruction.localizedCaseInsensitiveContains("egg") {
                complexityFactors.append(ComplexityFactor(
                    factor: "Delicate Folding Technique",
                    impact: .medium,
                    explanation: "Requires gentle mixing technique"
                ))
            }
        }
        
        // Analyze ingredient count
        if recipe.ingredients.count > 15 {
            complexityFactors.append(ComplexityFactor(
                factor: "Many Ingredients",
                impact: .medium,
                explanation: "Large number of ingredients to manage"
            ))
            simplifications.append("Prepare mise en place before starting")
        }
        
        // Analyze cooking time
        if recipe.cookingTime > 7200 { // 2 hours
            complexityFactors.append(ComplexityFactor(
                factor: "Long Cooking Time",
                impact: .medium,
                explanation: "Requires patience and timing management"
            ))
        }
        
        // Generate suggestions based on current difficulty
        switch recipe.difficulty {
        case .beginner:
            advancements = [
                "Try making your own spice blend",
                "Experiment with presentation techniques",
                "Add a complementary side dish"
            ]
        case .intermediate:
            simplifications = [
                "Use pre-cut vegetables to save time",
                "Substitute complex sauces with store-bought alternatives"
            ]
            advancements = [
                "Make components from scratch",
                "Try advanced plating techniques"
            ]
        case .advanced:
            simplifications = [
                "Break recipe into steps over multiple days",
                "Use kitchen tools to simplify techniques"
            ]
        case .professional:
            simplifications = [
                "Focus on mastering one technique at a time",
                "Practice components separately first"
            ]
        }
        
        // Determine suggested difficulty
        let avgComplexity = complexityFactors.map { factor in
            switch factor.impact {
            case .low: return 1.0
            case .medium: return 2.0
            case .high: return 3.0
            }
        }.reduce(0, +) / Double(max(complexityFactors.count, 1))
        
        let suggestedDifficulty: DifficultyLevel
        switch avgComplexity {
        case 0..<1.5: suggestedDifficulty = .beginner
        case 1.5..<2.5: suggestedDifficulty = .intermediate
        case 2.5..<3.0: suggestedDifficulty = .advanced
        default: suggestedDifficulty = .professional
        }
        
        return DifficultyAssessment(
            suggestedDifficulty: suggestedDifficulty,
            complexityFactors: complexityFactors,
            simplificationSuggestions: simplifications,
            advancementSuggestions: advancements
        )
    }
    
    private func analyzeNutrition(_ recipe: Recipe) async -> NutritionOptimization {
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        guard let nutrition = recipe.nutritionalInfo else {
            return NutritionOptimization()
        }
        
        var recommendations: [NutritionRecommendation] = []
        var allergenWarnings: [Allergen] = []
        
        // Calculate health score
        var healthScore = 50.0 // Base score
        
        // Analyze calories per serving
        let caloriesPerServing = nutrition.calories / Double(recipe.servingSize)
        if caloriesPerServing > 600 {
            recommendations.append(NutritionRecommendation(
                type: .reduceCalories,
                suggestion: "Consider reducing portion size or using lighter cooking methods",
                impact: "Could reduce calories by 100-200 per serving",
                priority: .medium
            ))
            healthScore -= 10
        } else if caloriesPerServing < 300 {
            healthScore += 10
        }
        
        // Analyze protein content
        let proteinPercentage = (nutrition.protein * 4) / nutrition.calories * 100
        if proteinPercentage < 15 {
            recommendations.append(NutritionRecommendation(
                type: .increaseProtein,
                suggestion: "Add lean protein sources like chicken, fish, or legumes",
                impact: "Improves satiety and muscle health",
                priority: .medium
            ))
        }
        
        // Analyze sodium
        if nutrition.sodium > 1500 { // mg per serving
            recommendations.append(NutritionRecommendation(
                type: .reduceSodium,
                suggestion: "Reduce salt and use herbs and spices for flavor",
                impact: "Better for heart health and blood pressure",
                priority: .high
            ))
            healthScore -= 15
        }
        
        // Analyze fiber
        if nutrition.fiber < 5 {
            recommendations.append(NutritionRecommendation(
                type: .addFiber,
                suggestion: "Add vegetables, fruits, or whole grains",
                impact: "Improves digestion and satiety",
                priority: .medium
            ))
        } else {
            healthScore += 5
        }
        
        // Check for common allergens in ingredients
        for ingredient in recipe.ingredients {
            for allergen in ingredient.allergens {
                if !allergenWarnings.contains(allergen) {
                    allergenWarnings.append(allergen)
                }
            }
        }
        
        // Calculate macro balance
        let totalCalories = nutrition.calories
        let proteinCals = nutrition.protein * 4
        let carbsCals = nutrition.carbohydrates * 4
        let fatCals = nutrition.fat * 9
        
        let proteinPerc = (proteinCals / totalCalories) * 100
        let carbsPerc = (carbsCals / totalCalories) * 100
        let fatPerc = (fatCals / totalCalories) * 100
        
        let isBalanced = proteinPerc >= 10 && proteinPerc <= 35 &&
                        carbsPerc >= 45 && carbsPerc <= 65 &&
                        fatPerc >= 20 && fatPerc <= 35
        
        let macroBalance = MacroBalance(
            proteinPercentage: proteinPerc,
            carbsPercentage: carbsPerc,
            fatPercentage: fatPerc,
            isBalanced: isBalanced,
            recommendations: isBalanced ? "Well-balanced macronutrients" : "Consider adjusting macro ratios"
        )
        
        if isBalanced {
            healthScore += 15
        }
        
        // Cap health score at 100
        healthScore = min(100, max(0, healthScore))
        
        return NutritionOptimization(
            healthScore: healthScore,
            recommendations: recommendations,
            macroBalance: macroBalance,
            allergenWarnings: allergenWarnings
        )
    }
    
    private func generateAllSubstitutions(_ recipe: Recipe) async -> [IngredientSubstitution] {
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        var substitutions: [IngredientSubstitution] = []
        
        for ingredient in recipe.ingredients.prefix(5) { // Limit to first 5 ingredients
            let subs = await generateSubstitutions(for: ingredient, recipe: recipe)
            if !subs.isEmpty {
                substitutions.append(IngredientSubstitution(
                    originalIngredient: ingredient.name,
                    substitutes: subs,
                    reason: determineSubstitutionReason(ingredient),
                    conversionRatio: 1.0,
                    nutritionalImpact: "Varies by substitute"
                ))
            }
        }
        
        return substitutions
    }
    
    private func generateSubstitutions(for ingredient: Ingredient, recipe: Recipe) async -> [SubstituteOption] {
        var substitutes: [SubstituteOption] = []
        
        let name = ingredient.name.lowercased()
        
        // Common substitutions based on ingredient type
        switch true {
        case name.contains("butter"):
            substitutes = [
                SubstituteOption(
                    name: "Coconut Oil",
                    conversionRatio: 0.75,
                    nutritionalChange: "Lower saturated fat",
                    flavorImpact: .slight,
                    availability: .common,
                    dietaryBenefits: [.vegan, .dairyFree]
                ),
                SubstituteOption(
                    name: "Avocado",
                    conversionRatio: 0.5,
                    nutritionalChange: "Higher fiber, lower calories",
                    flavorImpact: .minimal,
                    availability: .common,
                    dietaryBenefits: [.vegan, .dairyFree]
                )
            ]
            
        case name.contains("egg"):
            substitutes = [
                SubstituteOption(
                    name: "Flax Egg",
                    conversionRatio: 1.0,
                    nutritionalChange: "Higher fiber, omega-3s",
                    flavorImpact: .minimal,
                    availability: .common,
                    dietaryBenefits: [.vegan]
                ),
                SubstituteOption(
                    name: "Aquafaba",
                    conversionRatio: 0.25,
                    nutritionalChange: "Lower protein, fewer calories",
                    flavorImpact: .minimal,
                    availability: .specialty,
                    dietaryBenefits: [.vegan]
                )
            ]
            
        case name.contains("milk"):
            substitutes = [
                SubstituteOption(
                    name: "Almond Milk",
                    conversionRatio: 1.0,
                    nutritionalChange: "Lower calories, no dairy",
                    flavorImpact: .slight,
                    availability: .common,
                    dietaryBenefits: [.vegan, .dairyFree]
                ),
                SubstituteOption(
                    name: "Oat Milk",
                    conversionRatio: 1.0,
                    nutritionalChange: "Higher fiber, creamy texture",
                    flavorImpact: .minimal,
                    availability: .common,
                    dietaryBenefits: [.vegan, .dairyFree]
                )
            ]
            
        case name.contains("flour") && !name.contains("almond"):
            substitutes = [
                SubstituteOption(
                    name: "Almond Flour",
                    conversionRatio: 0.25,
                    nutritionalChange: "Higher protein, lower carbs",
                    flavorImpact: .slight,
                    availability: .common,
                    dietaryBenefits: [.glutenFree, .lowCarb]
                ),
                SubstituteOption(
                    name: "Coconut Flour",
                    conversionRatio: 0.25,
                    nutritionalChange: "Higher fiber, lower carbs",
                    flavorImpact: .noticeable,
                    availability: .common,
                    dietaryBenefits: [.glutenFree, .lowCarb]
                )
            ]
            
        case name.contains("sugar"):
            substitutes = [
                SubstituteOption(
                    name: "Stevia",
                    conversionRatio: 0.125,
                    nutritionalChange: "Zero calories",
                    flavorImpact: .slight,
                    availability: .common,
                    dietaryBenefits: [.sugarFree]
                ),
                SubstituteOption(
                    name: "Maple Syrup",
                    conversionRatio: 0.75,
                    nutritionalChange: "Contains minerals",
                    flavorImpact: .noticeable,
                    availability: .common,
                    dietaryBenefits: []
                )
            ]
            
        default:
            break
        }
        
        return substitutes
    }
    
    private func determineSubstitutionReason(_ ingredient: Ingredient) -> SubstitutionReason {
        if !ingredient.allergens.isEmpty {
            return .allergyFree
        }
        
        let name = ingredient.name.lowercased()
        if name.contains("butter") || name.contains("cream") {
            return .healthier
        }
        
        if name.contains("sugar") {
            return .lowerCalorie
        }
        
        return .healthier
    }
    
    private func generateCookingTips(_ recipe: Recipe) async -> [CookingTip] {
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        return await generateQuickTips(recipe)
    }
    
    private func generateQuickTips(_ recipe: Recipe) async -> [CookingTip] {
        var tips: [CookingTip] = []
        
        // General tips based on recipe characteristics
        if recipe.ingredients.count > 10 {
            tips.append(CookingTip(
                category: .preparation,
                tip: "Prep all ingredients before cooking",
                explanation: "Mise en place ensures smooth cooking process",
                difficulty: .beginner,
                estimatedTimeSaved: 300 // 5 minutes
            ))
        }
        
        if recipe.cookingTime > 3600 { // 1 hour
            tips.append(CookingTip(
                category: .timing,
                tip: "Break into manageable steps",
                explanation: "Long recipes are easier when divided into phases",
                difficulty: .beginner,
                estimatedTimeSaved: nil
            ))
        }
        
        // Category-specific tips
        switch recipe.category {
        case .dessert:
            tips.append(CookingTip(
                category: .preparation,
                tip: "Measure ingredients precisely",
                explanation: "Baking requires accurate measurements for best results",
                difficulty: .beginner,
                estimatedTimeSaved: nil
            ))
            
        case .dinner:
            tips.append(CookingTip(
                category: .timing,
                tip: "Start with longest-cooking ingredients",
                explanation: "Work backwards from serving time",
                difficulty: .intermediate,
                estimatedTimeSaved: 600 // 10 minutes
            ))
            
        default:
            break
        }
        
        // Difficulty-specific tips
        switch recipe.difficulty {
        case .beginner:
            tips.append(CookingTip(
                category: .safety,
                tip: "Taste and adjust seasonings gradually",
                explanation: "It's easier to add more than to take away",
                difficulty: .beginner,
                estimatedTimeSaved: nil
            ))
            
        case .advanced, .professional:
            tips.append(CookingTip(
                category: .equipment,
                tip: "Use a kitchen thermometer",
                explanation: "Precise temperatures ensure consistent results",
                difficulty: .intermediate,
                estimatedTimeSaved: nil
            ))
            
        default:
            break
        }
        
        return tips
    }
    
    private func analyzeTimeOptimization(_ recipe: Recipe) async -> TimeOptimization {
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        var batchSuggestions: [String] = []
        var prepAheadSteps: [PrepAheadStep] = []
        var parallelSteps: [ParallelStep] = []
        
        // Analyze ingredients for prep-ahead opportunities
        for ingredient in recipe.ingredients {
            let name = ingredient.name.lowercased()
            if name.contains("onion") || name.contains("garlic") {
                prepAheadSteps.append(PrepAheadStep(
                    step: "Chop \(ingredient.name)",
                    maxAdvanceDays: 2,
                    storageInstructions: "Store in airtight container in refrigerator"
                ))
            }
        }
        
        // Look for batch cooking opportunities
        if recipe.servingSize <= 4 {
            batchSuggestions.append("Double the recipe and freeze half for later")
        }
        
        if recipe.category == .dinner {
            batchSuggestions.append("Prepare similar ingredients for the week")
        }
        
        // Identify parallel cooking steps
        if recipe.instructions.count > 3 {
            parallelSteps.append(ParallelStep(
                primaryStep: "Cooking main ingredient",
                parallelStep: "Prepare side dishes",
                timeSaved: 900 // 15 minutes
            ))
        }
        
        return TimeOptimization(
            estimatedTotalTime: recipe.totalTime,
            actualAverageTime: recipe.totalTime * 1.2, // Add 20% buffer
            batchCookingSuggestions: batchSuggestions,
            prepAheadSteps: prepAheadSteps,
            parallelSteps: parallelSteps
        )
    }
    
    private func analyzeSkillRequirements(_ recipe: Recipe) async -> [CookingSkill] {
        var skills: [CookingSkill] = []
        
        // Analyze instructions for required skills
        for instruction in recipe.instructions {
            let text = instruction.instruction.lowercased()
            
            if text.contains("dice") || text.contains("chop") || text.contains("mince") {
                skills.append(CookingSkill(
                    skill: "Knife Skills",
                    difficulty: .beginner,
                    isRequired: true,
                    tutorialAvailable: true,
                    description: "Basic cutting techniques"
                ))
            }
            
            if text.contains("sauté") || text.contains("sear") {
                skills.append(CookingSkill(
                    skill: "Pan Cooking",
                    difficulty: .beginner,
                    isRequired: true,
                    tutorialAvailable: true,
                    description: "Cooking with stovetop pans"
                ))
            }
            
            if text.contains("fold") && text.contains("egg") {
                skills.append(CookingSkill(
                    skill: "Folding Technique",
                    difficulty: .intermediate,
                    isRequired: true,
                    tutorialAvailable: true,
                    description: "Gentle mixing for delicate batters"
                ))
            }
        }
        
        // Remove duplicates
        return Array(Set(skills.map { $0.skill })).compactMap { skillName in
            skills.first { $0.skill == skillName }
        }
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            self.analysisProgress = progress
        }
    }
    
    // MARK: - Persistence
    private func loadCachedAnalyses() {
        if let data = UserDefaults.standard.data(forKey: "cachedRecipeAnalyses"),
           let cache = try? JSONDecoder().decode([UUID: RecipeAnalysis].self, from: data) {
            analysisCache = cache
        }
    }
    
    private func saveCachedAnalyses() {
        if let data = try? JSONEncoder().encode(analysisCache) {
            UserDefaults.standard.set(data, forKey: "cachedRecipeAnalyses")
        }
    }
}

// MARK: - CookingSkill Hashable Conformance
extension CookingSkill: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(skill)
    }
    
    static func == (lhs: CookingSkill, rhs: CookingSkill) -> Bool {
        return lhs.skill == rhs.skill
    }
}
