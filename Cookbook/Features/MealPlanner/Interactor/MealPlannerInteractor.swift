//
//  MealPlannerInteractor.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

class MealPlannerInteractor: MealPlannerInteractorProtocol {
    var presenter: MealPlannerPresenterProtocol?
    private let worker: MealPlannerWorkerProtocol
    
    init(worker: MealPlannerWorkerProtocol = MealPlannerWorker()) {
        self.worker = worker
    }
    
    func loadMealPlan() {
        Task {
            do {
                let mealPlan = try await worker.fetchMealPlan()
                await presenter?.presentMealPlan(mealPlan)
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
}
