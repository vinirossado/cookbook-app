//
//  RecipeDetailViewModel.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation

@MainActor
@Observable
class RecipeDetailViewModel {
    private let interactor: RecipeDetailInteractorProtocol
    private let router: RecipeDetailRouterProtocol
    
    // State
    var recipe: Recipe?
    var isFavorite = false
    var adjustedServings: Int = 1
    var checkedIngredients: Set<UUID> = []
    var completedSteps: Set<Int> = []
    var adjustedIngredients: [Ingredient] = []
    var uncheckedIngredientsAmount: Int = 0
    var shareContent: String = ""
    
    // Loading states
    var isLoading = false
    var errorMessage: String?
    
    init(interactor: RecipeDetailInteractorProtocol, router: RecipeDetailRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadRecipeDetails(_ recipe: Recipe) {
        self.recipe = recipe
        self.adjustedServings = recipe.servingSize
        self.adjustedIngredients = recipe.ingredients
        self.isFavorite = AppState.shared.favoriteRecipes.contains(recipe.id)
        self.shareContent = generateShareContent(for: recipe)
        
        interactor.loadRecipeDetails(recipe.id)
    }
    
    @MainActor
    func toggleFavorite() {
        guard let recipe = recipe else { return }
        
        // Optimistic update for immediate UI feedback
        isFavorite.toggle()
        
        // Delegate to business logic layer
        interactor.toggleFavorite(recipeId: recipe.id, isFavorite: isFavorite)
    }
    
    func adjustServings(to newServings: Int) {
        guard let recipe = recipe, newServings > 0 else { return }
        
        adjustedServings = newServings
        let multiplier = Double(newServings) / Double(recipe.servingSize)
        
        adjustedIngredients = recipe.ingredients.map { ingredient in
            var adjustedIngredient = ingredient
            adjustedIngredient.amount = ingredient.amount * multiplier
            return adjustedIngredient
        }
    }
    
    func toggleIngredientCheck(_ ingredientId: UUID) {
        if checkedIngredients.contains(ingredientId) {
            checkedIngredients.remove(ingredientId)
        } else {
            checkedIngredients.insert(ingredientId)
        }
    }
    
    func toggleStepCompletion(_ stepIndex: Int) {
        if completedSteps.contains(stepIndex) {
            completedSteps.remove(stepIndex)
        } else {
            completedSteps.insert(stepIndex)
        }
    }
    
    @MainActor
    func addIngredientsToShoppingList() {
        guard let recipe = recipe else { return }
        
        // Filter out checked ingredients - only add unchecked ones
        let uncheckedIngredients = adjustedIngredients.filter { ingredient in
            !checkedIngredients.contains(ingredient.id)
        }
        // Only proceed if there are unchecked ingredients to add
        guard !uncheckedIngredients.isEmpty else { return }
        
        self.uncheckedIngredientsAmount = uncheckedIngredients.count
        
        // Delegate to business logic layer - no direct AppState manipulation
        interactor.addIngredientsToShoppingList(ingredients: uncheckedIngredients, recipeId: recipe.id)
    }
    
    func showMealPlanPicker() async {
        await router.showMealPlanPicker()
    }
    
    @MainActor
    func addToWantToday() {
        guard let recipe = recipe else { return }
        
        // Create a new planned meal for today with "want today" set to true
        let todayMeal = PlannedMeal(
            recipeId: recipe.id,
            recipeName: recipe.title,
            mealType: .lunch, // Default to lunch, user can adjust later
            scheduledDate: Date(),
            servings: adjustedServings
        )
        
        // Delegate to business logic layer
        interactor.addToWantToday(recipeId: recipe.id, meal: todayMeal)
    }
    
    func duplicateRecipe() {
        guard let recipe = recipe else { return }
        interactor.duplicateRecipe(recipe)
    }
    
    func startCookingMode() async {
        guard let recipe = recipe else { return }
        await router.navigateToCookingMode(recipe)
    }
    
    private func generateShareContent(for recipe: Recipe) -> String {
        let ingredients = recipe.ingredients.map { "• \($0.amount) \($0.unit) \($0.name)" }.joined(separator: "\n")
        let instructions = recipe.instructions.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        
        return """
        \(recipe.title)
        
        \(recipe.countryOfOrigin.flag) From \(recipe.countryOfOrigin.rawValue)
        
        Serves: \(recipe.servingSize)
        Prep: \(formatTime(recipe.prepTime)) | Cook: \(formatTime(recipe.cookingTime))
        
        \(recipe.description)
        
        Ingredients:
        \(ingredients)
        
        Instructions:
        \(instructions)
        
        Shared from CookBook Pro
        """
    }
    
    private func formatTime(_ minutes: Double) -> String {
        let totalMinutes = Int(minutes)
        
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
}

// MARK: - VIP Protocol Implementations
protocol RecipeDetailInteractorProtocol {
    var presenter: RecipeDetailPresenterProtocol? { get set }
    
    func loadRecipeDetails(_ recipeId: UUID)
    func toggleFavorite(recipeId: UUID, isFavorite: Bool)
    func addIngredientsToShoppingList(ingredients: [Ingredient], recipeId: UUID)
    func addToWantToday(recipeId: UUID, meal: PlannedMeal)
    func duplicateRecipe(_ recipe: Recipe)
}

class RecipeDetailInteractor: RecipeDetailInteractorProtocol {
    var presenter: RecipeDetailPresenterProtocol?
    private let worker: RecipeDetailWorkerProtocol
    
    init(worker: RecipeDetailWorkerProtocol = RecipeDetailWorker()) {
        self.worker = worker
    }
    
    func loadRecipeDetails(_ recipeId: UUID) {
        Task {
            do {
                let recipe = try await worker.fetchRecipeDetails(recipeId)
                await presenter?.presentRecipeDetails(recipe)
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
    
    func toggleFavorite(recipeId: UUID, isFavorite: Bool) {
        Task {
            do {
                try await worker.updateFavoriteStatus(recipeId: recipeId, isFavorite: isFavorite)
                await presenter?.presentFavoriteToggled(isFavorite: isFavorite)
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
    
    func addIngredientsToShoppingList(ingredients: [Ingredient], recipeId: UUID) {
        Task {
            do {
                try await worker.addIngredientsToShoppingList(ingredients: ingredients, recipeId: recipeId)
                await presenter?.presentIngredientsAddedToShoppingList()
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
    
    func addToWantToday(recipeId: UUID, meal: PlannedMeal) {
        Task {
            do {
                try await worker.addToWantToday(recipeId: recipeId, meal: meal)
                await presenter?.presentAddedToWantToday()
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
    
    func duplicateRecipe(_ recipe: Recipe) {
        Task {
            do {
                let duplicatedRecipe = try await worker.duplicateRecipe(recipe)
                await presenter?.presentRecipeDuplicated(duplicatedRecipe)
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
}

@MainActor
protocol RecipeDetailPresenterProtocol {
    var viewModel: RecipeDetailViewModel? { get set }
    
    func presentRecipeDetails(_ recipe: Recipe) async
    func presentFavoriteToggled(isFavorite: Bool) async
    func presentIngredientsAddedToShoppingList() async
    func presentAddedToWantToday() async
    func presentRecipeDuplicated(_ recipe: Recipe) async
    func presentError(_ message: String) async
}

@MainActor
class RecipeDetailPresenter: RecipeDetailPresenterProtocol {
    weak var viewModel: RecipeDetailViewModel?
    
    func presentRecipeDetails(_ recipe: Recipe) async {
        // Recipe details are already loaded in the view model
        // This could be used for additional processing or analytics
    }
    
    func presentFavoriteToggled(isFavorite: Bool) async {
        // Could show a toast or update UI feedback
    }
    
    func presentIngredientsAddedToShoppingList() async {
        // Could show success feedback
    }
    
    func presentAddedToWantToday() async {
        // Could show success feedback or navigate to Today tab
    }
    
    func presentRecipeDuplicated(_ recipe: Recipe) async {
        // Navigate to the duplicated recipe or show success message
    }
    
    func presentError(_ message: String) async {
        viewModel?.errorMessage = message
    }
}

@MainActor
protocol RecipeDetailRouterProtocol {
    func navigateToCookingMode(_ recipe: Recipe) async
    func showMealPlanPicker() async
    func navigateToEditRecipe(_ recipe: Recipe) async
}

class RecipeDetailRouter: RecipeDetailRouterProtocol {
    weak var viewController: UIViewController?
    
    // MARK: - Static Factory Method
    @MainActor
    static func createModule(for recipe: Recipe) -> RecipeDetailView {
        let interactor = RecipeDetailInteractor()
        let presenter = RecipeDetailPresenter()
        let router = RecipeDetailRouter()
        
        let viewModel = RecipeDetailViewModel(
            interactor: interactor,
            router: router
        )
        
        // Set up VIP dependencies
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        return RecipeDetailView(recipe: recipe, viewModel: viewModel)
    }
    
    @MainActor
    func navigateToCookingMode(_ recipe: Recipe) {
        // Navigation coordination - delegate to app coordinator
        // In a real app, this would use a proper coordinator pattern
        AppState.shared.selectedRecipe = recipe
    }
    
    @MainActor
    func showMealPlanPicker() {
        // Show meal plan picker - delegate to app coordinator
        AppState.shared.presentedSheets.insert(.mealPlanner)
    }
    
    @MainActor
    func navigateToEditRecipe(_ recipe: Recipe) {
        // Navigate to edit recipe - delegate to app coordinator
        AppState.shared.selectedRecipe = recipe
        AppState.shared.isShowingAddRecipe = true
    }
}

protocol RecipeDetailWorkerProtocol {
    func fetchRecipeDetails(_ recipeId: UUID) async throws -> Recipe
    func updateFavoriteStatus(recipeId: UUID, isFavorite: Bool) async throws
    func addIngredientsToShoppingList(ingredients: [Ingredient], recipeId: UUID) async throws
    func addToWantToday(recipeId: UUID, meal: PlannedMeal) async throws
    func duplicateRecipe(_ recipe: Recipe) async throws -> Recipe
}

class RecipeDetailWorker: RecipeDetailWorkerProtocol {
    @MainActor
    func fetchRecipeDetails(_ recipeId: UUID) async throws -> Recipe {
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        guard let recipe = AppState.shared.recipes.first(where: { $0.id == recipeId }) else {
            throw RecipeDetailError.recipeNotFound
        }
        
        return recipe
    }
    
    @MainActor
    func updateFavoriteStatus(recipeId: UUID, isFavorite: Bool) async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Update AppState after successful backend operation
        if isFavorite {
            AppState.shared.favoriteRecipes.insert(recipeId)
        } else {
            AppState.shared.favoriteRecipes.remove(recipeId)
        }
        
        // Update recipe in recipes array
        if let index = AppState.shared.recipes.firstIndex(where: { $0.id == recipeId }) {
            AppState.shared.recipes[index].isFavorite = isFavorite
        }
    }
    
    @MainActor
    func addIngredientsToShoppingList(ingredients: [Ingredient], recipeId: UUID) async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Update AppState after successful backend operation
        guard let recipe = AppState.shared.recipes.first(where: { $0.id == recipeId }) else { 
            throw RecipeDetailError.recipeNotFound 
        }
        
        AppState.shared.addIngredientsToShoppingCart(ingredients, from: recipe)
    }
    
    @MainActor
    func addToWantToday(recipeId: UUID, meal: PlannedMeal) async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Update AppState after successful backend operation
        AppState.shared.addMealToPlan(meal)
        AppState.shared.markWantToday(meal)
    }
    
    @MainActor
    func duplicateRecipe(_ recipe: Recipe) async throws -> Recipe {
        // Simulate API call
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        let duplicatedRecipe = Recipe(
            title: "\(recipe.title) (Copy)",
            description: recipe.description,
            images: recipe.images,
            ingredients: recipe.ingredients,
            instructions: recipe.instructions,
            category: recipe.category,
            difficulty: recipe.difficulty,
            cookingTime: recipe.cookingTime,
            prepTime: recipe.prepTime,
            servingSize: recipe.servingSize,
            nutritionalInfo: recipe.nutritionalInfo,
            tags: recipe.tags,
            rating: 0.0,
            reviews: [],
            createdBy: recipe.createdBy,
            isPublic: false,
            isFavorite: false,
            createdAt: Date(),
            updatedAt: Date(),
            countryOfOrigin: recipe.countryOfOrigin
        )
        
        AppState.shared.addRecipe(duplicatedRecipe)
        return duplicatedRecipe
    }
}

enum RecipeDetailError: LocalizedError {
    case recipeNotFound
    case networkError
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .recipeNotFound:
            return "Recipe not found"
        case .networkError:
            return "Network error occurred"
        case .invalidData:
            return "Invalid recipe data"
        }
    }
}
