//
//  RecipeRouter.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

@MainActor
protocol RecipeRouterProtocol {
    func navigateToRecipeDetail(recipe: Recipe)
    func navigateToAddRecipe()
    func navigateToEditRecipe(recipe: Recipe)
    func navigateToSearch()
    func navigateToFilters()
}

class RecipeRouter: RecipeRouterProtocol {
    
    @MainActor
    static func createModule() -> AnyView {
        let interactor = RecipeInteractor()
        let presenter = RecipePresenter()
        let router = RecipeRouter()
        
        let viewModel = RecipeListViewModel(
            interactor: interactor,
            router: router
        )
        
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        let view = RecipeListView(viewModel: viewModel)
        return AnyView(NavigationStack { view })
    }
    
    func navigateToRecipeDetail(recipe: Recipe) {
        // Navigation handled by SwiftUI NavigationLink
    }
    
    func navigateToAddRecipe() {
        // Navigation handled by SwiftUI sheet presentation
    }
    
    func navigateToEditRecipe(recipe: Recipe) {
        // Navigation handled by SwiftUI sheet presentation
    }
    
    func navigateToSearch() {
        // Navigation handled by SwiftUI sheet presentation
    }
    
    func navigateToFilters() {
        // Navigation handled by SwiftUI sheet presentation
    }
}




