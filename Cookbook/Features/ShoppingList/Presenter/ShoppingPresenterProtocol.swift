//
//  ShoppingPresenterProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

@MainActor
protocol ShoppingPresenterProtocol {
    var viewModel: ShoppingViewModel? { get set }
    
    func presentShoppingCart(_ cart: ShoppingCart) async
    func presentError(_ message: String) async
}
