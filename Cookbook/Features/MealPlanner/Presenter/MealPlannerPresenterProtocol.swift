//
//  MealPlannerPresenterProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

@MainActor
protocol MealPlannerPresenterProtocol {
    var viewModel: MealPlannerViewModel? { get set }
    
    func presentMealPlan(_ mealPlan: MealPlan) async
    func presentError(_ message: String) async
}
