//
//  CoreModels.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import SwiftUI

// MARK: - User Models
struct User: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var email: String
    var profileImage: String?
    var preferences: UserPreferences
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, email: String, profileImage: String? = nil, preferences: UserPreferences = UserPreferences()) {
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.preferences = preferences
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct UserPreferences: Codable, Hashable {
    var dietaryRestrictions: [DietaryRestriction]
    var allergies: [Allergen]
    var cookingSkillLevel: CookingSkillLevel
    var preferredUnits: MeasurementUnit
    var isVegetarian: Bool
    var isVegan: Bool
    var isGlutenFree: Bool
    var isDairyFree: Bool
    var favoriteCategories: [RecipeCategory]
    
    init() {
        self.dietaryRestrictions = []
        self.allergies = []
        self.cookingSkillLevel = .beginner
        self.preferredUnits = .grams // Default to grams as metric unit
        self.isVegetarian = false
        self.isVegan = false
        self.isGlutenFree = false
        self.isDairyFree = false
        self.favoriteCategories = []
    }
}

// MARK: - Recipe Models
struct Recipe: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    var images: [RecipeImage]
    var ingredients: [Ingredient]
    var instructions: [CookingStep]
    var category: RecipeCategory
    var difficulty: DifficultyLevel
    var cookingTime: TimeInterval
    var prepTime: TimeInterval
    var servingSize: Int
    var nutritionalInfo: NutritionData?
    var tags: [String]
    var rating: Double
    var reviews: [Review]
    var createdBy: UUID
    var isPublic: Bool
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    var countryOfOrigin: Country // New property for country origin
    
    var totalTime: TimeInterval {
        return prepTime + cookingTime
    }
    
    var formattedPrepTime: String {
        return TimeInterval.formatTime(prepTime)
    }
    
    var formattedCookTime: String {
        return TimeInterval.formatTime(cookingTime)
    }
    
    var formattedTotalTime: String {
        return TimeInterval.formatTime(totalTime)
    }
    
    var difficultyColor: Color {
        switch difficulty {
        case .beginner:
            return CookBookColors.beginner
        case .intermediate:
            return CookBookColors.intermediate
        case .advanced:
            return CookBookColors.advanced
        case .professional:
            return CookBookColors.professional
        }
    }
    
    var categoryColor: Color {
        switch category {
        case .breakfast:
            return CookBookColors.breakfast
        case .lunch:
            return CookBookColors.lunch
        case .dinner:
            return CookBookColors.dinner
        case .dessert:
            return CookBookColors.dessert
        case .snack:
            return CookBookColors.snack
        case .beverage:
            return CookBookColors.beverage
        }
    }
}

struct RecipeImage: Identifiable, Codable, Hashable {
    var id = UUID()
    var url: String
    var isMain: Bool
    var caption: String?
    var order: Int
    
    init(url: String, isMain: Bool = false, caption: String? = nil, order: Int = 0) {
        self.url = url
        self.isMain = isMain
        self.caption = caption
        self.order = order
    }
}

struct Ingredient: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var amount: Double
    var unit: MeasurementUnit
    var notes: String?
    var isOptional: Bool
    var allergens: [Allergen]
    var category: IngredientCategory
    
    var formattedAmount: String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.2f", amount).replacingOccurrences(of: ".00", with: "")
        }
    }
    
    var displayText: String {
        let amountText = formattedAmount
        let unitText = unit.rawValue
        let optionalText = isOptional ? " (optional)" : ""
        let notesText = notes != nil ? " - \(notes!)" : ""
        
        return "\(amountText) \(unitText) \(name)\(optionalText)\(notesText)"
    }
}

struct CookingStep: Identifiable, Codable, Hashable {
    var id = UUID()
    var stepNumber: Int
    var instruction: String
    var duration: TimeInterval?
    var temperature: Temperature?
    var tips: String?
    var imageUrl: String?
    var isCompleted: Bool = false
    
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        return TimeInterval.formatTime(duration)
    }
    
    var formattedTemperature: String? {
        guard let temperature = temperature else { return nil }
        return "\(Int(temperature.celsius))°C / \(Int(temperature.fahrenheit))°F"
    }
}

struct Temperature: Codable, Hashable {
    var celsius: Double
    
    var fahrenheit: Double {
        return (celsius * 9/5) + 32
    }
    
    init(celsius: Double) {
        self.celsius = celsius
    }
    
    init(fahrenheit: Double) {
        self.celsius = (fahrenheit - 32) * 5/9
    }
}

