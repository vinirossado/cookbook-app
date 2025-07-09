//
//  NotificationManager.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound, .provisional]
            )
            
            await MainActor.run {
                isAuthorized = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized ||
                                  settings.authorizationStatus == .provisional
            }
        }
    }
    
    @MainActor
    private func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Local Notifications
    func scheduleLocalNotification(
        id: String,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        userInfo: [String: Any] = [:]
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func scheduleMealReminder(for meal: PlannedMeal) {
        let calendar = Calendar.current
        let now = Date()
        
        // Schedule reminder 30 minutes before meal time
        let reminderTime = calendar.date(byAdding: .minute, value: -30, to: meal.scheduledDate) ?? meal.scheduledDate
        
        if reminderTime > now {
            let timeInterval = reminderTime.timeIntervalSince(now)
            
            scheduleLocalNotification(
                id: "meal_reminder_\(meal.id.uuidString)",
                title: "Meal Reminder",
                body: "Don't forget to prepare \(meal.recipeName) for \(meal.mealType.rawValue.lowercased())!",
                timeInterval: timeInterval,
                userInfo: [
                    "type": "meal_reminder",
                    "mealId": meal.id.uuidString,
                    "recipeId": meal.recipeId.uuidString
                ]
            )
        }
    }
    
    func scheduleCookingTimer(for step: CookingStep, recipeName: String) {
        guard let duration = step.duration else { return }
        
        scheduleLocalNotification(
            id: "cooking_timer_\(step.id.uuidString)",
            title: "Cooking Timer",
            body: "Step \(step.stepNumber) for \(recipeName) is complete!",
            timeInterval: duration,
            userInfo: [
                "type": "cooking_timer",
                "stepId": step.id.uuidString,
                "stepNumber": step.stepNumber
            ]
        )
    }
    
    func scheduleShoppingReminder(items: [ShoppingItem]) {
        let itemCount = items.count
        let body = itemCount == 1 ? 
            "Don't forget to buy \(items.first?.ingredient.name ?? "your item")!" :
            "Don't forget to buy your \(itemCount) grocery items!"
        
        // Schedule for tomorrow morning at 9 AM
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let reminderTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        let timeInterval = reminderTime.timeIntervalSince(Date())
        
        if timeInterval > 0 {
            scheduleLocalNotification(
                id: "shopping_reminder",
                title: "Shopping Reminder",
                body: body,
                timeInterval: timeInterval,
                userInfo: [
                    "type": "shopping_reminder",
                    "itemCount": itemCount
                ]
            )
        }
    }
    
    // MARK: - Cross-Device Notifications
    func sendWantTodayNotification(meal: PlannedMeal) {
        // In a real app, this would send a push notification to family members
        // For now, we'll simulate with a local notification
        
        scheduleLocalNotification(
            id: "want_today_\(meal.id.uuidString)",
            title: "Family Meal Request",
            body: "Someone wants to cook \(meal.recipeName) today!",
            timeInterval: 1, // Immediate notification
            userInfo: [
                "type": "want_today",
                "mealId": meal.id.uuidString,
                "recipeName": meal.recipeName
            ]
        )
        
        // Send haptic feedback
        triggerHapticFeedback(.success)
    }
    
    func sendShoppingCartUpdate(item: ShoppingItem, action: ShoppingAction) {
        let actionText = action == .added ? "added" : "completed"
        
        scheduleLocalNotification(
            id: "shopping_update_\(item.id.uuidString)",
            title: "Shopping List Updated",
            body: "\(item.ingredient.name) was \(actionText) to the shopping list",
            timeInterval: 1,
            userInfo: [
                "type": "shopping_update",
                "itemId": item.id.uuidString,
                "action": action.rawValue
            ]
        )
    }
    
    func sendRecipeShared(recipeName: String, sharedBy: String) {
        scheduleLocalNotification(
            id: "recipe_shared_\(UUID().uuidString)",
            title: "New Recipe Shared",
            body: "\(sharedBy) shared '\(recipeName)' with you!",
            timeInterval: 1,
            userInfo: [
                "type": "recipe_shared",
                "recipeName": recipeName,
                "sharedBy": sharedBy
            ]
        )
    }
    
    // MARK: - Notification Management
    func cancelNotification(withId id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAllMealReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let mealReminderIds = requests
                .filter { $0.content.userInfo["type"] as? String == "meal_reminder" }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: mealReminderIds)
        }
    }
    
    func cancelAllCookingTimers() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let timerIds = requests
                .filter { $0.content.userInfo["type"] as? String == "cooking_timer" }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: timerIds)
        }
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: - Haptic Feedback
    func triggerHapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func triggerImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Badge Management
    func updateBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func clearBadge() {
        updateBadgeCount(0)
    }
    
    // MARK: - Rich Notifications
    func scheduleRichNotification(
        id: String,
        title: String,
        body: String,
        imageName: String?,
        timeInterval: TimeInterval,
        userInfo: [String: Any] = [:]
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo
        
        // Add image attachment if provided
        if let imageName = imageName,
           let imageURL = Bundle.main.url(forResource: imageName, withExtension: "jpg") ?? Bundle.main.url(forResource: imageName, withExtension: "png") {
            do {
                let attachment = try UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("Failed to create notification attachment: \(error)")
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule rich notification: \(error)")
            }
        }
    }
}

// MARK: - Supporting Types
enum ShoppingAction: String, CaseIterable {
    case added = "added"
    case completed = "completed"
    case removed = "removed"
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification taps based on type
        if let type = userInfo["type"] as? String {
            handleNotificationResponse(type: type, userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func handleNotificationResponse(type: String, userInfo: [AnyHashable: Any]) {
        switch type {
        case "meal_reminder":
            // Navigate to meal planner or recipe detail
            if let mealId = userInfo["mealId"] as? String {
                NotificationCenter.default.post(name: .navigateToMeal, object: mealId)
            }
            
        case "cooking_timer":
            // Navigate to recipe with active cooking timer
            if let stepId = userInfo["stepId"] as? String {
                NotificationCenter.default.post(name: .cookingTimerCompleted, object: stepId)
            }
            
        case "shopping_reminder":
            // Navigate to shopping list
            NotificationCenter.default.post(name: .navigateToShopping, object: nil)
            
        case "want_today":
            // Navigate to today's meal view
            if let mealId = userInfo["mealId"] as? String {
                NotificationCenter.default.post(name: .navigateToTodayMeal, object: mealId)
            }
            
        case "recipe_shared":
            // Navigate to shared recipe
            if let recipeName = userInfo["recipeName"] as? String {
                NotificationCenter.default.post(name: .navigateToSharedRecipe, object: recipeName)
            }
            
        default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToMeal = Notification.Name("navigateToMeal")
    static let cookingTimerCompleted = Notification.Name("cookingTimerCompleted")
    static let navigateToShopping = Notification.Name("navigateToShopping")
    static let navigateToTodayMeal = Notification.Name("navigateToTodayMeal")
    static let navigateToSharedRecipe = Notification.Name("navigateToSharedRecipe")
}
