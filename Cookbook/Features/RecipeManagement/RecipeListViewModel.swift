//
//  RecipeListViewModel.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation

@MainActor
@Observable
class RecipeListViewModel {
    private let interactor: RecipeInteractorProtocol
    private let router: RecipeRouterProtocol
    
    // State
    var isLoading = false
    var errorMessage: String?
    
    init(interactor: RecipeInteractorProtocol, router: RecipeRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadRecipes() {
        interactor.loadRecipes()
    }
    
    func refreshRecipes() {
        interactor.refreshRecipes()
    }
    
    func navigateToRecipeDetail(_ recipe: Recipe) {
        router.navigateToRecipeDetail(recipe: recipe)
    }
    
    func navigateToAddRecipe() {
        router.navigateToAddRecipe()
    }
}

// MARK: - VIP Protocol Implementations
protocol RecipeInteractorProtocol {
    var presenter: RecipePresenterProtocol? { get set }
    
    func loadRecipes()
    func refreshRecipes()
}

class RecipeInteractor: RecipeInteractorProtocol {
    var presenter: RecipePresenterProtocol?
    private let worker: RecipeWorkerProtocol
    
    init(worker: RecipeWorkerProtocol = RecipeWorker()) {
        self.worker = worker
    }
    
    func loadRecipes() {
        Task {
            do {
                let recipes = try await worker.fetchRecipes()
                await presenter?.presentRecipes(recipes)
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
    
    func refreshRecipes() {
        Task {
            do {
                let recipes = try await worker.refreshRecipes()
                await presenter?.presentRecipes(recipes)
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
}

@MainActor
protocol RecipePresenterProtocol {
    var viewModel: RecipeListViewModel? { get set }
    
    func presentRecipes(_ recipes: [Recipe]) async
    func presentError(_ message: String) async
}

@MainActor
class RecipePresenter: RecipePresenterProtocol {
    weak var viewModel: RecipeListViewModel?
    
    func presentRecipes(_ recipes: [Recipe]) async {
        viewModel?.isLoading = false
        // Recipes are managed by AppState, so no need to update viewModel directly
    }
    
    func presentError(_ message: String) async {
        viewModel?.isLoading = false
        viewModel?.errorMessage = message
    }
}

protocol RecipeWorkerProtocol {
    func fetchRecipes() async throws -> [Recipe]
    func refreshRecipes() async throws -> [Recipe]
}

class RecipeWorker: RecipeWorkerProtocol {
    @MainActor
    func fetchRecipes() async throws -> [Recipe] {
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return recipes from AppState (which could be from API/Database)
        return AppState.shared.recipes
    }
    
    @MainActor
    func refreshRecipes() async throws -> [Recipe] {
        // Simulate API refresh
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        // In a real app, this would fetch fresh data from the API
        // For now, return the current recipes
        return AppState.shared.recipes
    }
}

enum RecipeListError: LocalizedError {
    case loadingFailed
    case networkError
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .loadingFailed:
            return "Failed to load recipes"
        case .networkError:
            return "Network error occurred"
        case .invalidData:
            return "Invalid recipe data"
        }
    }
}
