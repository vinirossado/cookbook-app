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
}

// MARK: - VIP Protocol Implementations
protocol ShoppingInteractorProtocol {
    var presenter: ShoppingPresenterProtocol? { get set }
    
    func loadShoppingCart()
}

class ShoppingInteractor: ShoppingInteractorProtocol {
    var presenter: ShoppingPresenterProtocol?
    private let worker: ShoppingWorkerProtocol
    
    init(worker: ShoppingWorkerProtocol = ShoppingWorker()) {
        self.worker = worker
    }
    
    func loadShoppingCart() {
        Task {
            do {
                let cart = try await worker.fetchShoppingCart()
                await presenter?.presentShoppingCart(cart)
            } catch {
                await presenter?.presentError(error.localizedDescription)
            }
        }
    }
}

@MainActor
protocol ShoppingPresenterProtocol {
    var viewModel: ShoppingViewModel? { get set }
    
    func presentShoppingCart(_ cart: ShoppingCart) async
    func presentError(_ message: String) async
}

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

protocol ShoppingWorkerProtocol {
    func fetchShoppingCart() async throws -> ShoppingCart
}

class ShoppingWorker: ShoppingWorkerProtocol {
    @MainActor
    func fetchShoppingCart() async throws -> ShoppingCart {
        // Simulate API call
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        return AppState.shared.shoppingCart
    }
}
