//
//  TodayRouter.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

@MainActor
protocol TodayRouterProtocol {
    func navigateToRecipeDetail(_ recipe: Recipe)
    func navigateToCookingMode(_ recipe: Recipe)
    func navigateToMealPlanner()
    func navigateToShoppingList()
    func navigateToFavorites()
    func navigateToRandomRecipe()
}

@MainActor
class TodayRouter: TodayRouterProtocol {
    weak var viewController: UIViewController?
    
    func navigateToRecipeDetail(_ recipe: Recipe) {
        // Navigate to recipe detail view
        AppState.shared.selectedRecipe = recipe
    }
    
    func navigateToCookingMode(_ recipe: Recipe) {
        // Navigate to cooking mode
        AppState.shared.selectedRecipe = recipe
    }
    
    func navigateToMealPlanner() {
        AppState.shared.selectedTab = .planner
    }
    
    func navigateToShoppingList() {
        AppState.shared.selectedTab = .shopping
    }
    
    func navigateToFavorites() {
        // Navigate to favorites view - switch to recipes tab and show favorites
        AppState.shared.selectedTab = .recipes
    }
    
    func navigateToRandomRecipe() {
        // Get random recipe and navigate
        if let randomRecipe = AppState.shared.recipes.randomElement() {
            AppState.shared.selectedRecipe = randomRecipe
        }
    }
}