struct Review: Identifiable, Codable, Hashable {
    var id = UUID()
    var userId: UUID
    var userName: String
    var rating: Int
    var comment: String
    var images: [String]
    var createdAt: Date
    var isHelpful: Bool = false
    var helpfulCount: Int = 0
    
    init(userId: UUID, userName: String, rating: Int, comment: String, images: [String] = []) {
        self.userId = userId
        self.userName = userName
        self.rating = rating
        self.comment = comment
        self.images = images
        self.createdAt = Date()
    }
}

struct NutritionData: Codable, Hashable {
    var calories: Double
    var protein: Double // grams
    var carbohydrates: Double // grams
    var fat: Double // grams
    var fiber: Double // grams
    var sugar: Double // grams
    var sodium: Double // milligrams
    var cholesterol: Double // milligrams
    var vitaminA: Double? // IU
    var vitaminC: Double? // milligrams
    var calcium: Double? // milligrams
    var iron: Double? // milligrams
    
    var formattedCalories: String {
        return String(format: "%.0f", calories)
    }
    
    var macronutrients: [(name: String, amount: String, unit: String)] {
        return [
            ("Protein", String(format: "%.1f", protein), "g"),
            ("Carbs", String(format: "%.1f", carbohydrates), "g"),
            ("Fat", String(format: "%.1f", fat), "g"),
            ("Fiber", String(format: "%.1f", fiber), "g")
        ]
    }
}

// MARK: - Shopping Models
struct ShoppingCart: Identifiable, Codable {
    var id = UUID()
    var items: [ShoppingItem]
    var createdAt: Date
    var updatedAt: Date
    var isShared: Bool
    var sharedWith: [UUID]
    
    init() {
        self.items = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isShared = false
        self.sharedWith = []
    }
    
    var totalItems: Int {
        return items.count
    }
    
    var completedItems: Int {
        return items.filter { $0.isCompleted }.count
    }
    
    var progress: Double {
        guard totalItems > 0 else { return 0 }
        return Double(completedItems) / Double(totalItems)
    }
    
    mutating func addIngredient(_ ingredient: Ingredient, from recipe: Recipe) {
        if let existingIndex = items.firstIndex(where: { $0.ingredient.name == ingredient.name && $0.ingredient.unit == ingredient.unit }) {
            items[existingIndex].ingredient.amount += ingredient.amount
            items[existingIndex].recipes.insert(recipe.id)
        } else {
            let shoppingItem = ShoppingItem(ingredient: ingredient, recipes: [recipe.id])
            items.append(shoppingItem)
        }
        updatedAt = Date()
    }
    
    mutating func removeItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        updatedAt = Date()
    }
    
    mutating func toggleCompleted(for itemId: UUID) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].isCompleted.toggle()
            items[index].completedAt = items[index].isCompleted ? Date() : nil
            updatedAt = Date()
        }
    }
}

struct ShoppingItem: Identifiable, Codable {
    var id = UUID()
    var ingredient: Ingredient
    var isCompleted: Bool
    var completedAt: Date?
    var notes: String?
    var recipes: Set<UUID>
    var addedAt: Date
    
    init(ingredient: Ingredient, recipes: Set<UUID> = []) {
        self.ingredient = ingredient
        self.isCompleted = false
        self.completedAt = nil
        self.notes = nil
        self.recipes = recipes
        self.addedAt = Date()
    }
}

// MARK: - Meal Planning Models
struct MealPlan: Identifiable, Codable {
    var id = UUID()
    var meals: [PlannedMeal]
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    var updatedAt: Date
    
    init(startDate: Date, endDate: Date) {
        self.meals = []
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func meals(for date: Date) -> [PlannedMeal] {
        return meals.filter { Calendar.current.isDate($0.scheduledDate, inSameDayAs: date) }
    }
    
    mutating func addMeal(_ meal: PlannedMeal) {
        meals.append(meal)
        updatedAt = Date()
    }
    
    mutating func removeMeal(withId id: UUID) {
        meals.removeAll { $0.id == id }
        updatedAt = Date()
    }
}

struct PlannedMeal: Identifiable, Codable {
    var id = UUID()
    var recipeId: UUID
    var recipeName: String
    var mealType: MealType
    var scheduledDate: Date
    var servings: Int
    var notes: String?
    var isCompleted: Bool
    var completedAt: Date?
    var wantToday: Bool
    
    init(recipeId: UUID, recipeName: String, mealType: MealType, scheduledDate: Date, servings: Int = 1) {
        self.recipeId = recipeId
        self.recipeName = recipeName
        self.mealType = mealType
        self.scheduledDate = scheduledDate
        self.servings = servings
        self.notes = nil
        self.isCompleted = false
        self.completedAt = nil
        self.wantToday = false
    }
}
