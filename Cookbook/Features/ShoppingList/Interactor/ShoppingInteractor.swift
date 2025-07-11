//
//  ShoppingInteractor.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

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
