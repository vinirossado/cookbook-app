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
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
        }
    }
    
    func activateSession() {
        session?.activate()
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
        
        // Optimistically update UI - temporarily disabled due to type mismatch
        // if let index = shoppingItems.firstIndex(where: { $0 == itemId }) {
        //     // Temporarily commented out due to Watch model issues
        //     // shoppingItems[index] = WatchShoppingItem(
        //     //     id: shoppingItems[index].id,
        //     //     name: shoppingItems[index].name,  
        //     //     quantity: shoppingItems[index].quantity,
        //     //     isCompleted: !shoppingItems[index].isCompleted
        //     // )
        // }
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
            // Request initial data sync
            requestDataSync()
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
        
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Received message with reply handler: \(message)")
        
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
            replyHandler(["status": "received"])
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Received application context: \(applicationContext)")
        
        DispatchQueue.main.async {
            self.handleApplicationContext(applicationContext)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("Received user info: \(userInfo)")
        
        DispatchQueue.main.async {
            self.handleUserInfo(userInfo)
        }
    }
    
    // MARK: - Message Handling
    private func handleReceivedMessage(_ message: [String: Any]) {
        guard let action = message["action"] as? String else { return }
        
        switch action {
        case "dataUpdate":
            handleDataUpdate(message)
        case "timerUpdate":
            handleTimerUpdate(message)
        case "cookingModeStarted":
            handleCookingModeStarted(message)
        default:
            print("Unknown action received: \(action)")
        }
    }
    
    private func handleApplicationContext(_ context: [String: Any]) {
        // Temporarily simplified - Watch integration disabled
        print("Watch application context received: \(context)")
    }
    
    private func handleUserInfo(_ userInfo: [String: Any]) {
        // Handle specific data transfers
        handleApplicationContext(userInfo)
    }
    
    private func handleDataUpdate(_ message: [String: Any]) {
        if message["todayMeals"] is [[String: Any]] {
            // todayMeals = todayMealsData.compactMap { WatchMeal.from($0) }
            print("Today meals update received")
        }
        
        if message["wantTodayMeals"] is [[String: Any]] {
            // wantTodayMeals = wantTodayMealsData.compactMap { WatchMeal.from($0) }
            print("Want today meals update received")
        }
        
        if message["shoppingItems"] is [[String: Any]] {
            // shoppingItems = shoppingItemsData.compactMap { WatchShoppingItem.from($0) }
            print("Shopping items update received")
        }
        
        if message["recipes"] is [[String: Any]] {
            // recipes = recipesData.compactMap { WatchRecipe.from($0) }
            print("Recipes update received")
        }
    }
    
    private func handleTimerUpdate(_ message: [String: Any]) {
        // Temporarily simplified - Watch integration disabled
        print("Watch timer update received: \(message)")
    }
    
    private func handleCookingModeStarted(_ message: [String: Any]) {
        // Handle cooking mode started notification
        if let recipeName = message["recipeName"] as? String {
            // Could show a notification or update UI
            print("Cooking mode started for: \(recipeName)")
        }
    }
}

// MARK: - Data Model Extensions
// MARK: - Temporarily commented out Watch model extensions
/*
extension WatchMeal {
    static func from(_ dict: [String: Any]) -> WatchMeal? {
        guard 
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let recipeName = dict["recipeName"] as? String,
            let mealType = dict["mealType"] as? String,
            let recipeIdString = dict["recipeId"] as? String,
            let recipeId = UUID(uuidString: recipeIdString)
        else { return nil }
        
        return WatchMeal(
            id: id,
            recipeName: recipeName,
            mealType: mealType,
            recipeId: recipeId
        )
    }
}

extension WatchRecipe {
    static func from(_ dict: [String: Any]) -> WatchRecipe? {
        guard 
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let title = dict["title"] as? String,
            let cookingTime = dict["cookingTime"] as? Int,
            let difficulty = dict["difficulty"] as? String
        else { return nil }
        
        return WatchRecipe(
            id: id,
            title: title,
            cookingTime: cookingTime,
            difficulty: difficulty
        )
    }
}

extension WatchShoppingItem {
    static func from(_ dict: [String: Any]) -> WatchShoppingItem? {
        guard 
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let name = dict["name"] as? String,
            let quantity = dict["quantity"] as? String,
            let isCompleted = dict["isCompleted"] as? Bool
        else { return nil }
        
        return WatchShoppingItem(
            id: id,
            name: name,
            quantity: quantity,
            isCompleted: isCompleted
        )
    }
}

extension WatchTimer {
    static func from(_ dict: [String: Any]) -> WatchTimer? {
        guard 
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let recipeName = dict["recipeName"] as? String,
            let stepNumber = dict["stepNumber"] as? Int,
            let endTimeInterval = dict["endTime"] as? TimeInterval
        else { return nil }
        
        return WatchTimer(
            id: id,
            recipeName: recipeName,
            stepNumber: stepNumber,
            endTime: Date(timeIntervalSince1970: endTimeInterval)
        )
    }
}
*/
