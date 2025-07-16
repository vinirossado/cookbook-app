//
//  HealthNutritionService.swift
//  CookBook Pro
//
//  Created by GitHub Copilot on 16/07/2025.
//

import Foundation
import SwiftUI
import HealthKit

// MARK: - Health & Nutrition Models
struct NutritionGoals: Codable {
    var dailyCalories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var sodiumMilligrams: Double
    var sugarGrams: Double
    var waterLiters: Double
    
    // Percentage goals (optional)
    var proteinPercentage: Double
    var carbsPercentage: Double
    var fatPercentage: Double
    
    var goalType: GoalType
    var customizedFor: User?
    var createdDate: Date
    var updatedDate: Date
    
    init() {
        // Default goals based on general recommendations
        self.dailyCalories = 2000
        self.proteinGrams = 150
        self.carbsGrams = 250
        self.fatGrams = 67
        self.fiberGrams = 25
        self.sodiumMilligrams = 2300
        self.sugarGrams = 50
        self.waterLiters = 2.5
        
        self.proteinPercentage = 30
        self.carbsPercentage = 50
        self.fatPercentage = 20
        
        self.goalType = .general
        self.customizedFor = nil
        self.createdDate = Date()
        self.updatedDate = Date()
    }
}

enum GoalType: String, CaseIterable, Codable {
    case general = "General Health"
    case weightLoss = "Weight Loss"
    case muscleGain = "Muscle Gain"
    case athletic = "Athletic Performance"
    case lowCarb = "Low Carb"
    case highProtein = "High Protein"
    case heart = "Heart Health"
    case diabetes = "Diabetes Management"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .general: return "Balanced nutrition for overall health"
        case .weightLoss: return "Calorie deficit with balanced macros"
        case .muscleGain: return "Higher protein and calories for muscle building"
        case .athletic: return "Performance-focused nutrition"
        case .lowCarb: return "Reduced carbohydrate intake"
        case .highProtein: return "Increased protein for various goals"
        case .heart: return "Heart-healthy nutrition guidelines"
        case .diabetes: return "Blood sugar management focused"
        case .custom: return "Personalized nutrition goals"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return .blue
        case .weightLoss: return .orange
        case .muscleGain: return .purple
        case .athletic: return .green
        case .lowCarb: return .red
        case .highProtein: return .brown
        case .heart: return .pink
        case .diabetes: return .yellow
        case .custom: return .gray
        }
    }
}

struct DailyNutritionSummary: Codable, Identifiable {
    let id = UUID()
    let date: Date
    var consumedCalories: Double
    var consumedProtein: Double
    var consumedCarbs: Double
    var consumedFat: Double
    var consumedFiber: Double
    var consumedSodium: Double
    var consumedSugar: Double
    var consumedWater: Double
    
    var consumedMeals: [ConsumedMeal]
    var goals: NutritionGoals
    
    // Calculated properties
    var calorieProgress: Double {
        return min(consumedCalories / goals.dailyCalories, 1.0)
    }
    
    var proteinProgress: Double {
        return min(consumedProtein / goals.proteinGrams, 1.0)
    }
    
    var carbsProgress: Double {
        return min(consumedCarbs / goals.carbsGrams, 1.0)
    }
    
    var fatProgress: Double {
        return min(consumedFat / goals.fatGrams, 1.0)
    }
    
    var overallScore: Double {
        let scores = [calorieProgress, proteinProgress, carbsProgress, fatProgress]
        return scores.reduce(0, +) / Double(scores.count) * 100
    }
    
    init(date: Date, goals: NutritionGoals) {
        self.date = date
        self.consumedCalories = 0
        self.consumedProtein = 0
        self.consumedCarbs = 0
        self.consumedFat = 0
        self.consumedFiber = 0
        self.consumedSodium = 0
        self.consumedSugar = 0
        self.consumedWater = 0
        self.consumedMeals = []
        self.goals = goals
    }
}

struct ConsumedMeal: Codable, Identifiable {
    let id = UUID()
    let recipeId: UUID
    let recipeName: String
    let servings: Double
    let mealType: MealType
    let consumedAt: Date
    let nutrition: NutritionData
    
