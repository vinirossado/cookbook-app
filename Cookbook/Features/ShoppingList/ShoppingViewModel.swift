//
//  ShoppingViewModel.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation

@MainActor
@Observable
class ShoppingViewModel {
    private let interactor: ShoppingInteractorProtocol
    private let router: ShoppingRouterProtocol
    
    // State
    var isLoading = false
    var errorMessage: String?
    
    init(interactor: ShoppingInteractorProtocol, router: ShoppingRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadShoppingCart() {
        interactor.loadShoppingCart()
    }
    
    func shareShoppingList() {
        router.shareShoppingList()
    }
    
    // MARK: - Business Logic Functions
    func clearCompleted() {
        AppState.shared.clearCompletedShoppingItems()
    }
    
    func clearAll() {
        AppState.shared.clearShoppingCart()
    }
    
    func addFromRecentRecipes() {
        // Implementation to add ingredients from recently viewed recipes
    }
    
    func suggestFromMealPlan() {
        // Implementation to suggest ingredients based on meal plan
    }
    
    func generateShoppingListText() -> String {
        let cart = AppState.shared.shoppingCart
        var text = "🛒 Shopping List\n\n"
        
        let grouped = Dictionary(grouping: cart.items) { $0.ingredient.category }
        
        for category in grouped.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            text += "\(category.rawValue):\n"
            for item in grouped[category] ?? [] {
                let checkbox = item.isCompleted ? "☑️" : "☐"
                text += "\(checkbox) \(item.ingredient.displayText)\n"
            }
            text += "\n"
        }
        
        return text
    }
}
