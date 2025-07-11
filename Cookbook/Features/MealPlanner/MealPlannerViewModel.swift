//
//  MealPlannerViewModel.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation

@MainActor
@Observable
class MealPlannerViewModel {
    private let interactor: MealPlannerInteractorProtocol
    private let router: MealPlannerRouterProtocol
    
    // State
    var isLoading = false
    var errorMessage: String?
    
    init(interactor: MealPlannerInteractorProtocol, router: MealPlannerRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadMealPlan() {
        interactor.loadMealPlan()
    }
    
    func navigateToRecipeSelection() {
        router.navigateToRecipeSelection()
    }
    
    func navigateToMealDetail(_ meal: PlannedMeal) {
        router.navigateToMealDetail(meal: meal)
    }
    
    // MARK: - Business Logic Functions
    func autoGenerateWeekPlan() {
        // Implementation for auto-generating week meal plan
    }
    
    func addWeekToShopping() {
        // Implementation for adding week's meals to shopping list
    }
    
    func showMealPrepGuide() {
        // Implementation for showing meal prep guide
    }
    
    func showNutritionGoals() {
        // Implementation for showing nutrition goals
    }
}
