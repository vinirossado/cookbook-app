//
//  ShoppingRouterProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

@MainActor
protocol ShoppingRouterProtocol {
    func navigateToRecipeDetail(recipeId: UUID)
    func shareShoppingList()
}
