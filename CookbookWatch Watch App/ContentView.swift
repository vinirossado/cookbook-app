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
                            }
                        }
                    }
                }
                
                // Quick Actions
                VStack(spacing: 8) {
                    Button("Random Recipe") {
                        connectivity.requestRandomRecipe()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    
                    Button("Shopping List") {
                        // Switch to shopping tab
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Today")
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
}

struct WatchRecipesView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredRecipes, id: \.id) { recipe in
                    WatchRecipeRow(recipe: recipe) {
                        connectivity.startCookingMode(recipeId: recipe.id)
                    }
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes")
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
}

struct WatchShoppingView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(connectivity.shoppingItems, id: \.id) { item in
                    WatchShoppingItemRow(item: item) {
                        connectivity.toggleShoppingItem(itemId: item.id)
                    }
                }
            }
            .navigationTitle("Shopping")
        }
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
        Button(action: action) {
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
                
                Image(systemName: "play.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

struct WatchRecipeRow: View {
    let recipe: WatchRecipe
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    HStack {
                        Text("\(recipe.cookingTime) min")
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
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
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
}

#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManager.shared)
}
