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
    @Published var suggestedRecipe: (title: String, id: UUID)? = nil
    @Published var showRecipeSuggestion = false
    
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
            
            if activationState == .activated {
                print("⌚ Watch connectivity activated successfully")
                print("⌚ WatchConnectivity Status:")
                print("  - activationState: \(activationState.rawValue)")
                print("  - isReachable: \(session.isReachable)")
                print("  - isConnected: \(self.isConnected)")
                
                // Request initial data sync from iPhone
                self.requestDataSync()
            }
        }
        
        if let error = error {
            print("⌚ Watch connectivity activation error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("⌚ Watch received message: \(message)")
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("⌚ Watch received application context: \(applicationContext)")
        DispatchQueue.main.async {
            self.updateDataFromMessage(applicationContext)
        }
    }
    
    // MARK: - Helper Methods
    private func requestDataSync() {
        sendMessage(["action": "syncData"])
    }
    
    private func handleReceivedMessage(_ message: [String: Any]) {
        print("⌚ Watch received message from iPhone: \(message.keys)")
        
        // Handle specific action responses
        if let action = message["action"] as? String {
            handleActionResponse(action, message: message)
        }
        
        // Handle data updates
        updateDataFromMessage(message)
    }
    
    private func handleActionResponse(_ action: String, message: [String: Any]) {
        switch action {
        case "cookingModeStarted":
            if let recipeName = message["recipeName"] as? String {
                print("⌚ Cooking mode started for: \(recipeName)")
                // Could show local notification on Watch
            }
        case "wantTodayAdded":
            if let recipeName = message["recipeName"] as? String {
                print("⌚ Want today added: \(recipeName)")
                // Could trigger haptic feedback or show confirmation
            }
        case "shoppingItemToggled":
            if let itemName = message["recipeName"] as? String {
                print("⌚ Shopping item toggled: \(itemName)")
            }
        case "randomRecipeResponse":
            if let recipeData = message["recipe"] as? [String: Any],
               let title = recipeData["title"] as? String,
               let idString = recipeData["id"] as? String,
               let id = UUID(uuidString: idString) {
                print("⌚ Random recipe received: \(title)")
                
                // Show user the recipe suggestion - let them decide
                DispatchQueue.main.async {
                    // Store the suggested recipe for user to act on
                    self.showRandomRecipeSuggestion(title: title, recipeId: id)
                }
            }
        default:
            print("⌚ Unknown action response: \(action)")
        }
    }
    
    private func updateDataFromMessage(_ message: [String: Any]) {
        // Handle recipes data
        if let recipesData = message["recipes"] as? [[String: Any]] {
            let newRecipes = recipesData.compactMap { recipeDict -> WatchRecipe? in
                guard let idString = recipeDict["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let title = recipeDict["title"] as? String,
                      let cookingTime = recipeDict["cookingTime"] as? Int,
                      let difficulty = recipeDict["difficulty"] as? String else {
                    return nil
                }
                return WatchRecipe(id: id, title: title, cookingTime: cookingTime, difficulty: difficulty)
            }
            
            if !newRecipes.isEmpty {
                self.recipes = newRecipes
                print("⌚ Updated \(newRecipes.count) recipes")
            }
        }
        
        // Handle today meals data
        if let mealsData = message["todayMeals"] as? [[String: Any]] {
            let newMeals = mealsData.compactMap { mealDict -> WatchMeal? in
                guard let idString = mealDict["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let recipeName = mealDict["recipeName"] as? String,
                      let mealType = mealDict["mealType"] as? String,
                      let recipeIdString = mealDict["recipeId"] as? String,
                      let recipeId = UUID(uuidString: recipeIdString) else {
                    return nil
                }
                return WatchMeal(id: id, recipeName: recipeName, mealType: mealType, recipeId: recipeId)
            }
            
            self.todayMeals = newMeals
            print("⌚ Updated \(newMeals.count) today meals")
        }
        
        // Handle want today meals data
        if let wantTodayData = message["wantTodayMeals"] as? [[String: Any]] {
            let newWantTodayMeals = wantTodayData.compactMap { mealDict -> WatchMeal? in
                guard let idString = mealDict["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let recipeName = mealDict["recipeName"] as? String,
                      let mealType = mealDict["mealType"] as? String,
                      let recipeIdString = mealDict["recipeId"] as? String,
                      let recipeId = UUID(uuidString: recipeIdString) else {
                    return nil
                }
                return WatchMeal(id: id, recipeName: recipeName, mealType: mealType, recipeId: recipeId)
            }
            
            self.wantTodayMeals = newWantTodayMeals
            print("⌚ Updated \(newWantTodayMeals.count) want today meals")
        }
        
        // Handle shopping items data
        if let shoppingData = message["shoppingItems"] as? [[String: Any]] {
            let newShoppingItems = shoppingData.compactMap { itemDict -> WatchShoppingItem? in
                guard let idString = itemDict["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let name = itemDict["name"] as? String,
                      let quantity = itemDict["quantity"] as? String,
                      let isCompleted = itemDict["isCompleted"] as? Bool else {
                    return nil
                }
                return WatchShoppingItem(id: id, name: name, quantity: quantity, isCompleted: isCompleted)
            }
            
            self.shoppingItems = newShoppingItems
            print("⌚ Updated \(newShoppingItems.count) shopping items")
        }
        
        // Handle active timers data
        if let timersData = message["activeTimers"] as? [[String: Any]] {
            // Will implement timer parsing when cooking mode is added
            print("⌚ Received timers data: \(timersData.count) timers")
        }
    }
}

// MARK: - Recipe Suggestion Handling
extension WatchConnectivityManager {
    private func showRandomRecipeSuggestion(title: String, recipeId: UUID) {
        suggestedRecipe = (title: title, id: recipeId)
        showRecipeSuggestion = true
        print("⌚ Showing recipe suggestion: \(title)")
    }
    
    func acceptRecipeSuggestion() {
        guard let suggested = suggestedRecipe else { return }
        markWantToday(recipeId: suggested.id)
        dismissRecipeSuggestion()
        print("⌚ User accepted recipe suggestion: \(suggested.title)")
    }
    
    func dismissRecipeSuggestion() {
        suggestedRecipe = nil
        showRecipeSuggestion = false
    }
}
