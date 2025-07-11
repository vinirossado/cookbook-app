//
//  ShoppingWorker.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

class ShoppingWorker: ShoppingWorkerProtocol {
    @MainActor
    func fetchShoppingCart() async throws -> ShoppingCart {
        // Simulate API call
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        return AppState.shared.shoppingCart
    }
}