    // Calculated nutrition based on servings
    var adjustedNutrition: NutritionData {
        return NutritionData(
            calories: nutrition.calories * servings,
            protein: nutrition.protein * servings,
            carbohydrates: nutrition.carbohydrates * servings,
            fat: nutrition.fat * servings,
            fiber: nutrition.fiber * servings,
            sugar: nutrition.sugar * servings,
            sodium: nutrition.sodium * servings,
            cholesterol: nutrition.cholesterol * servings,
            vitaminA: (nutrition.vitaminA ?? 0) * servings,
            vitaminC: (nutrition.vitaminC ?? 0) * servings,
            calcium: (nutrition.calcium ?? 0) * servings,
            iron: (nutrition.iron ?? 0) * servings
        )
    }
}

struct WeeklyNutritionReport: Codable {
    let weekStartDate: Date
    let weekEndDate: Date
    let dailySummaries: [DailyNutritionSummary]
    
    // Weekly averages
    var avgCalories: Double {
        return dailySummaries.map { $0.consumedCalories }.reduce(0, +) / Double(dailySummaries.count)
    }
    
    var avgProtein: Double {
        return dailySummaries.map { $0.consumedProtein }.reduce(0, +) / Double(dailySummaries.count)
    }
    
    var avgScore: Double {
        return dailySummaries.map { $0.overallScore }.reduce(0, +) / Double(dailySummaries.count)
    }
    
    var recommendations: [NutritionRecommendation] {
        generateWeeklyRecommendations()
    }
    
    private func generateWeeklyRecommendations() -> [NutritionRecommendation] {
        var recs: [NutritionRecommendation] = []
        
        // Check calorie consistency
        let calorieVariation = calculateVariation(values: dailySummaries.map { $0.consumedCalories })
        if calorieVariation > 0.3 {
            recs.append(NutritionRecommendation(
                type: .portionControl,
                suggestion: "Try to maintain more consistent daily calorie intake",
                impact: "Better energy levels and weight management",
                priority: .medium
            ))
        }
        
        // Check protein intake
        if avgProtein < dailySummaries.first?.goals.proteinGrams ?? 0 {
            recs.append(NutritionRecommendation(
                type: .increaseProtein,
                suggestion: "Consider adding more protein-rich foods to your meals",
                impact: "Better muscle maintenance and satiety",
                priority: .high
            ))
        }
        
        return recs
    }
    
    private func calculateVariation(values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        let standardDeviation = sqrt(variance)
        
        return mean > 0 ? standardDeviation / mean : 0
    }
}

struct AllergenAlert: Identifiable {
    let id = UUID()
    let allergen: Allergen
    let recipeId: UUID
    let recipeName: String
    let severity: AlertSeverity
    let message: String
    let suggestedAction: String
}

enum AlertSeverity: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"  
    case high = "High"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Health & Nutrition Service
@MainActor
class HealthNutritionService: ObservableObject {
    static let shared = HealthNutritionService()
    
    @Published var currentGoals: NutritionGoals = NutritionGoals()
    @Published var todaySummary: DailyNutritionSummary
    @Published var weeklyReport: WeeklyNutritionReport?
    @Published var allergenAlerts: [AllergenAlert] = []
    @Published var isHealthKitEnabled: Bool = false
    
    private let healthStore = HKHealthStore()
    private var nutritionHistory: [Date: DailyNutritionSummary] = [:]
    
    private init() {
        let initialGoals = NutritionGoals()
        self.todaySummary = DailyNutritionSummary(date: Date(), goals: initialGoals)
        loadNutritionData()
        checkHealthKitAvailability()
    }
    
    // MARK: - Public Methods
    
    /// Set personalized nutrition goals
    func setNutritionGoals(_ goals: NutritionGoals) {
        currentGoals = goals
        todaySummary.goals = goals
        saveNutritionData()
    }
    
    /// Generate goals based on user profile
    func generatePersonalizedGoals(for user: User, goalType: GoalType) async -> NutritionGoals {
        var goals = NutritionGoals()
        goals.goalType = goalType
        goals.customizedFor = user
        
        // Base calculations (simplified - in real app would use more sophisticated formulas)
        switch goalType {
        case .weightLoss:
            goals.dailyCalories = 1600
            goals.proteinGrams = 120
            goals.carbsGrams = 180
            goals.fatGrams = 53
            
        case .muscleGain:
            goals.dailyCalories = 2400
            goals.proteinGrams = 180
            goals.carbsGrams = 300
            goals.fatGrams = 80
            
        case .athletic:
            goals.dailyCalories = 2800
            goals.proteinGrams = 200
            goals.carbsGrams = 350
            goals.fatGrams = 93
            
        case .lowCarb:
            goals.dailyCalories = 1800
            goals.proteinGrams = 135
            goals.carbsGrams = 90  // 20% of calories
            goals.fatGrams = 120
            
        case .heart:
            goals.dailyCalories = 2000
            goals.proteinGrams = 150
            goals.carbsGrams = 250
            goals.fatGrams = 56  // Lower fat
            goals.sodiumMilligrams = 1500  // Lower sodium
            
        default:
            break // Use default values
        }
        
        return goals
    }
    
