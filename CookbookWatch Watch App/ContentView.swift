//
//  ContentView.swift
//  CookbookWatch Watch App
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif
import UserNotifications

// MARK: - Watch Data Models
struct WatchMeal: Codable, Identifiable {
    let id: UUID
    let recipeName: String
    let mealType: String
    let recipeId: UUID
}

struct WatchRecipe: Codable, Identifiable {
    let id: UUID
    let title: String
    let cookingTime: Int
    let difficulty: String
}

struct WatchShoppingItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let quantity: String
    let isCompleted: Bool
}

struct WatchTimer: Codable, Identifiable {
    let id: UUID
    let recipeName: String
    let stepNumber: Int
    let endTime: Date
    
    var timeRemaining: TimeInterval {
        return max(0, endTime.timeIntervalSinceNow)
    }
    
    var isExpired: Bool {
        return timeRemaining <= 0
    }
}

// MARK: - WatchConnectivityManager
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
        
        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            WCSession.default.delegate = self
        }
        #endif
        
        // Request notification permissions
        requestNotificationPermission()
        
        // Load mock data for preview/testing
        loadMockData()
    }
    
    func activateSession() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        
        let session = WCSession.default
        session.activate()
        #endif
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
    
    // MARK: - Timer Management
    func startTimer(recipeName: String, stepNumber: Int, duration: TimeInterval, stepDescription: String = "") {
        let timer = WatchTimer(
            id: UUID(),
            recipeName: recipeName,
            stepNumber: stepNumber,
            endTime: Date().addingTimeInterval(duration)
        )
        
        // Add to local timers
        activeTimers.append(timer)
        
        // Schedule local notification
        scheduleTimerNotification(for: timer, stepDescription: stepDescription)
        
        // Send to iPhone
        sendMessage([
            "action": "startTimer",
            "timer": [
                "id": timer.id.uuidString,
                "recipeName": timer.recipeName,
                "stepNumber": timer.stepNumber,
                "endTime": timer.endTime.timeIntervalSince1970,
                "duration": duration,
                "stepDescription": stepDescription
            ]
        ])
    }
    
    func stopTimer(id: UUID) {
        activeTimers.removeAll { $0.id == id }
        
        // Cancel notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_\(id.uuidString)"])
        
        // Send to iPhone
        sendMessage([
            "action": "stopTimer",
            "timerId": id.uuidString
        ])
    }
    
    private func scheduleTimerNotification(for timer: WatchTimer, stepDescription: String = "") {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished!"
        
        let bodyText = if !stepDescription.isEmpty {
            "\(timer.recipeName) - Step \(timer.stepNumber): \(stepDescription) is complete"
        } else {
            "\(timer.recipeName) - Step \(timer.stepNumber) is complete"
        }
        content.body = bodyText
        content.sound = .default
        content.categoryIdentifier = "TIMER_FINISHED"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timer.timeRemaining > 0 ? timer.timeRemaining : 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "timer_\(timer.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⌚ Failed to schedule timer notification: \(error.localizedDescription)")
            } else {
                print("⌚ Timer notification scheduled for \(timer.recipeName)")
            }
        }
    }
    
    private func sendMessage(_ message: [String: Any]) {
        #if canImport(WatchConnectivity)
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        #endif
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
        
        // Mock timer for testing
        let testTimer = WatchTimer(
            id: UUID(),
            recipeName: "Test Recipe",
            stepNumber: 1,
            endTime: Date().addingTimeInterval(300) // 5 minutes from now
        )
        activeTimers = [testTimer]
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("⌚ Notification permission granted")
            } else if let error = error {
                print("⌚ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Recipe Suggestion Handling
    func showRandomRecipeSuggestion(title: String, recipeId: UUID) {
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

#if canImport(WatchConnectivity)
// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.updateDataFromMessage(applicationContext)
        }
    }
    
    private func handleReceivedMessage(_ message: [String: Any]) {
        if let action = message["action"] as? String {
            handleActionResponse(action, message: message)
        }
        updateDataFromMessage(message)
    }
    
    private func handleActionResponse(_ action: String, message: [String: Any]) {
        switch action {
        case "randomRecipeResponse":
            if let recipeData = message["recipe"] as? [String: Any],
               let title = recipeData["title"] as? String,
               let idString = recipeData["id"] as? String,
               let id = UUID(uuidString: idString) {
                showRandomRecipeSuggestion(title: title, recipeId: id)
            }
        case "timerStarted":
            if let timerData = message["timer"] as? [String: Any] {
                handleIncomingTimer(timerData)
            }
        case "timerStopped":
            if let timerId = message["timerId"] as? String,
               let id = UUID(uuidString: timerId) {
                handleStoppedTimer(id: id)
            }
        default:
            print("⌚ Unknown action response: \(action)")
        }
    }
    
    private func handleIncomingTimer(_ timerData: [String: Any]) {
        guard let idString = timerData["id"] as? String,
              let id = UUID(uuidString: idString),
              let recipeName = timerData["recipeName"] as? String,
              let stepNumber = timerData["stepNumber"] as? Int,
              let endTimeInterval = timerData["endTime"] as? TimeInterval else {
            return
        }
        
        let endTime = Date(timeIntervalSince1970: endTimeInterval)
        let stepDescription = timerData["stepDescription"] as? String ?? ""
        
        let timer = WatchTimer(
            id: id,
            recipeName: recipeName,
            stepNumber: stepNumber,
            endTime: endTime
        )
        
        if timer.timeRemaining > 0 {
            activeTimers.append(timer)
            scheduleTimerNotification(for: timer, stepDescription: stepDescription)
        }
    }
    
    private func handleStoppedTimer(id: UUID) {
        activeTimers.removeAll { $0.id == id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_\(id.uuidString)"])
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
            let newTimers = timersData.compactMap { timerDict -> WatchTimer? in
                guard let idString = timerDict["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let recipeName = timerDict["recipeName"] as? String,
                      let stepNumber = timerDict["stepNumber"] as? Int,
                      let endTimeInterval = timerDict["endTime"] as? TimeInterval else {
                    return nil
                }
                let endTime = Date(timeIntervalSince1970: endTimeInterval)
                return WatchTimer(id: id, recipeName: recipeName, stepNumber: stepNumber, endTime: endTime)
            }
            
            self.activeTimers = newTimers
            print("⌚ Updated \(newTimers.count) active timers")
        }
    }
}
#endif

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WatchTodayView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
                .tag(0)
            
            WatchRecipesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }
                .tag(1)
            
            WatchShoppingView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shopping")
                }
                .tag(2)
            
            WatchTimersView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timers")
                }
                .tag(3)
        }
        .environmentObject(connectivity)
        .onAppear {
            connectivity.activateSession()
        }
    }
}

