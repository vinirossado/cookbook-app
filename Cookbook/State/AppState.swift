//
//  AppState.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
@Observable
class AppState {
    static let shared = AppState()
    
    // MARK: - Authentication State
    var currentUser: User?
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var authError: String?
    
    // MARK: - App Settings
    var isDarkMode: Bool = false
    var selectedLanguage: String = "en"
    var notificationsEnabled: Bool = true
    var hapticFeedbackEnabled: Bool = true
    var preferredMeasurementUnit: MeasurementSystem = .metric
    
    // MARK: - Recipe State
    var recipes: [Recipe] = []
    var favoriteRecipes: Set<UUID> = []
    var recentlyViewedRecipes: [UUID] = []
    var searchText: String = ""
    var selectedCategory: RecipeCategory?
    var selectedDifficulty: DifficultyLevel?
    var sortOption: SortOption = .newest
    var filterOptions: Set<FilterOption> = []
    
    // MARK: - Shopping Cart State
    var shoppingCart: ShoppingCart = ShoppingCart()
    var shoppingListSortedByStore: Bool = true
    
    // MARK: - Meal Planning State
    var currentMealPlan: MealPlan?
    var todayMeals: [PlannedMeal] = []
    var wantTodayMeals: [PlannedMeal] = []
    
    // MARK: - UI State
    var selectedTab: TabItem = .recipes
    var isShowingRecipeDetail: Bool = false
    var selectedRecipe: Recipe?
    var isShowingAddRecipe: Bool = false
    var isShowingProfile: Bool = false
    var isShowingSettings: Bool = false
    
    // MARK: - Navigation State
    var navigationPath: [String] = []
    var presentedSheets: Set<SheetType> = []
    
    private init() {
        loadAppSettings()
        loadUserData()
        setupMockData()
    }
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async {
        isLoading = true
        authError = nil
        
        do {
            // Simulate API call
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // Mock successful authentication
            let user = User(
                name: "Demo User",
                email: email,
                preferences: UserPreferences()
            )
            
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            saveUserData()
        } catch {
            authError = "Authentication failed. Please try again."
            isLoading = false
        }
    }
    
    func signInWithApple() async {
        isLoading = true
        authError = nil
        
        // Simulate Apple Sign In
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            let user = User(
                name: "Apple User",
                email: "user@apple.com",
                preferences: UserPreferences()
            )
            
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            saveUserData()
        } catch {
            authError = "Apple Sign In failed."
            isLoading = false
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        authError = nil
        clearUserData()
    }
    