    /// Log a consumed meal
    func logMeal(recipe: Recipe, servings: Double, mealType: MealType) {
        guard let nutrition = recipe.nutritionalInfo else { return }
        
        let consumedMeal = ConsumedMeal(
            recipeId: recipe.id,
            recipeName: recipe.title,
            servings: servings,
            mealType: mealType,
            consumedAt: Date(),
            nutrition: nutrition
        )
        
        todaySummary.consumedMeals.append(consumedMeal)
        updateTodayNutrition()
        
        // Check for allergen alerts
        checkAllergenAlerts(for: recipe)
        
        saveNutritionData()
        
        // Sync with HealthKit if enabled
        if isHealthKitEnabled {
            syncToHealthKit(meal: consumedMeal)
        }
    }
    
    /// Remove a logged meal
    func removeMeal(mealId: UUID) {
        todaySummary.consumedMeals.removeAll { $0.id == mealId }
        updateTodayNutrition()
        saveNutritionData()
    }
    
    /// Get nutrition summary for a specific date
    func getNutritionSummary(for date: Date) -> DailyNutritionSummary? {
        let dateKey = Calendar.current.startOfDay(for: date)
        return nutritionHistory[dateKey]
    }
    
    /// Generate weekly report
    func generateWeeklyReport() async -> WeeklyNutritionReport {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? today
        
        var dailySummaries: [DailyNutritionSummary] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStart) {
                let dateKey = calendar.startOfDay(for: date)
                if let summary = nutritionHistory[dateKey] {
                    dailySummaries.append(summary)
                } else {
                    // Create empty summary for days without data
                    dailySummaries.append(DailyNutritionSummary(date: date, goals: currentGoals))
                }
            }
        }
        
        let report = WeeklyNutritionReport(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            dailySummaries: dailySummaries
        )
        
        weeklyReport = report
        return report
    }
    
    /// Check recipe for allergen conflicts
    func checkRecipeAllergens(_ recipe: Recipe) -> [AllergenAlert] {
        guard let user = AppState.shared.currentUser else { return [] }
        
        var alerts: [AllergenAlert] = []
        
        for ingredient in recipe.ingredients {
            for allergen in ingredient.allergens {
                if user.preferences.allergies.contains(allergen) {
                    let alert = AllergenAlert(
                        allergen: allergen,
                        recipeId: recipe.id,
                        recipeName: recipe.title,
                        severity: .high,
                        message: "This recipe contains \(allergen.rawValue), which you're allergic to",
                        suggestedAction: "Consider finding a substitute or choosing a different recipe"
                    )
                    alerts.append(alert)
                }
            }
        }
        
        return alerts
    }
    
    /// Get recipe suggestions based on nutrition goals
    func getRecipeSuggestions(for goalType: GoalType, mealType: MealType) -> [Recipe] {
        let allRecipes = AppState.shared.recipes.filter { $0.category.correspondsToMealType(mealType) }
        
        return allRecipes.filter { recipe in
            guard let nutrition = recipe.nutritionalInfo else { return false }
            
            switch goalType {
            case .weightLoss:
                return nutrition.calories < 400 && nutrition.fiber > 3
            case .muscleGain:
                return nutrition.protein > 20
            case .lowCarb:
                return nutrition.carbohydrates < 20
            case .heart:
                return nutrition.sodium < 600 && nutrition.fat < 15
            default:
                return true
            }
        }.prefix(10).map { $0 }
    }
    
    /// Calculate nutrition density score
    func calculateNutritionDensity(_ recipe: Recipe) -> Double {
        guard let nutrition = recipe.nutritionalInfo else { return 0 }
        
        let calories = nutrition.calories
        guard calories > 0 else { return 0 }
        
        // Calculate nutrient density based on protein, fiber, vitamins
        let proteinScore = (nutrition.protein * 4) / calories * 100 // Protein as % of calories
        let fiberScore = nutrition.fiber * 10 // Fiber boost
        let vitaminScore = ((nutrition.vitaminA ?? 0) + (nutrition.vitaminC ?? 0)) / 100
        
        let densityScore = (proteinScore + fiberScore + vitaminScore) / 3
        
        return min(densityScore, 100) // Cap at 100
    }
    
    // MARK: - Private Methods
    
    private func updateTodayNutrition() {
        var calories = 0.0
        var protein = 0.0
        var carbs = 0.0
        var fat = 0.0
        var fiber = 0.0
        var sodium = 0.0
        var sugar = 0.0
        
        for meal in todaySummary.consumedMeals {
            let adjusted = meal.adjustedNutrition
            calories += adjusted.calories
            protein += adjusted.protein
            carbs += adjusted.carbohydrates
            fat += adjusted.fat
            fiber += adjusted.fiber
            sodium += adjusted.sodium
            sugar += adjusted.sugar
        }
        
        todaySummary.consumedCalories = calories
        todaySummary.consumedProtein = protein
        todaySummary.consumedCarbs = carbs
        todaySummary.consumedFat = fat
        todaySummary.consumedFiber = fiber
        todaySummary.consumedSodium = sodium
        todaySummary.consumedSugar = sugar
        
        // Update history
        let dateKey = Calendar.current.startOfDay(for: todaySummary.date)
        nutritionHistory[dateKey] = todaySummary
    }
    
    private func checkAllergenAlerts(for recipe: Recipe) {
        let newAlerts = checkRecipeAllergens(recipe)
        allergenAlerts.append(contentsOf: newAlerts)
        
        // Keep only recent alerts (last 24 hours)
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        allergenAlerts = allergenAlerts.filter { _ in Date() > oneDayAgo }
    }
    
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isHealthKitEnabled = false
            return
        }
        
        requestHealthKitPermissions()
    }
    
    private func requestHealthKitPermissions() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isHealthKitEnabled = success
            }
        }
    }
    
    private func syncToHealthKit(meal: ConsumedMeal) {
        guard isHealthKitEnabled else { return }
        
        let nutrition = meal.adjustedNutrition
        let metadata = [HKMetadataKeyFoodType: meal.recipeName]
        
        // Create HealthKit samples
        let caloriesSample = HKQuantitySample(
            type: HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            quantity: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: nutrition.calories),
            start: meal.consumedAt,
            end: meal.consumedAt,
            metadata: metadata
        )
        
        let proteinSample = HKQuantitySample(
            type: HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!,
            quantity: HKQuantity(unit: HKUnit.gram(), doubleValue: nutrition.protein),
            start: meal.consumedAt,
            end: meal.consumedAt,
            metadata: metadata
        )
        
        // Save to HealthKit
        healthStore.save([caloriesSample, proteinSample]) { success, error in
            if let error = error {
                print("Error saving to HealthKit: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Persistence
    private func loadNutritionData() {
        // Load goals
        if let goalsData = UserDefaults.standard.data(forKey: "nutritionGoals"),
           let goals = try? JSONDecoder().decode(NutritionGoals.self, from: goalsData) {
            currentGoals = goals
        }
        
        // Load history
        if let historyData = UserDefaults.standard.data(forKey: "nutritionHistory"),
           let history = try? JSONDecoder().decode([Date: DailyNutritionSummary].self, from: historyData) {
            nutritionHistory = history
        }
        
        // Update today's summary
        let today = Calendar.current.startOfDay(for: Date())
        if let todayData = nutritionHistory[today] {
            todaySummary = todayData
        } else {
            todaySummary = DailyNutritionSummary(date: Date(), goals: currentGoals)
        }
    }
    
    private func saveNutritionData() {
        // Save goals
        if let goalsData = try? JSONEncoder().encode(currentGoals) {
            UserDefaults.standard.set(goalsData, forKey: "nutritionGoals")
        }
        
        // Save history
        if let historyData = try? JSONEncoder().encode(nutritionHistory) {
            UserDefaults.standard.set(historyData, forKey: "nutritionHistory")
        }
    }
}

// MARK: - Extensions

extension RecipeCategory {
    func correspondsToMealType(_ mealType: MealType) -> Bool {
        switch (self, mealType) {
        case (.breakfast, .breakfast):
            return true
        case (.lunch, .lunch):
            return true
        case (.dinner, .dinner):
            return true
        case (.dessert, .dessert):
            return true
        case (.snack, .snack):
            return true
        case (.beverage, _):
            return true // Beverages can be consumed at any meal
        default:
            return false
        }
    }
}
