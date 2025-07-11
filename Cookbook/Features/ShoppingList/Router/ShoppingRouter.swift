//
//  ShoppingRouter.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import SwiftUI

class ShoppingRouter: ShoppingRouterProtocol {
    
    @MainActor
    static func createModule() -> AnyView {
        let interactor = ShoppingInteractor()
        let presenter = ShoppingPresenter()
        let router = ShoppingRouter()
        
        let viewModel = ShoppingViewModel(
            interactor: interactor,
            router: router
        )
        
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        let view = ShoppingListView(viewModel: viewModel)
        return AnyView(NavigationStack { view })
    }
    
    func navigateToRecipeDetail(recipeId: UUID) {
        // Navigation implementation
    }
    
    func shareShoppingList() {
        // Share functionality implementation
    }
}
