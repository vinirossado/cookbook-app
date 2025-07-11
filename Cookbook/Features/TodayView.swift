//
//  TodayView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @Environment(AppState.self) private var appState
    @State private var showingCookingMode = false
    @State private var selectedRecipe: Recipe?
    
    init(viewModel: TodayViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Greeting Section
                greetingSection
                
                // Want Today Section
                wantTodaySection
                
                // Today's Meals
                todayMealsSection
                
                // World Cuisines
                worldCuisinesSection
                
                // Quick Actions
                quickActionsSection
                
                // Cooking Timers (if any active)
                activeTimersSection
            }
            .padding()
        }
        .navigationTitle("Today")
        .refreshable {
            viewModel.refreshTodayData()
        }
        .sheet(isPresented: $showingCookingMode) {
            if let recipe = selectedRecipe {
                CookingModeView(recipe: recipe)
            }
        }
    }
    
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(greetingText)
                        .font(CookBookFonts.title1)
                        .fontWeight(.bold)
                        .foregroundColor(CookBookColors.text)
                    
                    Text("Ready to cook something delicious?")
                        .font(CookBookFonts.subheadline)
                        .foregroundColor(CookBookColors.textSecondary)
                }
                
                Spacer()
                
                // Weather-based cooking suggestion icon
                Image(systemName: weatherIcon)
                    .font(.largeTitle)
                    .foregroundColor(CookBookColors.primary)
            }
            
            // Today's date and meal summary
            HStack {
                Text(Date.now, style: .date)
                    .font(CookBookFonts.subheadline)
                    .foregroundColor(CookBookColors.textSecondary)
                
                Spacer()
                
                Text("\(appState.todayMeals.count) meals planned")
                    .font(CookBookFonts.subheadline)
                    .foregroundColor(CookBookColors.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [CookBookColors.primary.opacity(0.1), CookBookColors.surface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    private var wantTodaySection: some View {
        Group {
            if !appState.wantTodayMeals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(CookBookColors.accent)
                        
                        Text("Want to Cook Today")
                            .font(CookBookFonts.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(appState.wantTodayMeals.count)")
                            .font(CookBookFonts.caption1)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(CookBookColors.accent))
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(appState.wantTodayMeals) { meal in
                                WantTodayCard(meal: meal) {
                                    if let recipe = appState.recipes.first(where: { $0.id == meal.recipeId }) {
                                        selectedRecipe = recipe
                                        showingCookingMode = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(CookBookColors.cardBackground)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
        }
    }
    
    private var todayMealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Meal Plan")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    appState.selectedTab = .planner
                }
                .font(CookBookFonts.caption1)
                .foregroundColor(CookBookColors.primary)
            }
            
            if appState.todayMeals.isEmpty {
                EmptyTodayMealsView()
            } else {
                VStack(spacing: 12) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        if let meal = appState.todayMeals.first(where: { $0.mealType == mealType }) {
                            TodayMealCard(meal: meal) {
                                if let recipe = appState.recipes.first(where: { $0.id == meal.recipeId }) {
                                    selectedRecipe = recipe
                                    showingCookingMode = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var worldCuisinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(CookBookColors.primary)
                
                Text("World Cuisines")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: RecipeRouter.createModule()) {
                    Text("See All")
                        .font(CookBookFonts.caption1)
                        .foregroundColor(CookBookColors.primary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(topCountriesWithRecipes, id: \.country) { countryStats in
                        CuisineStatsCard(
                            country: countryStats.country,
                            recipeCount: countryStats.count
                        ) {
                            // Navigate to filtered recipes
                            appState.setCountryFilter(countryStats.country)
                            appState.selectedTab = .recipes
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    title: "Random Recipe",
                    icon: "shuffle",
                    color: CookBookColors.primary
                ) {
                    viewModel.getRandomRecipe()
                }
                
                QuickActionButton(
                    title: "Shopping List",
                    icon: "cart",
                    color: CookBookColors.secondary
                ) {
                    appState.selectedTab = .shopping
                }
                
                QuickActionButton(
                    title: "Favorites",
                    icon: "heart.fill",
                    color: CookBookColors.accent
                ) {
                    viewModel.showFavorites()
                }
            }
        }
    }
    
    private var activeTimersSection: some View {
        Group {
            if !viewModel.activeTimers.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Cooking Timers")
                        .font(CookBookFonts.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(viewModel.activeTimers) { timer in
                            ActiveTimerCard(timer: timer)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(CookBookColors.warning.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(CookBookColors.warning.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    private var topCountriesWithRecipes: [(country: Country, count: Int)] {
        let countryGroups = Dictionary(grouping: appState.recipes) { $0.countryOfOrigin }
        return countryGroups
            .map { (country: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(6)
            .map { $0 }
    }
    
    // MARK: - Helper Properties
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    private var weatherIcon: String {
        // In a real app, this would be based on actual weather data
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<18:
            return "sun.max"
        default:
            return "moon.stars"
        }
    }
}

struct WantTodayCard: View {
    let meal: PlannedMeal
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: meal.mealType.icon)
                        .foregroundColor(meal.mealType.color)
                        .font(.caption)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(CookBookColors.textSecondary)
                        .font(.caption2)
                }
                
                Text(meal.recipeName)
                    .font(CookBookFonts.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(meal.mealType.rawValue)
                    .font(CookBookFonts.caption2)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            .frame(width: 140, height: 100)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.surface)
            )
        }
    }
}

struct TodayMealCard: View {
    let meal: PlannedMeal
    let action: () -> Void
    @Environment(AppState.self) private var appState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: meal.mealType.icon)
                        .foregroundColor(meal.mealType.color)
                    
                    Text(meal.mealType.rawValue)
                        .font(CookBookFonts.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(meal.mealType.color)
                }
                
                Text(meal.recipeName)
                    .font(CookBookFonts.callout)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.text)
                
                Text("Serves \(meal.servings)")
                    .font(CookBookFonts.caption1)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: action) {
                    Text("Cook")
                        .font(CookBookFonts.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(CookBookColors.primary)
                        )
                }
                
                Button(action: {
                    appState.markWantToday(meal)
                }) {
                    Image(systemName: meal.wantToday ? "heart.fill" : "heart")
                        .foregroundColor(meal.wantToday ? CookBookColors.accent : CookBookColors.textSecondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.surface)
        )
    }
}

struct EmptyTodayMealsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.largeTitle)
                .foregroundColor(CookBookColors.textSecondary)
            
            VStack(spacing: 4) {
                Text("No meals planned for today")
                    .font(CookBookFonts.callout)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.text)
                
                Text("Add some meals to your planner to get started")
                    .font(CookBookFonts.caption1)
                    .foregroundColor(CookBookColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Plan Meals") {
                AppState.shared.selectedTab = .planner
            }
            .font(CookBookFonts.callout)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(CookBookColors.primary)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CookBookColors.surface)
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(CookBookFonts.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.text)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.surface)
            )
        }
    }
}