    func createAccount(name: String, email: String, password: String) async {
        isLoading = true
        authError = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let user = User(
                name: name,
                email: email,
                preferences: UserPreferences()
            )
            
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            saveUserData()
        } catch {
            authError = "Account creation failed. Please try again."
            isLoading = false
        }
    }
    
    // MARK: - Recipe Methods
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveRecipes()
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            saveRecipes()
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        favoriteRecipes.remove(recipe.id)
        recentlyViewedRecipes.removeAll { $0 == recipe.id }
        saveRecipes()
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        if favoriteRecipes.contains(recipe.id) {
            favoriteRecipes.remove(recipe.id)
        } else {
            favoriteRecipes.insert(recipe.id)
        }
        
        // Update recipe in array
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite = favoriteRecipes.contains(recipe.id)
        }
        
        saveFavorites()
    }
    
    func addToRecentlyViewed(_ recipe: Recipe) {
        recentlyViewedRecipes.removeAll { $0 == recipe.id }
        recentlyViewedRecipes.insert(recipe.id, at: 0)
        
        // Keep only last 20 items
        if recentlyViewedRecipes.count > 20 {
            recentlyViewedRecipes = Array(recentlyViewedRecipes.prefix(20))
        }
        
        saveRecentlyViewed()
    }
    
    // MARK: - Shopping Cart Methods
    func addRecipeToShoppingCart(_ recipe: Recipe) {
        for ingredient in recipe.ingredients {
            shoppingCart.addIngredient(ingredient, from: recipe)
        }
        saveShoppingCart()
    }
    
    func removeFromShoppingCart(_ item: ShoppingItem) {
        shoppingCart.items.removeAll { $0.id == item.id }
        saveShoppingCart()
    }
    
    func toggleShoppingItemCompleted(_ item: ShoppingItem) {
        shoppingCart.toggleCompleted(for: item.id)
        saveShoppingCart()
    }
    
    func clearCompletedShoppingItems() {
        shoppingCart.items.removeAll { $0.isCompleted }
        saveShoppingCart()
    }
    
    func clearShoppingCart() {
        shoppingCart = ShoppingCart()
        saveShoppingCart()
    }
    
    // MARK: - Meal Planning Methods
    func addMealToPlan(_ meal: PlannedMeal) {
        if currentMealPlan == nil {
            let startOfWeek = Calendar.current.startOfWeek(for: Date())
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? Date()
            currentMealPlan = MealPlan(startDate: startOfWeek, endDate: endOfWeek)
        }
        
        currentMealPlan?.addMeal(meal)
        updateTodayMeals()
        saveMealPlan()
    }
    
    func removeMealFromPlan(_ meal: PlannedMeal) {
        currentMealPlan?.removeMeal(withId: meal.id)
        updateTodayMeals()
        saveMealPlan()
    }
    
    func markWantToday(_ meal: PlannedMeal) {
        if let index = currentMealPlan?.meals.firstIndex(where: { $0.id == meal.id }) {
            currentMealPlan?.meals[index].wantToday = true
        }
        updateWantTodayMeals()
        saveMealPlan()
        
        // Send notification to family members
        sendWantTodayNotification(meal)
    }
    
    private func updateTodayMeals() {
        let today = Date()
        todayMeals = currentMealPlan?.meals(for: today) ?? []
    }
    
    private func updateWantTodayMeals() {
        wantTodayMeals = currentMealPlan?.meals.filter { $0.wantToday } ?? []
    }
    
    private func sendWantTodayNotification(_ meal: PlannedMeal) {
        // Implementation for sending push notifications
        NotificationManager.shared.sendWantTodayNotification(meal: meal)
    }
    
    // MARK: - Data Persistence
    private func loadAppSettings() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled")
        
        if let unitRawValue = UserDefaults.standard.string(forKey: "preferredMeasurementUnit"),
           let unit = MeasurementSystem(rawValue: unitRawValue) {
            preferredMeasurementUnit = unit
        }
    }
    
    private func saveAppSettings() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(hapticFeedbackEnabled, forKey: "hapticFeedbackEnabled")
        UserDefaults.standard.set(preferredMeasurementUnit.rawValue, forKey: "preferredMeasurementUnit")
    }
    
    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
        
        loadRecipes()
        loadFavorites()
        loadRecentlyViewed()
        loadShoppingCart()
        loadMealPlan()
    }
    
    private func saveUserData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        saveAppSettings()
    }
    
    private func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "recipes")
        UserDefaults.standard.removeObject(forKey: "favoriteRecipes")
        UserDefaults.standard.removeObject(forKey: "recentlyViewedRecipes")
        UserDefaults.standard.removeObject(forKey: "shoppingCart")
        UserDefaults.standard.removeObject(forKey: "currentMealPlan")
    }
    
    private func loadRecipes() {
        if let recipesData = UserDefaults.standard.data(forKey: "recipes"),
           let loadedRecipes = try? JSONDecoder().decode([Recipe].self, from: recipesData) {
            recipes = loadedRecipes
        }
    }
    
    private func saveRecipes() {
        if let recipesData = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(recipesData, forKey: "recipes")
        }
    }
    
    private func loadFavorites() {
        if let favoritesData = UserDefaults.standard.data(forKey: "favoriteRecipes"),
           let favorites = try? JSONDecoder().decode(Set<UUID>.self, from: favoritesData) {
            favoriteRecipes = favorites
        }
    }
    
    private func saveFavorites() {
        if let favoritesData = try? JSONEncoder().encode(favoriteRecipes) {
            UserDefaults.standard.set(favoritesData, forKey: "favoriteRecipes")
        }
    }
    
    private func loadRecentlyViewed() {
        if let recentData = UserDefaults.standard.data(forKey: "recentlyViewedRecipes"),
           let recent = try? JSONDecoder().decode([UUID].self, from: recentData) {
            recentlyViewedRecipes = recent
        }
    }
    
    private func saveRecentlyViewed() {
        if let recentData = try? JSONEncoder().encode(recentlyViewedRecipes) {
            UserDefaults.standard.set(recentData, forKey: "recentlyViewedRecipes")
        }
    }
    
    private func loadShoppingCart() {
        if let cartData = UserDefaults.standard.data(forKey: "shoppingCart"),
           let cart = try? JSONDecoder().decode(ShoppingCart.self, from: cartData) {
            shoppingCart = cart
        }
    }
    
    private func saveShoppingCart() {
        if let cartData = try? JSONEncoder().encode(shoppingCart) {
            UserDefaults.standard.set(cartData, forKey: "shoppingCart")
        }
    }
    
    private func loadMealPlan() {
        if let planData = UserDefaults.standard.data(forKey: "currentMealPlan"),
           let plan = try? JSONDecoder().decode(MealPlan.self, from: planData) {
            currentMealPlan = plan
            updateTodayMeals()
            updateWantTodayMeals()
        }
    }
    
    private func saveMealPlan() {
        if let planData = try? JSONEncoder().encode(currentMealPlan) {
            UserDefaults.standard.set(planData, forKey: "currentMealPlan")
        }
    }
    
    // MARK: - Mock Data Setup
    private func setupMockData() {
        print("🔍 AppState setupMockData called, recipes.isEmpty: \(recipes.isEmpty)")
        // Clear old data and force fresh generation with Pexels URLs
        print("�️ Clearing old recipe data and generating fresh mock data...")
        recipes = MockDataProvider.generateMockRecipes()
        saveRecipes()
        print("✅ Generated \(recipes.count) fresh recipes with Pexels URLs")
    }
}

// MARK: - Supporting Types
enum TabItem: String, CaseIterable {
    case recipes = "Recipes"
    case shopping = "Shopping"
    case planner = "Planner"
    case today = "Today"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .recipes: return "book.closed"
        case .shopping: return "cart"
        case .planner: return "calendar"
        case .today: return "clock"
        case .profile: return "person.circle"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .recipes: return "book.closed.fill"
        case .shopping: return "cart.fill"
        case .planner: return "calendar"
        case .today: return "clock.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

enum SheetType: String, CaseIterable {
    case addRecipe = "addRecipe"
    case recipeDetail = "recipeDetail"
    case editRecipe = "editRecipe"
    case profile = "profile"
    case settings = "settings"
    case shoppingList = "shoppingList"
    case mealPlanner = "mealPlanner"
    case search = "search"
    case filters = "filters"
}

// MARK: - Calendar Extension
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}