struct WatchTodayView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""
    @State private var lastRandomRequestTime: Date?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Want Today Meals Section
                    if !connectivity.wantTodayMeals.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Want Today")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            ForEach(connectivity.wantTodayMeals, id: \.id) { meal in
                                WatchMealCard(meal: meal)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Today's Meals Section
                    if !connectivity.todayMeals.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Meals")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            ForEach(connectivity.todayMeals, id: \.id) { meal in
                                WatchMealCard(meal: meal)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Random Recipe Button
                    Button(action: requestRandomRecipe) {
                        HStack {
                            Image(systemName: "dice")
                            Text("Random Recipe")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isRandomRequestCooldown)
                    .opacity(isRandomRequestCooldown ? 0.6 : 1.0)
                    
                    if connectivity.todayMeals.isEmpty && connectivity.wantTodayMeals.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No meals planned")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Try a random recipe!")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("Today")
        }
        .alert("Recipe Suggestion", isPresented: $connectivity.showRecipeSuggestion) {
            Button("Add to Want Today") {
                connectivity.acceptRecipeSuggestion()
            }
            Button("Dismiss") {
                connectivity.dismissRecipeSuggestion()
            }
        } message: {
            if let recipe = connectivity.suggestedRecipe {
                Text("How about: \(recipe.title)?")
            }
        }
        .alert("Confirmation", isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
    }
    
    private var isRandomRequestCooldown: Bool {
        guard let lastRequest = lastRandomRequestTime else { return false }
        return Date().timeIntervalSince(lastRequest) < 5.0 // 5 second cooldown
    }
    
    private func requestRandomRecipe() {
        lastRandomRequestTime = Date()
        connectivity.requestRandomRecipe()
        
        // Show temporary feedback
        confirmationMessage = "Requesting random recipe..."
        showingConfirmation = true
        
        // Hide confirmation after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingConfirmation = false
        }
    }
}

struct WatchRecipesView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var searchText = ""
    @State private var selectedRecipeForCooking: WatchRecipe?
    @State private var showingCookingModeAlert = false
    @State private var showingWantTodayConfirmation = false
    @State private var selectedRecipe: WatchRecipe?
    
    var body: some View {
        NavigationView {
            VStack {
                // Search functionality (simplified for watch)
                if !connectivity.recipes.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search recipes", text: $searchText)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                }
                
                // Recipes List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredRecipes, id: \.id) { recipe in
                            WatchRecipeCard(recipe: recipe)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                
                if connectivity.recipes.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "book.closed")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No recipes available")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Add recipes on your iPhone")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                }
            }
            .navigationTitle("Recipes")
        }
        .alert("Start Cooking?", isPresented: $showingCookingModeAlert) {
            Button("Start") {
                if let recipe = selectedRecipeForCooking {
                    connectivity.startCookingMode(recipeId: recipe.id)
                }
            }
            Button("Cancel") { }
        } message: {
            if let recipe = selectedRecipeForCooking {
                Text("Start cooking mode for \(recipe.title)?")
            }
        }
        .alert("Added to Want Today", isPresented: $showingWantTodayConfirmation) {
            Button("OK") { }
        } message: {
            if let recipe = selectedRecipe {
                Text("\(recipe.title) added to your want today list!")
            }
        }
    }
    
    private var filteredRecipes: [WatchRecipe] {
        if searchText.isEmpty {
            return connectivity.recipes
        } else {
            return connectivity.recipes.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) 
            }
        }
    }
}