struct ActiveTimerCard: View {
    let timer: CookingTimer
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(timer.recipeName)
                    .font(CookBookFonts.subheadline)
                    .fontWeight(.medium)
                
                Text("Step \(timer.stepNumber)")
                    .font(CookBookFonts.caption1)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
            
            Text(timer.formattedTimeRemaining)
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(CookBookColors.warning)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
    }
}

struct CookingModeView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Cooking Mode")
                    .font(CookBookFonts.title1)
                    .fontWeight(.bold)
                
                Text(recipe.title)
                    .font(CookBookFonts.headline)
                    .foregroundColor(CookBookColors.textSecondary)
                
                Spacer()
                
                Text("Full cooking mode implementation would go here")
                    .font(CookBookFonts.body)
                    .foregroundColor(CookBookColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Cooking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Models
struct CookingTimer: Identifiable {
    let id = UUID()
    let recipeName: String
    let stepNumber: Int
    let totalTime: TimeInterval
    let startTime: Date
    
    var timeRemaining: TimeInterval {
        let elapsed = Date().timeIntervalSince(startTime)
        return max(0, totalTime - elapsed)
    }
    
    var formattedTimeRemaining: String {
        return TimeInterval.formatTime(timeRemaining)
    }
    
    var isExpired: Bool {
        return timeRemaining <= 0
    }
}

struct CuisineStatsCard: View {
    let country: Country
    let recipeCount: Int
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(country.flag)
                .font(.title)
            
            Text(country.rawValue)
                .font(CookBookFonts.caption1)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text("\(recipeCount) recipe\(recipeCount == 1 ? "" : "s")")
                .font(CookBookFonts.caption2)
                .foregroundColor(CookBookColors.textSecondary)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .onTapGesture {
            action()
        }
    }
}

@MainActor
@Observable
class TodayViewModel {
    var activeTimers: [CookingTimer] = []
    
    private let interactor: TodayInteractorProtocol
    private let router: TodayRouterProtocol
    
    init(interactor: TodayInteractorProtocol, router: TodayRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func refreshTodayData() {
        // Refresh today's meals and other data
    }
    
    func getRandomRecipe() {
        // Get a random recipe suggestion
    }
    
    func showFavorites() {
        // Show favorite recipes
    }
}

protocol TodayInteractorProtocol {
    var presenter: TodayPresenterProtocol? { get set }
}

class TodayInteractor: TodayInteractorProtocol {
    var presenter: TodayPresenterProtocol?
}

@MainActor
protocol TodayPresenterProtocol {
    var viewModel: TodayViewModel? { get set }
}

class TodayPresenter: TodayPresenterProtocol {
    weak var viewModel: TodayViewModel?
}

#Preview {
    let interactor = TodayInteractor()
    let presenter = TodayPresenter()
    let router = TodayRouter()
    
    let viewModel = TodayViewModel(
        interactor: interactor,
        router: router
    )
    
    // Wire VIP dependencies
    interactor.presenter = presenter
    presenter.viewModel = viewModel
    
    return TodayView(viewModel: viewModel)
        .environment(AppState.shared)
}
