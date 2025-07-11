//
//  MealPlannerRouterProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

@MainActor
protocol MealPlannerRouterProtocol {
    func navigateToRecipeSelection()
    func navigateToMealDetail(meal: PlannedMeal)
}
