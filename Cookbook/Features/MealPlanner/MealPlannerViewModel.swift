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
}

// MARK: - VIP Protocol Implementations
protocol MealPlannerInteractorProtocol {
    var presenter: MealPlannerPresenterProtocol? { get set }
    
    func loadMealPlan()
}

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

@MainActor
protocol MealPlannerPresenterProtocol {
    var viewModel: MealPlannerViewModel? { get set }
    
    func presentMealPlan(_ mealPlan: MealPlan) async
    func presentError(_ message: String) async
}

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

protocol MealPlannerWorkerProtocol {
    func fetchMealPlan() async throws -> MealPlan
}

class MealPlannerWorker: MealPlannerWorkerProtocol {
    @MainActor
    func fetchMealPlan() async throws -> MealPlan {
        // Simulate API call
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        return AppState.shared.mealPlan
    }
}
