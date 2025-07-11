//
//  ShoppingWorkerProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

protocol ShoppingWorkerProtocol {
    func fetchShoppingCart() async throws -> ShoppingCart
}
