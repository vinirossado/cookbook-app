//
//  RecipeRouter.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

@MainActor
protocol RecipeRouterProtocol {
    func navigateToRecipeDetail(recipe: Recipe)
    func navigateToAddRecipe()
    func navigateToEditRecipe(recipe: Recipe)
    func navigateToSearch()
    func navigateToFilters()
}

class RecipeRouter: RecipeRouterProtocol {
    
    @MainActor
    static func createModule() -> AnyView {
        let interactor = RecipeInteractor()
        let presenter = RecipePresenter()
        let router = RecipeRouter()
        
        let viewModel = RecipeListViewModel(
            interactor: interactor,
            router: router
        )
        
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        let view = RecipeListView(viewModel: viewModel)
        return AnyView(NavigationStack { view })
    }
    
    func navigateToRecipeDetail(recipe: Recipe) {
        // Navigation handled by SwiftUI NavigationLink
    }
    
    func navigateToAddRecipe() {
        // Navigation handled by SwiftUI sheet presentation
    }
    
    func navigateToEditRecipe(recipe: Recipe) {
        // Navigation handled by SwiftUI sheet presentation
    }
    
    func navigateToSearch() {
        // Navigation handled by SwiftUI sheet presentation
    }
    
    func navigateToFilters() {
        // Navigation handled by SwiftUI sheet presentation
    }
}

// MARK: - Shopping Router
@MainActor
protocol ShoppingRouterProtocol {
    func navigateToRecipeDetail(recipeId: UUID)
    func shareShoppingList()
}

class ShoppingRouter: ShoppingRouterProtocol {
    
    @MainActor
    static func createModule() -> AnyView {
        let interactor = ShoppingInteractor()
        let presenter = ShoppingPresenter()
        let router = ShoppingRouter()
        
        let viewModel = ShoppingViewModel(
            interactor: interactor,
            router: router
        )
        
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        let view = ShoppingListView(viewModel: viewModel)
        return AnyView(NavigationStack { view })
    }
    
    func navigateToRecipeDetail(recipeId: UUID) {
        // Navigation implementation
    }
    
    func shareShoppingList() {
        // Share functionality implementation
    }
}

// MARK: - Meal Planner Router
@MainActor
protocol MealPlannerRouterProtocol {
    func navigateToRecipeSelection()
    func navigateToMealDetail(meal: PlannedMeal)
}

class MealPlannerRouter: MealPlannerRouterProtocol {
    
    @MainActor
    static func createModule() -> AnyView {
        let interactor = MealPlannerInteractor()
        let presenter = MealPlannerPresenter()
        let router = MealPlannerRouter()
        
        let viewModel = MealPlannerViewModel(
            interactor: interactor,
            router: router
        )
        
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        let view = MealPlannerView(viewModel: viewModel)
        return AnyView(NavigationStack { view })
    }
    
    func navigateToRecipeSelection() {
        // Navigation implementation
    }
    
    func navigateToMealDetail(meal: PlannedMeal) {
        // Navigation implementation
    }
}




