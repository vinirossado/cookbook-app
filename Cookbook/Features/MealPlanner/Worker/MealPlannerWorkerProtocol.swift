//
//  MealPlannerWorkerProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

protocol MealPlannerWorkerProtocol {
    func fetchMealPlan() async throws -> MealPlan
}
