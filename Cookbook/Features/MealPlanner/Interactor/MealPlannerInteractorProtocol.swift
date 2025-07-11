//
//  MealPlannerInteractorProtocol.swift
//  Cookbook
//
//  Created by VIP Architecture on 11/07/2025.
//

import Foundation

protocol MealPlannerInteractorProtocol {
    var presenter: MealPlannerPresenterProtocol? { get set }
    
    func loadMealPlan()
}
