//
//  Enums.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import SwiftUI

// MARK: - Recipe Enums
enum RecipeCategory: String, CaseIterable, Codable, Hashable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case dessert = "Dessert"
    case snack = "Snack"
    case beverage = "Beverage"
    
    var icon: String {
        switch self {
        case .breakfast: return "sun.and.horizon"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .dessert: return "birthday.cake"
        case .snack: return "leaf"
        case .beverage: return "cup.and.saucer"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast: return Color.orange
        case .lunch: return Color.yellow
        case .dinner: return Color.purple
        case .dessert: return Color.pink
        case .snack: return Color.green
        case .beverage: return Color.blue
        }
    }
    
    var description: String {
        switch self {
        case .breakfast: return "Start your day right"
        case .lunch: return "Midday fuel"
        case .dinner: return "Evening satisfaction"
        case .dessert: return "Sweet endings"
        case .snack: return "Quick bites"
        case .beverage: return "Refreshing drinks"
        }
    }
}

enum DifficultyLevel: String, CaseIterable, Codable, Hashable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case professional = "Professional"
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle"
        case .intermediate: return "2.circle"
        case .advanced: return "3.circle"
        case .professional: return "crown"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner: return Color.green
        case .intermediate: return Color.yellow
        case .advanced: return Color.orange
        case .professional: return Color.red
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Perfect for cooking newcomers"
        case .intermediate: return "Some cooking experience helpful"
        case .advanced: return "For experienced home cooks"
        case .professional: return "Chef-level techniques required"
        }
    }
}

enum CookingSkillLevel: String, CaseIterable, Codable, Hashable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var description: String {
        switch self {
        case .beginner: return "New to cooking"
        case .intermediate: return "Some experience"
        case .advanced: return "Experienced cook"
        case .expert: return "Culinary expert"
        }
    }
}

enum MeasurementUnit: String, CaseIterable, Codable, Hashable {
    // Volume - Metric
    case milliliters = "ml"
    case liters = "L"
    
    // Volume - Imperial
    case teaspoons = "tsp"
    case tablespoons = "tbsp"
    case fluidOunces = "fl oz"
    case cups = "cup"
    case pints = "pt"
    case quarts = "qt"
    case gallons = "gal"
    
    // Weight - Metric
    case grams = "g"
    case kilograms = "kg"
    
    // Weight - Imperial
    case ounces = "oz"
    case pounds = "lb"
    
    // Count/Other
    case pieces = "pcs"
    case whole = "whole"
    case pinch = "pinch"
    case dash = "dash"
    case cloves = "cloves"
    case stalks = "stalks"
    case slices = "slices"
    case cans = "cans"
    case packages = "pkg"
    
    var isMetric: Bool {
        switch self {
        case .milliliters, .liters, .grams, .kilograms:
            return true
        default:
            return false
        }
    }
    
    var isVolume: Bool {
        switch self {
        case .milliliters, .liters, .teaspoons, .tablespoons, .fluidOunces, .cups, .pints, .quarts, .gallons:
            return true
        default:
            return false
        }
    }
    
    var isWeight: Bool {
        switch self {
        case .grams, .kilograms, .ounces, .pounds:
            return true
        default:
            return false
        }
    }
    
    var category: UnitCategory {
        if isVolume { return .volume }
        if isWeight { return .weight }
        return .count
    }
}

enum UnitCategory {
    case volume
    case weight
    case count
}

enum MeasurementSystem: String, CaseIterable, Codable, Hashable {
    case metric = "metric"
    case imperial = "imperial"
    
    var displayName: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        }
    }
    
    var description: String {
        switch self {
        case .metric: return "Grams, kilograms, milliliters, liters"
        case .imperial: return "Ounces, pounds, cups, fluid ounces"
        }
    }
}

enum IngredientCategory: String, CaseIterable, Codable, Hashable, Comparable {
    case produce = "Produce"
    case meat = "Meat & Seafood"
    case dairy = "Dairy & Eggs"
    case pantry = "Pantry Staples"
    case spices = "Herbs & Spices"
    case frozen = "Frozen"
    case bakery = "Bakery"
    case beverages = "Beverages"
    case condiments = "Condiments & Sauces"
    case grains = "Grains & Pasta"
    case snacks = "Snacks"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .produce: return "carrot"
        case .meat: return "fish"
        case .dairy: return "drop"
        case .pantry: return "archivebox"
        case .spices: return "leaf"
        case .frozen: return "snowflake"
        case .bakery: return "birthday.cake"
        case .beverages: return "cup.and.saucer"
        case .condiments: return "drop.triangle"
        case .grains: return "square.grid.3x3"
        case .snacks: return "bag"
        case .other: return "ellipsis.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .produce: return Color.green
        case .meat: return Color.red
        case .dairy: return Color.blue
        case .pantry: return Color.brown
        case .spices: return Color.orange
        case .frozen: return Color.cyan
        case .bakery: return Color.yellow
        case .beverages: return Color.purple
        case .condiments: return Color.pink
        case .grains: return Color.orange
        case .snacks: return Color.indigo
        case .other: return Color.gray
        }
    }
}

// MARK: - IngredientCategory Comparable Conformance
extension IngredientCategory {
    static func < (lhs: IngredientCategory, rhs: IngredientCategory) -> Bool {
        // Define the order for categories in the shopping list
        let order: [IngredientCategory] = [
            .produce, .meat, .dairy, .pantry, .spices, 
            .frozen, .bakery, .beverages, .condiments, 
            .grains, .snacks, .other
        ]
        
        let lhsIndex = order.firstIndex(of: lhs) ?? order.count
        let rhsIndex = order.firstIndex(of: rhs) ?? order.count
        
        return lhsIndex < rhsIndex
    }
}

