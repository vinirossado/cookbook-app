//
//  MealPlannerPresenter.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

@MainActor
class MealPlannerPresenter: MealPlannerPresenterProtocol {
    weak var viewModel: MealPlannerViewModel?
    
    func presentMealPlan(_ mealPlan: MealPlan) async {
        viewModel?.isLoading = false
        // Meal plan is managed by AppState
    }
    
    func presentError(_ message: String) async {
        viewModel?.isLoading = false
        viewModel?.errorMessage = message
    }
}