struct WatchShoppingView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(connectivity.shoppingItems, id: \.id) { item in
                        WatchShoppingItemCard(item: item)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                
                if connectivity.shoppingItems.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "cart.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No shopping items")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Add items on your iPhone")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                }
            }
            .navigationTitle("Shopping")
        }
    }
}

struct WatchTimersView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var showingAddTimer = false
    @State private var newTimerMinutes: Double = 5
    @State private var newTimerName = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 8) {
                    // Active Timers
                    ForEach(connectivity.activeTimers, id: \.id) { timer in
                        WatchTimerCard(timer: timer)
                    }
                    
                    // Add Timer Button
                    Button(action: { showingAddTimer = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Timer")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.vertical, 8)
                
                if connectivity.activeTimers.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No active timers")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Start cooking to begin timers")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Timers")
        }
        .sheet(isPresented: $showingAddTimer) {
            AddTimerView(
                timerName: $newTimerName,
                timerMinutes: $newTimerMinutes,
                onAdd: { name, minutes in
                    connectivity.startTimer(
                        recipeName: name.isEmpty ? "Custom Timer" : name,
                        stepNumber: 1,
                        duration: minutes * 60,
                        stepDescription: "Custom timer"
                    )
                    showingAddTimer = false
                    newTimerName = ""
                    newTimerMinutes = 5
                }
            )
        }
    }
}

struct AddTimerView: View {
    @Binding var timerName: String
    @Binding var timerMinutes: Double
    let onAdd: (String, Double) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timer Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Timer name", text: $timerName)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(Int(timerMinutes)) minutes")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Slider(value: $timerMinutes, in: 1...60, step: 1)
                        .accentColor(.blue)
                }
                
                Button("Add Timer") {
                    onAdd(timerName, timerMinutes)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Timer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Card Views

struct WatchMealCard: View {
    let meal: WatchMeal
    @State private var showingWantTodayAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.recipeName)
                    .font(.headline)
                    .lineLimit(1)
                Text(meal.mealType)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { showingWantTodayAlert = true }) {
                Image(systemName: "heart.circle")
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .alert("Add to Want Today?", isPresented: $showingWantTodayAlert) {
            Button("Add") {
                WatchConnectivityManager.shared.markWantToday(recipeId: meal.recipeId)
            }
            Button("Cancel") { }
        }
    }
}

struct WatchRecipeCard: View {
    let recipe: WatchRecipe
    @State private var showingCookingModeAlert = false
    @State private var showingWantTodayAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text("\(recipe.cookingTime) min • \(recipe.difficulty)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
            HStack(spacing: 8) {
                Button("Cook") {
                    showingCookingModeAlert = true
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(6)
                
                Button("Want") {
                    showingWantTodayAlert = true
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .alert("Start Cooking?", isPresented: $showingCookingModeAlert) {
            Button("Start") {
                WatchConnectivityManager.shared.startCookingMode(recipeId: recipe.id)
            }
            Button("Cancel") { }
        }
        .alert("Add to Want Today?", isPresented: $showingWantTodayAlert) {
            Button("Add") {
                WatchConnectivityManager.shared.markWantToday(recipeId: recipe.id)
            }
            Button("Cancel") { }
        }
    }
}

struct WatchShoppingItemCard: View {
    let item: WatchShoppingItem
    
    var body: some View {
        HStack {
            Button(action: toggleItem) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .gray : .primary)
                Text(item.quantity)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
    
    private func toggleItem() {
        WatchConnectivityManager.shared.toggleShoppingItem(itemId: item.id)
    }
}

struct WatchTimerCard: View {
    let timer: WatchTimer
    @State private var timeRemaining: TimeInterval = 0
    @State private var timerIsActive = true
    
    init(timer: WatchTimer) {
        self.timer = timer
        _timeRemaining = State(initialValue: timer.timeRemaining)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(timer.recipeName)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Step \(timer.stepNumber)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Button(action: stopTimer) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            // Timer Display
            HStack {
                Text(formatTime(timeRemaining))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining <= 60 ? .red : .primary)
                
                Spacer()
                
                // Progress indicator
                Circle()
                    .fill(timeRemaining <= 60 ? Color.red : Color.blue)
                    .frame(width: 8, height: 8)
                    .opacity(timerIsActive ? 1.0 : 0.3)
            }
        }
        .padding(12)
        .background(timeRemaining <= 60 ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timerIsActive = false
        }
    }
    
    private func startTimer() {
        timerIsActive = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timerIsActive {
                timeRemaining = max(0, self.timer.timeRemaining)
                if timeRemaining <= 0 {
                    timer.invalidate()
                    timerIsActive = false
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func stopTimer() {
        timerIsActive = false
        WatchConnectivityManager.shared.stopTimer(id: timer.id)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManager.shared)
}
