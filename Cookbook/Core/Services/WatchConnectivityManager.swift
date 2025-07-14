//
//  WatchConnectivityManager.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import WatchConnectivity
import SwiftUI

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isConnected = false
    @Published var todayMeals: [String] = [] // Temporarily simplified
    @Published var wantTodayMeals: [String] = [] // Temporarily simplified
    @Published var recipes: [String] = [] // Temporarily simplified
    @Published var shoppingItems: [String] = [] // Temporarily simplified
    @Published var activeTimers: [String] = [] // Temporarily simplified
    
    private var session: WCSession?
    @MainActor private var appState: AppState {
        return AppState.shared
    }
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
        }
    }
    
    func activateSession() {
        session?.activate()
        
        // Add detailed debugging
        DispatchQueue.main.async {
            if let session = self.session {
                print("📱 WatchConnectivity Status:")
                print("  - isSupported: \(WCSession.isSupported())")
                print("  - activationState: \(session.activationState.rawValue)")
                print("  - isPaired: \(session.isPaired)")
                print("  - isWatchAppInstalled: \(session.isWatchAppInstalled)")
                print("  - isReachable: \(session.isReachable)")
                print("  - isConnected: \(self.isConnected)")
            }
        }
        
        // Send initial data to Watch when session activates
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.isConnected {
                print("📱 Auto-syncing data to Watch...")
                self.syncDataToWatch()
            } else {
                print("📱 Watch not connected, skipping auto-sync")
            }
        }
    }
    
    // MARK: - Data Synchronization
    func syncDataToWatch() {
        guard let session = session, session.isPaired && session.isWatchAppInstalled else {
            print("Watch not paired or app not installed")
            return
        }
        
        // Prepare data for Watch
        Task { @MainActor in
            let watchData = prepareWatchData()
            
            // Send via application context for background updates
            do {
                try session.updateApplicationContext(watchData)
                print("Data synced to Watch via application context")
            } catch {
                print("Error syncing data to Watch: \(error.localizedDescription)")
            }
            
            // Also try direct message if reachable
            if session.isReachable {
                session.sendMessage(watchData, replyHandler: { response in
                    print("Watch data sync confirmed: \(response)")
                }) { error in
                    print("Error sending direct message to Watch: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func prepareWatchData() -> [String: Any] {
        // Convert app data to Watch-friendly format
        let watchRecipes = appState.recipes.prefix(20).map { recipe in
            [
                "id": recipe.id.uuidString,
                "title": recipe.title,
                "cookingTime": recipe.cookingTime + recipe.prepTime,
                "difficulty": recipe.difficulty.rawValue
            ]
        }
        
        let watchTodayMeals = appState.todayMeals.map { meal in
            [
                "id": meal.id.uuidString,
                "recipeName": meal.recipeName,
                "mealType": meal.mealType.rawValue,
                "recipeId": meal.recipeId.uuidString
            ]
        }
        
        let watchWantTodayMeals = appState.wantTodayMeals.map { meal in
            [
                "id": meal.id.uuidString,
                "recipeName": meal.recipeName,
                "mealType": meal.mealType.rawValue,
                "recipeId": meal.recipeId.uuidString
            ]
        }
        
        let watchShoppingItems = appState.shoppingCart.items.map { item in
            [
                "id": item.id.uuidString,
                "name": item.ingredient.name,
                "quantity": "\(item.ingredient.formattedAmount) \(item.ingredient.unit.rawValue)",
                "isCompleted": item.isCompleted
            ]
        }
        
        return [
            "recipes": watchRecipes,
            "todayMeals": watchTodayMeals,
            "wantTodayMeals": watchWantTodayMeals,
            "shoppingItems": watchShoppingItems,
            "activeTimers": [] // Will be implemented with cooking mode
        ]
    }
    
    // MARK: - Send Messages to iPhone
    func startCookingMode(recipeId: UUID) {
        guard let session = session, session.isReachable else { return }
        
        let message = [
            "action": "startCookingMode",
            "recipeId": recipeId.uuidString
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending cooking mode message: \(error.localizedDescription)")
        }
    }
    
    func toggleShoppingItem(itemId: UUID) {
        guard let session = session, session.isReachable else { return }
        
        let message = [
            "action": "toggleShoppingItem",
            "itemId": itemId.uuidString
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error toggling shopping item: \(error.localizedDescription)")
        }
    }
    
    func markWantToday(recipeId: UUID) {
        guard let session = session, session.isReachable else { return }
        
        let message = [
            "action": "markWantToday",
            "recipeId": recipeId.uuidString
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error marking want today: \(error.localizedDescription)")
        }
    }
    
    func requestRandomRecipe() {
        guard let session = session, session.isReachable else { return }
        
        let message = ["action": "randomRecipe"]
        
        session.sendMessage(message, replyHandler: { response in
            // Handle random recipe response
        }) { error in
            print("Error requesting random recipe: \(error.localizedDescription)")
        }
    }
    
    func requestDataSync() {
        guard let session = session, session.isReachable else { return }
        
        let message = ["action": "syncData"]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error requesting data sync: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Send Application Context (for background updates)
    func sendApplicationContext(_ context: [String: Any]) {
        guard let session = session else { return }
        
        do {
            try session.updateApplicationContext(context)
        } catch {
            print("Error sending application context: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
        }
        
        if let error = error {
            print("Watch connectivity activation error: \(error.localizedDescription)")
        } else {
            print("Watch connectivity activated successfully")
            // Send initial data sync
            syncDataToWatch()
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch session deactivated")
        session.activate()
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from counterpart: \(message)")
        
        Task { @MainActor in
            self.handleReceivedMessage(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Received message with reply handler: \(message)")
        
        Task { @MainActor in
            self.handleReceivedMessage(message)
            replyHandler(["status": "received"])
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Received application context: \(applicationContext)")
        
        Task { @MainActor in
            self.handleApplicationContext(applicationContext)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("Received user info: \(userInfo)")
        
        Task { @MainActor in
            self.handleUserInfo(userInfo)
        }
    }
    
    // MARK: - Message Handling
    @MainActor
    private func handleReceivedMessage(_ message: [String: Any]) {
        guard let action = message["action"] as? String else { return }
        
        print("📱 iPhone received action from Watch: \(action)")
        
        switch action {
        case "startCookingMode":
            handleStartCookingMode(message)
        case "markWantToday":
            handleMarkWantToday(message)
        case "toggleShoppingItem":
            handleToggleShoppingItem(message)
        case "requestRandomRecipe":
            handleRequestRandomRecipe(message)
        case "syncData":
            handleDataSyncRequest()
        default:
            print("Unknown action received from Watch: \(action)")
        }
    }
    
    @MainActor
    private func handleStartCookingMode(_ message: [String: Any]) {
        guard let recipeIdString = message["recipeId"] as? String,
              let recipeId = UUID(uuidString: recipeIdString) else { return }
        
        print("🍳 Starting cooking mode for recipe: \(recipeId)")
        
        // Find the recipe
        if let recipe = appState.recipes.first(where: { $0.id == recipeId }) {
            // You could trigger navigation to cooking mode here
            // For now, just print confirmation
            print("🍳 Found recipe: \(recipe.title)")
            
            // Send confirmation back to Watch
            sendConfirmationToWatch(action: "cookingModeStarted", recipeName: recipe.title)
            
            // Trigger local notification as feedback
            Task {
                await NotificationManager.shared.requestAuthorization()
                NotificationManager.shared.scheduleLocalNotification(
                    id: "cooking_mode_\(recipeId)",
                    title: "🍳 Cooking Mode Started",
                    body: "Now cooking: \(recipe.title)",
                    timeInterval: 1
                )
            }
        }
    }
    
    @MainActor
    private func handleMarkWantToday(_ message: [String: Any]) {
        guard let recipeIdString = message["recipeId"] as? String,
              let recipeId = UUID(uuidString: recipeIdString) else { return }
        
        print("⏰ Watch wants to cook recipe: \(recipeId)")
        
        // Find the recipe
        if let recipe = appState.recipes.first(where: { $0.id == recipeId }) {
            // Create a new planned meal for today
            let todayMeal = PlannedMeal(
                recipeId: recipe.id,
                recipeName: recipe.title,
                mealType: .lunch, // Default to lunch
                scheduledDate: Date(),
                servings: recipe.servingSize
            )
            
            appState.addMealToPlan(todayMeal)
            appState.markWantToday(todayMeal)
            
            print("⏰ Added to want today from Watch: \(recipe.title)")
            
            // Send confirmation back to Watch
            sendConfirmationToWatch(action: "wantTodayAdded", recipeName: recipe.title)
            
            // Sync updated data back to Watch
            syncDataToWatch()
            
            // Create detailed notification about the recipe choice
            Task {
                await NotificationManager.shared.requestAuthorization()
                
                // Main notification
                NotificationManager.shared.scheduleLocalNotification(
                    id: "watch_wants_to_cook_\(recipeId)",
                    title: "🍳 Recipe Selected on Apple Watch",
                    body: "You chose \(recipe.title) on your Watch! Ready to start cooking?",
                    timeInterval: 1
                )
                
                // Follow-up reminder notification
                NotificationManager.shared.scheduleLocalNotification(
                    id: "cooking_reminder_\(recipeId)",
                    title: "👨‍🍳 Ready to Cook?",
                    body: "\(recipe.title) is waiting for you! Estimated time: \(recipe.formattedTotalTime)",
                    timeInterval: 30 // 30 seconds later
                )
            }
            
            // Add some visual feedback on iPhone too
            DispatchQueue.main.async {
                // This could trigger a toast or banner in your app if it's open
                print("📱 iPhone: Recipe \(recipe.title) selected from Watch!")
            }
        }
    }
    
    @MainActor
    private func handleToggleShoppingItem(_ message: [String: Any]) {
        guard let itemIdString = message["itemId"] as? String,
              let itemId = UUID(uuidString: itemIdString) else { return }
        
        print("🛒 Toggling shopping item: \(itemId)")
        
        // Find and toggle the shopping item
        if let itemIndex = appState.shoppingCart.items.firstIndex(where: { $0.id == itemId }) {
            appState.shoppingCart.items[itemIndex].isCompleted.toggle()
            let item = appState.shoppingCart.items[itemIndex]
            
            print("🛒 Toggled item: \(item.ingredient.name) - completed: \(item.isCompleted)")
            
            // Send confirmation back to Watch
            sendConfirmationToWatch(action: "shoppingItemToggled", recipeName: item.ingredient.name)
            
            // Sync updated data back to Watch
            syncDataToWatch()
        }
    }
    
    @MainActor
    private func handleRequestRandomRecipe(_ message: [String: Any]) {
        print("🎲 Random recipe requested from Watch")
        
        if let randomRecipe = appState.recipes.randomElement() {
            print("🎲 Selected random recipe: \(randomRecipe.title)")
            
            // Send the random recipe back to Watch
            guard let session = session, session.isReachable else { return }
            
            let response: [String: Any] = [
                "action": "randomRecipeResponse",
                "recipe": [
                    "id": randomRecipe.id.uuidString,
                    "title": randomRecipe.title,
                    "cookingTime": randomRecipe.cookingTime + randomRecipe.prepTime,
                    "difficulty": randomRecipe.difficulty.rawValue
                ]
            ]
            
            session.sendMessage(response, replyHandler: nil) { error in
                print("Error sending random recipe: \(error.localizedDescription)")
            }
            
            // Trigger engaging notification on iPhone
            Task {
                await NotificationManager.shared.requestAuthorization()
                NotificationManager.shared.scheduleLocalNotification(
                    id: "random_recipe_suggestion",
                    title: "🎲 Your Watch Picked a Recipe!",
                    body: "How about cooking \(randomRecipe.title)? It takes about \(randomRecipe.formattedTotalTime) and is \(randomRecipe.difficulty.rawValue.lowercased()) to make!",
                    timeInterval: 1
                )
                
                // Optional: Auto-add to want today
                let suggestedMeal = PlannedMeal(
                    recipeId: randomRecipe.id,
                    recipeName: randomRecipe.title,
                    mealType: .lunch,
                    scheduledDate: Date(),
                    servings: randomRecipe.servingSize
                )
                
                // Safely update main actor from main actor context
                appState.addMealToPlan(suggestedMeal)
                appState.markWantToday(suggestedMeal)
                
                // Sync the updated data back to Watch
                syncDataToWatch()
                
                // Follow-up notification with action
                NotificationManager.shared.scheduleLocalNotification(
                    id: "random_recipe_action",
                    title: "🍳 Ready to Start?",
                    body: "\(randomRecipe.title) has been added to your Want Today list. Tap to open the app!",
                    timeInterval: 5
                )
            }
        } else {
            // No recipes available
            Task {
                await NotificationManager.shared.requestAuthorization()
                NotificationManager.shared.scheduleLocalNotification(
                    id: "no_recipes_available",
                    title: "🤔 No Recipes Found",
                    body: "Add some recipes to your collection first!",
                    timeInterval: 1
                )
            }
        }
    }
    
    private func handleDataSyncRequest() {
        print("🔄 Data sync requested from Watch")
        syncDataToWatch()
    }
    
    private func sendConfirmationToWatch(action: String, recipeName: String) {
        guard let session = session, session.isReachable else { return }
        
        let confirmation = [
            "action": action,
            "recipeName": recipeName,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]
        
        session.sendMessage(confirmation, replyHandler: nil) { error in
            print("Error sending confirmation to Watch: \(error.localizedDescription)")
        }
    }
    
    private func handleApplicationContext(_ context: [String: Any]) {
        // Handle background data updates
        print("📱 iPhone received application context: \(context)")
        syncDataToWatch()
    }
    
    private func handleUserInfo(_ userInfo: [String: Any]) {
        // Handle specific data transfers
        print("📱 iPhone received user info: \(userInfo)")
        handleApplicationContext(userInfo)
    }
}

