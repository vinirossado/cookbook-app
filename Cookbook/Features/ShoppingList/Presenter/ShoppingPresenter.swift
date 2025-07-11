//
//  ShoppingPresenter.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

@MainActor
class ShoppingPresenter: ShoppingPresenterProtocol {
    weak var viewModel: ShoppingViewModel?
    
    func presentShoppingCart(_ cart: ShoppingCart) async {
        viewModel?.isLoading = false
        // Shopping cart is managed by AppState
    }
    
    func presentError(_ message: String) async {
        viewModel?.isLoading = false
        viewModel?.errorMessage = message
    }
}
