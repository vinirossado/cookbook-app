//
//  ShoppingInteractorProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

protocol ShoppingInteractorProtocol {
    var presenter: ShoppingPresenterProtocol? { get set }
    
    func loadShoppingCart()
}