enum DietaryRestriction: String, CaseIterable, Codable, Hashable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case nutFree = "Nut-Free"
    case lowCarb = "Low-Carb"
    case keto = "Keto"
    case paleo = "Paleo"
    case lowSodium = "Low-Sodium"
    case sugarFree = "Sugar-Free"
    case halal = "Halal"
    case kosher = "Kosher"
    
    var icon: String {
        switch self {
        case .vegetarian: return "leaf.circle"
        case .vegan: return "leaf.circle.fill"
        case .glutenFree: return "g.circle.fill"
        case .dairyFree: return "drop.circle"
        case .nutFree: return "n.circle.fill"
        case .lowCarb: return "c.circle"
        case .keto: return "k.circle.fill"
        case .paleo: return "p.circle.fill"
        case .lowSodium: return "s.circle"
        case .sugarFree: return "minus.circle"
        case .halal: return "h.circle.fill"
        case .kosher: return "k.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .vegetarian, .vegan: return Color.green
        case .glutenFree: return Color.orange
        case .dairyFree: return Color.blue
        case .nutFree: return Color.brown
        case .lowCarb, .keto: return Color.purple
        case .paleo: return Color.orange
        case .lowSodium: return Color.red
        case .sugarFree: return Color.pink
        case .halal, .kosher: return Color.indigo
        }
    }
}

enum Allergen: String, CaseIterable, Codable, Hashable {
    case milk = "Milk"
    case eggs = "Eggs"
    case fish = "Fish"
    case shellfish = "Shellfish"
    case treeNuts = "Tree Nuts"
    case peanuts = "Peanuts"
    case wheat = "Wheat"
    case soybeans = "Soybeans"
    case sesame = "Sesame"
    case sulfites = "Sulfites"
    
    var icon: String {
        switch self {
        case .milk: return "drop.circle"
        case .eggs: return "oval.circle"
        case .fish: return "fish.circle"
        case .shellfish: return "fossil.shell.circle"
        case .treeNuts: return "tree.circle"
        case .peanuts: return "p.circle"
        case .wheat: return "w.circle"
        case .soybeans: return "s.circle"
        case .sesame: return "sesame.circle"
        case .sulfites: return "s.circle.fill"
        }
    }
    
    var color: Color {
        Color.red
    }
}

enum MealType: String, CaseIterable, Codable, Hashable {
    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case lunch = "Lunch"
    case snack = "Snack"
    case dinner = "Dinner"
    case dessert = "Dessert"
    
    var icon: String {
        switch self {
        case .breakfast: return "sun.and.horizon"
        case .brunch: return "sun.min"
        case .lunch: return "sun.max"
        case .snack: return "leaf"
        case .dinner: return "moon.stars"
        case .dessert: return "birthday.cake"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast: return Color.orange
        case .brunch: return Color.yellow
        case .lunch: return Color.green
        case .snack: return Color.blue
        case .dinner: return Color.purple
        case .dessert: return Color.pink
        }
    }
    
    var timeRange: String {
        switch self {
        case .breakfast: return "6:00 - 10:00"
        case .brunch: return "10:00 - 14:00"
        case .lunch: return "11:00 - 15:00"
        case .snack: return "Any time"
        case .dinner: return "17:00 - 21:00"
        case .dessert: return "After meals"
        }
    }
}

enum SortOption: String, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case newest = "Newest First"
    case oldest = "Oldest First"
    case ratingHighest = "Highest Rated"
    case ratingLowest = "Lowest Rated"
    case cookingTimeShort = "Shortest Cook Time"
    case cookingTimeLong = "Longest Cook Time"
    case difficulty = "Difficulty"
    
    var systemImage: String {
        switch self {
        case .nameAscending: return "textformat.abc"
        case .nameDescending: return "textformat.abc"
        case .newest: return "clock.arrow.circlepath"
        case .oldest: return "clock"
        case .ratingHighest: return "star.fill"
        case .ratingLowest: return "star"
        case .cookingTimeShort: return "timer"
        case .cookingTimeLong: return "timer"
        case .difficulty: return "chart.bar"
        }
    }
}

enum FilterOption: String, CaseIterable {
    case all = "All Recipes"
    case favorites = "Favorites"
    case myRecipes = "My Recipes"
    case recentlyViewed = "Recently Viewed"
    case quickCook = "Quick Cook (< 30 min)"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten Free"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .favorites: return "heart.fill"
        case .myRecipes: return "person.crop.circle"
        case .recentlyViewed: return "clock.arrow.circlepath"
        case .quickCook: return "timer"
        case .vegetarian: return "leaf.circle"
        case .vegan: return "leaf.circle.fill"
        case .glutenFree: return "g.circle.fill"
        }
    }
}

// MARK: - Time Extension
extension TimeInterval {
//    static func formatTime(_ interval: TimeInterval) -> String {
//        let hours = Int(interval) / 3600
//        let minutes = Int(interval) % 3600 / 60
//        
//        if hours > 0 {
//            if minutes > 0 {
//                return "\(hours)h \(minutes)m"
//            } else {
//                return "\(hours)h"
//            }
//        } else if minutes > 0 {
//            return "\(minutes)m"
//        } else {
//            return "< 1m"
//        }
//    }
    
    var hours: Int {
        return Int(self) / 3600
    }
    
    var minutes: Int {
        return Int(self) % 3600 / 60
    }
    
    var formattedTime: String {
        return TimeInterval.formatTime(self)
    }
}
