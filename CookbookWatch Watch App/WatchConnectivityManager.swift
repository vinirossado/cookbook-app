//
//  WatchConnectivityManager.swift
//  CookbookWatch Watch App
//
//  Created by Vinicius Rossado on 09/07/2025.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var recipes: [WatchRecipe] = []
    @Published var todayMeals: [WatchMeal] = []
    @Published var wantTodayMeals: [WatchMeal] = []
    @Published var shoppingItems: [WatchShoppingItem] = []
    @Published var activeTimers: [WatchTimer] = []
    @Published var isConnected = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
        }
        
        // Load mock data for preview/testing
        loadMockData()
    }
    
    func activateSession() {
        guard WCSession.isSupported() else { return }
        
        let session = WCSession.default
        session.activate()
    }
    
    // MARK: - Actions
    func startCookingMode(recipeId: UUID) {
        sendMessage([
            "action": "startCookingMode",
            "recipeId": recipeId.uuidString
        ])
    }
    
    func markWantToday(recipeId: UUID) {
        sendMessage([
            "action": "markWantToday",
            "recipeId": recipeId.uuidString
        ])
    }
    
    func toggleShoppingItem(itemId: UUID) {
        sendMessage([
            "action": "toggleShoppingItem",
            "itemId": itemId.uuidString
        ])
    }
    
    func requestRandomRecipe() {
        sendMessage([
            "action": "requestRandomRecipe"
        ])
    }
    
    private func sendMessage(_ message: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    private func loadMockData() {
        // Mock recipes
        recipes = [
            WatchRecipe(id: UUID(), title: "Pancakes", cookingTime: 15, difficulty: "Easy"),
            WatchRecipe(id: UUID(), title: "Pasta Carbonara", cookingTime: 20, difficulty: "Medium"),
            WatchRecipe(id: UUID(), title: "Chocolate Cake", cookingTime: 45, difficulty: "Hard")
        ]
        
        // Mock today meals
        todayMeals = [
            WatchMeal(id: UUID(), recipeName: "Breakfast Pancakes", mealType: "Breakfast", recipeId: recipes[0].id)
        ]
        
        // Mock shopping items
        shoppingItems = [
            WatchShoppingItem(id: UUID(), name: "Milk", quantity: "1L", isCompleted: false),
            WatchShoppingItem(id: UUID(), name: "Eggs", quantity: "12", isCompleted: true),
            WatchShoppingItem(id: UUID(), name: "Flour", quantity: "500g", isCompleted: false)
        ]
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleReceivedMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleReceivedMessage(applicationContext)
    }
    
    private func handleReceivedMessage(_ message: [String: Any]) {
        DispatchQueue.main.async {
            // Handle incoming data from iPhone
            if let recipesData = message["recipes"] as? Data,
               let decodedRecipes = try? JSONDecoder().decode([WatchRecipe].self, from: recipesData) {
                self.recipes = decodedRecipes
            }
            
            if let mealsData = message["todayMeals"] as? Data,
               let decodedMeals = try? JSONDecoder().decode([WatchMeal].self, from: mealsData) {
                self.todayMeals = decodedMeals
            }
            
            if let shoppingData = message["shoppingItems"] as? Data,
               let decodedItems = try? JSONDecoder().decode([WatchShoppingItem].self, from: shoppingData) {
                self.shoppingItems = decodedItems
            }
            
            if let timersData = message["activeTimers"] as? Data,
               let decodedTimers = try? JSONDecoder().decode([WatchTimer].self, from: timersData) {
                self.activeTimers = decodedTimers
            }
        }
    }
}
