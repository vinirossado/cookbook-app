//
//  MealPlannerWorker.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

class MealPlannerWorker: MealPlannerWorkerProtocol {
    @MainActor
    func fetchMealPlan() async throws -> MealPlan {
        // Simulate API call
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        return AppState.shared.currentMealPlan ?? MealPlan(startDate: Date(), endDate: Date())
    }
}
