//
//  Enums.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import SwiftUI

// MARK: - Country Origin
enum Country: String, CaseIterable, Codable, Hashable {
    // Europe
    case italy = "Italy"
    case france = "France"
    case spain = "Spain"
    case greece = "Greece"
    case germany = "Germany"
    case unitedKingdom = "United Kingdom"
    case portugal = "Portugal"
    case netherlands = "Netherlands"
    case switzerland = "Switzerland"
    case austria = "Austria"
    case poland = "Poland"
    case russia = "Russia"
    case sweden = "Sweden"
    case norway = "Norway"
    case denmark = "Denmark"
    case finland = "Finland"
    case belgium = "Belgium"
    case ireland = "Ireland"
    
    // Asia
    case china = "China"
    case japan = "Japan"
    case southKorea = "South Korea"
    case thailand = "Thailand"
    case vietnam = "Vietnam"
    case india = "India"
    case philippines = "Philippines"
    case indonesia = "Indonesia"
    case malaysia = "Malaysia"
    case singapore = "Singapore"
    case taiwan = "Taiwan"
    case mongolia = "Mongolia"
    case myanmar = "Myanmar"
    case cambodia = "Cambodia"
    case laos = "Laos"
    case nepal = "Nepal"
    case sriLanka = "Sri Lanka"
    case bangladesh = "Bangladesh"
    case pakistan = "Pakistan"
    case afghanistan = "Afghanistan"
    
    // Middle East & North Africa
    case turkey = "Turkey"
    case iran = "Iran"
    case lebanon = "Lebanon"
    case syria = "Syria"
    case israel = "Israel"
    case palestine = "Palestine"
    case jordan = "Jordan"
    case egypt = "Egypt"
    case morocco = "Morocco"
    case tunisia = "Tunisia"
    case algeria = "Algeria"
    case libya = "Libya"
    case sudan = "Sudan"
    case ethiopia = "Ethiopia"
    case saudiArabia = "Saudi Arabia"
    case uae = "UAE"
    case iraq = "Iraq"
    
    // Americas
    case unitedStates = "United States"
    case canada = "Canada"
    case mexico = "Mexico"
    case brazil = "Brazil"
    case argentina = "Argentina"
    case chile = "Chile"
    case peru = "Peru"
    case colombia = "Colombia"
    case venezuela = "Venezuela"
    case ecuador = "Ecuador"
    case bolivia = "Bolivia"
    case uruguay = "Uruguay"
    case paraguay = "Paraguay"
    case guatemala = "Guatemala"
    case honduras = "Honduras"
    case nicaragua = "Nicaragua"
    case costaRica = "Costa Rica"
    case panama = "Panama"
    case cuba = "Cuba"
    case haiti = "Haiti"
    case dominicanRepublic = "Dominican Republic"
    case jamaica = "Jamaica"
    case puertoRico = "Puerto Rico"
    
    // Africa
    case southAfrica = "South Africa"
    case nigeria = "Nigeria"
    case kenya = "Kenya"
    case ghana = "Ghana"
    case senegal = "Senegal"
    case ivoryCoast = "Ivory Coast"
    case cameroon = "Cameroon"
    case uganda = "Uganda"
    case tanzania = "Tanzania"
    case zimbabwe = "Zimbabwe"
    case botswana = "Botswana"
    case zambia = "Zambia"
    case malawi = "Malawi"
    case mozambique = "Mozambique"
    case madagascar = "Madagascar"
    
    // Oceania
    case australia = "Australia"
    case newZealand = "New Zealand"
    case fiji = "Fiji"
    case samoa = "Samoa"
    case tonga = "Tonga"
    case vanuatu = "Vanuatu"
    case papuaNewGuinea = "Papua New Guinea"
    
    // Caribbean & Central America
    case barbados = "Barbados"
    case trinidad = "Trinidad and Tobago"
    case bahamas = "Bahamas"
    case belize = "Belize"
    case guyana = "Guyana"
    case suriname = "Suriname"
    
