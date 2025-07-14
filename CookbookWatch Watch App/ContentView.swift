//
//  CookbookWatch Watch App.swift
//  CookbookWatch Watch App
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

@main
struct CookbookWatch_Watch_App: App {
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchConnectivity)
                .onAppear {
                    watchConnectivity.activateSession()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
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
    }
}

struct WatchTodayView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Ready to cook?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Connection Status
                if !connectivity.isConnected {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Not connected to iPhone")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Want Today Meals
                if !connectivity.wantTodayMeals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Want Today")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        ForEach(connectivity.wantTodayMeals.prefix(3), id: \.id) { meal in
                            WatchMealCard(meal: meal) {
                                // Start cooking mode
                                connectivity.startCookingMode(recipeId: meal.recipeId)
                                showConfirmation("Starting cooking mode...")
                            }
                        }
                    }
                }
                
                // Today's Meals
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Meals")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    if connectivity.todayMeals.isEmpty {
                        Text("No meals planned")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(connectivity.todayMeals.prefix(4), id: \.id) { meal in
                            WatchMealCard(meal: meal) {
                                connectivity.startCookingMode(recipeId: meal.recipeId)
                                showConfirmation("Starting cooking mode...")
                            }
                        }
                    }
                }
                
                // Quick Actions
                VStack(spacing: 8) {
                    Button("🎲 Random Recipe to Cook") {
                        connectivity.requestRandomRecipe()
                        showConfirmation("Finding a recipe for you...")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    
                    Button("📖 Browse Recipes") {
                        // This will switch to recipes tab - handled by TabView selection
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("🛒 Shopping List") {
                        // Switch to shopping tab
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Today")
        .alert("Action", isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }
    
    private func showConfirmation(_ message: String) {
        confirmationMessage = message
        showingConfirmation = true
    }
}

struct WatchRecipesView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var searchText = ""
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""
    @State private var selectedRecipeForCooking: WatchRecipe?
    
    var body: some View {
        NavigationView {
            List {
                // Show connection status if not connected
                if !connectivity.isConnected {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Not connected to iPhone")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Show recipes or loading state
                if connectivity.recipes.isEmpty && connectivity.isConnected {
                    Section {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Loading recipes...")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    ForEach(filteredRecipes, id: \.id) { recipe in
                        WatchRecipeRow(recipe: recipe) {
                            connectivity.startCookingMode(recipeId: recipe.id)
                            showConfirmation("Starting cooking mode for \(recipe.title)")
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes")
            .alert("Action", isPresented: $showingConfirmation) {
                Button("OK") { }
            } message: {
                Text(confirmationMessage)
            }
        }
    }
    
    private var filteredRecipes: [WatchRecipe] {
        if searchText.isEmpty {
            return connectivity.recipes
        } else {
            return connectivity.recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func showConfirmation(_ message: String) {
        confirmationMessage = message
        showingConfirmation = true
    }
}

struct WatchShoppingView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Show connection status if not connected
                if !connectivity.isConnected {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Not connected to iPhone")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Show shopping items or empty state
                if connectivity.shoppingItems.isEmpty && connectivity.isConnected {
                    Section {
                        Text("No shopping items")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(connectivity.shoppingItems, id: \.id) { item in
                        WatchShoppingItemRow(item: item) {
                            connectivity.toggleShoppingItem(itemId: item.id)
                            showConfirmation("Toggled \(item.name)")
                        }
                    }
                }
            }
            .navigationTitle("Shopping")
            .alert("Action", isPresented: $showingConfirmation) {
                Button("OK") { }
            } message: {
                Text(confirmationMessage)
            }
        }
    }
    
    private func showConfirmation(_ message: String) {
        confirmationMessage = message
        showingConfirmation = true
    }
}

struct WatchTimersView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    
    var body: some View {
        NavigationView {
            VStack {
                if connectivity.activeTimers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "timer")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("No Active Timers")
                            .font(.headline)
                        
                        Text("Start cooking to see timers here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(connectivity.activeTimers, id: \.id) { timer in
                            WatchTimerRow(timer: timer)
                        }
                    }
                }
            }
            .navigationTitle("Timers")
        }
    }
}

// MARK: - Watch Components
struct WatchMealCard: View {
    let meal: WatchMeal
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.recipeName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(meal.mealType)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // Want to Cook button
                Button(action: {
                    WatchConnectivityManager.shared.markWantToday(recipeId: meal.recipeId)
                }) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                
                // Cook Now button
                Button(action: action) {
                    Image(systemName: "play.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

struct WatchRecipeRow: View {
    let recipe: WatchRecipe
    let action: () -> Void
    @State private var showingActionMenu = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack {
                    Text(formatTime(recipe.cookingTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(recipe.difficulty)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                // Want to Cook button
                Button(action: {
                    WatchConnectivityManager.shared.markWantToday(recipeId: recipe.id)
                }) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                
                // Cook Now button  
                Button(action: action) {
                    Image(systemName: "play.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if remainingMinutes == 0 {
                return hours == 1 ? "1 hour" : "\(hours) hours"
            } else {
                return hours == 1 ? "1 hour \(remainingMinutes) min" : "\(hours) hours \(remainingMinutes) min"
            }
        }
    }
}

struct WatchShoppingItemRow: View {
    let item: WatchShoppingItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.caption)
                        .strikethrough(item.isCompleted)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                    
                    if !item.quantity.isEmpty {
                        Text(item.quantity)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

struct WatchTimerRow: View {
    let timer: WatchTimer
    @State private var timeRemaining: TimeInterval
    
    init(timer: WatchTimer) {
        self.timer = timer
        self._timeRemaining = State(initialValue: timer.timeRemaining)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timer.recipeName)
                .font(.caption)
                .fontWeight(.medium)
            
            Text("Step \(timer.stepNumber)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack {
                Text(formatTime(timeRemaining))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining < 60 ? .red : .primary)
                
                Spacer()
                
                if timeRemaining <= 0 {
                    Text("DONE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            let newTimeRemaining = timer.endTime.timeIntervalSinceNow
            timeRemaining = max(0, newTimeRemaining)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Watch Data Models
struct WatchMeal: Codable {
    let id: UUID
    let recipeName: String
    let mealType: String
    let recipeId: UUID
}

struct WatchRecipe: Codable {
    let id: UUID
    let title: String
    let cookingTime: Int
    let difficulty: String
}

struct WatchShoppingItem: Codable {
    let id: UUID
    let name: String
    let quantity: String
    let isCompleted: Bool
}

struct WatchTimer: Codable {
    let id: UUID
    let recipeName: String
    let stepNumber: Int
    let endTime: Date
    
    var timeRemaining: TimeInterval {
        return endTime.timeIntervalSinceNow
    }
    
    private func formatTime(_ minutes: Double) -> String {
        let totalMinutes = Int(minutes)
        
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let remainingMinutes = totalMinutes % 60
            
            if remainingMinutes == 0 {
                return hours == 1 ? "1 hour" : "\(hours) hours"
            } else {
                return hours == 1 ? "1 hour \(remainingMinutes) min" : "\(hours) hours \(remainingMinutes) min"
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManager.shared)
}
