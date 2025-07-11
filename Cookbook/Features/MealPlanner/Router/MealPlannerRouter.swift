//
//  MealPlannerRouter.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import SwiftUI

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