    var flag: String {
        switch self {
        // Europe
        case .italy: return "🇮🇹"
        case .france: return "🇫🇷"
        case .spain: return "🇪🇸"
        case .greece: return "🇬🇷"
        case .germany: return "🇩🇪"
        case .unitedKingdom: return "🇬🇧"
        case .portugal: return "🇵🇹"
        case .netherlands: return "🇳🇱"
        case .switzerland: return "🇨🇭"
        case .austria: return "🇦🇹"
        case .poland: return "🇵🇱"
        case .russia: return "🇷🇺"
        case .sweden: return "🇸🇪"
        case .norway: return "🇳🇴"
        case .denmark: return "🇩🇰"
        case .finland: return "🇫🇮"
        case .belgium: return "🇧🇪"
        case .ireland: return "🇮🇪"
        
        // Asia
        case .china: return "🇨🇳"
        case .japan: return "🇯🇵"
        case .southKorea: return "🇰🇷"
        case .thailand: return "🇹🇭"
        case .vietnam: return "🇻🇳"
        case .india: return "🇮🇳"
        case .philippines: return "🇵🇭"
        case .indonesia: return "🇮🇩"
        case .malaysia: return "🇲🇾"
        case .singapore: return "🇸🇬"
        case .taiwan: return "🇹🇼"
        case .mongolia: return "🇲🇳"
        case .myanmar: return "🇲🇲"
        case .cambodia: return "🇰🇭"
        case .laos: return "🇱🇦"
        case .nepal: return "🇳🇵"
        case .sriLanka: return "🇱🇰"
        case .bangladesh: return "🇧🇩"
        case .pakistan: return "🇵🇰"
        case .afghanistan: return "🇦🇫"
        
        // Middle East & North Africa
        case .turkey: return "🇹🇷"
        case .iran: return "🇮🇷"
        case .lebanon: return "🇱🇧"
        case .syria: return "🇸🇾"
        case .israel: return "🇮🇱"
        case .palestine: return "🇵🇸"
        case .jordan: return "🇯🇴"
        case .egypt: return "🇪🇬"
        case .morocco: return "🇲🇦"
        case .tunisia: return "🇹🇳"
        case .algeria: return "🇩🇿"
        case .libya: return "🇱🇾"
        case .sudan: return "🇸🇩"
        case .ethiopia: return "🇪🇹"
        case .saudiArabia: return "🇸🇦"
        case .uae: return "🇦🇪"
        case .iraq: return "🇮🇶"
        
        // Americas
        case .unitedStates: return "🇺🇸"
        case .canada: return "🇨🇦"
        case .mexico: return "🇲🇽"
        case .brazil: return "🇧🇷"
        case .argentina: return "🇦🇷"
        case .chile: return "🇨🇱"
        case .peru: return "🇵🇪"
        case .colombia: return "🇨🇴"
        case .venezuela: return "🇻🇪"
        case .ecuador: return "🇪🇨"
        case .bolivia: return "🇧🇴"
        case .uruguay: return "🇺🇾"
        case .paraguay: return "🇵🇾"
        case .guatemala: return "🇬🇹"
        case .honduras: return "🇭🇳"
        case .nicaragua: return "🇳🇮"
        case .costaRica: return "🇨🇷"
        case .panama: return "🇵🇦"
        case .cuba: return "🇨🇺"
        case .haiti: return "🇭🇹"
        case .dominicanRepublic: return "🇩🇴"
        case .jamaica: return "🇯🇲"
        case .puertoRico: return "🇵🇷"
        
        // Africa
        case .southAfrica: return "🇿🇦"
        case .nigeria: return "🇳🇬"
        case .kenya: return "🇰🇪"
        case .ghana: return "🇬🇭"
        case .senegal: return "🇸🇳"
        case .ivoryCoast: return "🇨🇮"
        case .cameroon: return "🇨🇲"
        case .uganda: return "🇺🇬"
        case .tanzania: return "🇹🇿"
        case .zimbabwe: return "🇿🇼"
        case .botswana: return "🇧🇼"
        case .zambia: return "🇿🇲"
        case .malawi: return "🇲🇼"
        case .mozambique: return "🇲🇿"
        case .madagascar: return "🇲🇬"
        
        // Oceania
        case .australia: return "🇦🇺"
        case .newZealand: return "🇳🇿"
        case .fiji: return "🇫🇯"
        case .samoa: return "🇼🇸"
        case .tonga: return "🇹🇴"
        case .vanuatu: return "🇻🇺"
        case .papuaNewGuinea: return "🇵🇬"
        
        // Caribbean & Central America
        case .barbados: return "🇧🇧"
        case .trinidad: return "🇹🇹"
        case .bahamas: return "🇧🇸"
        case .belize: return "🇧🇿"
        case .guyana: return "🇬🇾"
        case .suriname: return "🇸🇷"
        }
    }
    
    var continent: Continent {
        switch self {
        case .italy, .france, .spain, .greece, .germany, .unitedKingdom, .portugal, .netherlands, .switzerland, .austria, .poland, .russia, .sweden, .norway, .denmark, .finland, .belgium, .ireland:
            return .europe
        case .china, .japan, .southKorea, .thailand, .vietnam, .india, .philippines, .indonesia, .malaysia, .singapore, .taiwan, .mongolia, .myanmar, .cambodia, .laos, .nepal, .sriLanka, .bangladesh, .pakistan, .afghanistan:
            return .asia
        case .turkey, .iran, .lebanon, .syria, .israel, .palestine, .jordan, .egypt, .morocco, .tunisia, .algeria, .libya, .sudan, .ethiopia, .saudiArabia, .uae, .iraq:
            return .middleEastNorthAfrica
        case .unitedStates, .canada, .mexico, .brazil, .argentina, .chile, .peru, .colombia, .venezuela, .ecuador, .bolivia, .uruguay, .paraguay, .guatemala, .honduras, .nicaragua, .costaRica, .panama, .cuba, .haiti, .dominicanRepublic, .jamaica, .puertoRico, .barbados, .trinidad, .bahamas, .belize, .guyana, .suriname:
            return .americas
        case .southAfrica, .nigeria, .kenya, .ghana, .senegal, .ivoryCoast, .cameroon, .uganda, .tanzania, .zimbabwe, .botswana, .zambia, .malawi, .mozambique, .madagascar:
            return .africa
        case .australia, .newZealand, .fiji, .samoa, .tonga, .vanuatu, .papuaNewGuinea:
            return .oceania
        }
    }
    
    var regionDescription: String {
        switch continent {
        case .europe: return "European Cuisine"
        case .asia: return "Asian Cuisine"
        case .middleEastNorthAfrica: return "Middle Eastern & North African Cuisine"
        case .americas: return "American Cuisine"
        case .africa: return "African Cuisine"
        case .oceania: return "Oceanic Cuisine"
        }
    }
    
    var displayText: String {
        return "\(flag) \(rawValue)"
    }
}

enum Continent: String, CaseIterable, Codable, Hashable {
    case europe = "Europe"
    case asia = "Asia"
    case middleEastNorthAfrica = "Middle East & North Africa"
    case americas = "Americas"
    case africa = "Africa"
    case oceania = "Oceania"
    
    var countries: [Country] {
        return Country.allCases.filter { $0.continent == self }
    }
    
    var icon: String {
        switch self {
        case .europe: return "building.columns"
        case .asia: return "mountain.2"
        case .middleEastNorthAfrica: return "moon.stars"
        case .americas: return "leaf"
        case .africa: return "sun.max"
        case .oceania: return "water.waves"
        }
    }
    
    var color: Color {
        switch self {
        case .europe: return .blue
        case .asia: return .orange
        case .middleEastNorthAfrica: return .purple
        case .americas: return .green
        case .africa: return .yellow
        case .oceania: return .cyan
        }
    }
}

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
    case byCountry = "By Country"
    case byContinent = "By Continent"
    
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
        case .byCountry: return "flag"
        case .byContinent: return "globe"
        }
    }
}

// MARK: - Time Extension
extension TimeInterval {
    static func formatTime(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval / 60) // Convert seconds to minutes
        
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let remainingMinutes = totalMinutes % 60
            
            if remainingMinutes == 0 {
                return hours == 1 ? "1 hour" : "\(hours) hours"
            } else {
                return hours == 1 ? "1 hour \(remainingMinutes) min" : "\(hours) hours \(remainingMinutes) min"
            }
        }
    }
    
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
