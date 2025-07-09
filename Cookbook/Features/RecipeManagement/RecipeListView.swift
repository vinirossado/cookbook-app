//
//  RecipeListView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct RecipeListView: View {
    @State private var viewModel: RecipeListViewModel
    @Environment(AppState.self) private var appState
    @State private var showingAddRecipe = false
    @State private var showingFilters = false
    @State private var selectedRecipe: Recipe?
    
    init(viewModel: RecipeListViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Search Bar
                searchSection
                
                // Category Filters
                categoryFilterSection
                
                // Quick Filters
                quickFiltersSection
                
                // Recipes Grid
                recipesSection
            }
            
            .padding(.bottom, 20)
        }
        .navigationTitle("Recipes")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("🔔 Test") {
                    // Test navigation
                    if let firstRecipe = filteredRecipes.first {
                        print("🔍 Testing navigation with recipe: \(firstRecipe.title)")
                        selectedRecipe = firstRecipe
                    }
                    
                    // Test notification
                    Task {
                        await NotificationManager.shared.requestAuthorization()
                        NotificationManager.shared.scheduleLocalNotification(
                            id: "test_notification",
                            title: "Test Notification",
                            body: "This is a test notification from Cookbook!",
                            timeInterval: 1
                        )
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddRecipe = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(CookBookColors.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeView()
        }
        .sheet(isPresented: $showingFilters) {
            FiltersView()
        }
        .onAppear {
            viewModel.loadRecipes()
        }
        .navigationDestination(item: $selectedRecipe) { recipe in
            print("🧭 NavigationDestination triggered for recipe: \(recipe.title)")
            print("🏗️ Creating RecipeDetailView module...")
            let module = RecipeDetailRouter.createModule(for: recipe)
            print("✅ Module created successfully")
            return module
        }
    }
    
    private var searchSection: some View {
        @Bindable var bindableAppState = appState
        return HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(CookBookColors.textSecondary)
                
                TextField("Search recipes...", text: $bindableAppState.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !bindableAppState.searchText.isEmpty {
                    Button(action: { bindableAppState.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(CookBookColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.surface)
            )
            
            Button(action: { showingFilters = true }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(CookBookColors.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(CookBookColors.surface)
                    )
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        category: category,
                        isSelected: appState.selectedCategory == category
                    ) {
                        appState.selectedCategory = appState.selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var quickFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterOption.allCases, id: \.self) { filter in
                    QuickFilterChip(
                        filter: filter,
                        isSelected: appState.filterOptions.contains(filter)
                    ) {
                        if appState.filterOptions.contains(filter) {
                            appState.filterOptions.remove(filter)
                        } else {
                            appState.filterOptions.insert(filter)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var recipesSection: some View {
        let columns = [
            GridItem(.flexible(minimum: 150, maximum: .infinity), spacing: 6),
            GridItem(.flexible(minimum: 150, maximum: .infinity), spacing: 6)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredRecipes) { recipe in
                RecipeCard(
                    recipe: recipe,
                    onFavoriteToggle: {
                        print("🔖 Favorite toggle for recipe: \(recipe.title)")
                        appState.toggleFavorite(recipe)
                    },
                    onWantToday: {
                        print("⏰ Want today for recipe: \(recipe.title)")
                        // Create a new planned meal for today with "want today" set to true
                        let todayMeal = PlannedMeal(
                            recipeId: recipe.id,
                            recipeName: recipe.title,
                            mealType: .lunch, // Default to lunch
                            scheduledDate: Date(),
                            servings: recipe.servingSize
                        )
                        appState.addMealToPlan(todayMeal)
                        appState.markWantToday(todayMeal)
                    },
                    onTap: {
                        print("🔍 Recipe card tapped: \(recipe.title)")
                        print("📱 Setting selectedRecipe to: \(recipe.title)")
                        selectedRecipe = recipe
                        print("✅ selectedRecipe is now: \(selectedRecipe?.title ?? "nil")")
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    private var filteredRecipes: [Recipe] {
        return viewModel.filteredRecipes(
            searchText: appState.searchText,
            category: appState.selectedCategory,
            filters: appState.filterOptions
        )
    }
}

struct CategoryFilterChip: View {
    let category: RecipeCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(CookBookFonts.caption1)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color : CookBookColors.surface)
            )
            .foregroundColor(isSelected ? .white : CookBookColors.text)
        }
    }
}

struct QuickFilterChip: View {
    let filter: FilterOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                
                Text(filter.rawValue)
                    .font(CookBookFonts.caption2)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? CookBookColors.primary : CookBookColors.surface)
            )
            .foregroundColor(isSelected ? .white : CookBookColors.textSecondary)
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    let onFavoriteToggle: () -> Void
    let onWantToday: () -> Void
    let onTap: () -> Void
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe Image
            ZStack(alignment: .topTrailing) {
                RecipeImageView(
                    imageUrl: recipe.images.first?.url ?? "photo",
                    height: 110,
                    cornerRadius: 12
                )
                .clipped()
                .frame(height: 110)
                
                // Action Buttons
                HStack(spacing: 4) {
                    // Want Today Button
                    Button(action: {
                        onWantToday()
                    }) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 11, weight: .medium))
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(CookBookColors.primary.opacity(0.8))
                                    .background(Circle().fill(.ultraThinMaterial))
                            )
                    }
                    
                    // Favorite Button
                    Button(action: {
                        onFavoriteToggle()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? CookBookColors.accent : .white)
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 26, height: 26)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .background(Circle().fill(.ultraThinMaterial))
                            )
                    }
                }
                .padding(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Recipe Title - Fixed height container
                Text(recipe.title)
                    .font(CookBookFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(CookBookColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 42, alignment: .top)
                
                // Recipe Meta
                HStack(spacing: 4) {
                    // Difficulty
                    HStack(spacing: 2) {
                        Image(systemName: recipe.difficulty.icon)
                            .font(.caption2)
                        Text(recipe.difficulty.rawValue)
                            .font(CookBookFonts.caption2)
                    }
                    .foregroundColor(recipe.difficultyColor)
                    
                    Spacer(minLength: 0)
                    
                    // Cook Time
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(recipe.formattedTotalTime)
                            .font(CookBookFonts.caption2)
                    }
                    .foregroundColor(CookBookColors.textSecondary)
                }
                .frame(height: 16)
                
                // Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(recipe.rating) ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(CookBookColors.accent)
                    }
                    
                    Text("(\(recipe.reviews.count))")
                        .font(CookBookFonts.caption2)
                        .foregroundColor(CookBookColors.textSecondary)
                    
                    Spacer(minLength: 0)
                }
                .frame(height: 16)
            }
            
            Spacer(minLength: 0)
        }
        .frame(height: 200)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var isFavorite: Bool {
        appState.favoriteRecipes.contains(recipe.id)
    }
}

// MARK: - ViewModels and Supporting Views (Simplified for space)

@MainActor
@Observable
class RecipeListViewModel {
    var recipes: [Recipe] = []
    var isLoading = false
    var errorMessage: String?
    
    private let interactor: RecipeInteractorProtocol
    private let router: RecipeRouterProtocol
    
    init(interactor: RecipeInteractorProtocol, router: RecipeRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadRecipes() {
        recipes = AppState.shared.recipes
    }
    
    func filteredRecipes(searchText: String, category: RecipeCategory?, filters: Set<FilterOption>) -> [Recipe] {
        var filtered = recipes
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.description.localizedCaseInsensitiveContains(searchText) ||
                recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply category filter
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply other filters
        for filter in filters {
            switch filter {
            case .favorites:
                filtered = filtered.filter { $0.isFavorite }
            case .quickCook:
                filtered = filtered.filter { $0.totalTime <= 1800 } // 30 minutes
            case .vegetarian:
                filtered = filtered.filter { $0.tags.contains("vegetarian") }
            case .vegan:
                filtered = filtered.filter { $0.tags.contains("vegan") }
            case .glutenFree:
                filtered = filtered.filter { $0.tags.contains("gluten-free") }
            default:
                break
            }
        }
        
        return filtered
    }
}

protocol RecipeInteractorProtocol {
    var presenter: RecipePresenterProtocol? { get set }
    func loadRecipes()
    func searchRecipes(query: String)
    func toggleFavorite(recipe: Recipe)
}

class RecipeInteractor: RecipeInteractorProtocol {
    var presenter: RecipePresenterProtocol?
    
    func loadRecipes() {
        // Implementation
    }
    
    func searchRecipes(query: String) {
        // Implementation
    }
    
    func toggleFavorite(recipe: Recipe) {
        // Implementation
    }
}

protocol RecipePresenterProtocol {
    var viewModel: RecipeListViewModel? { get set }
}

class RecipePresenter: RecipePresenterProtocol {
    weak var viewModel: RecipeListViewModel?
}

struct AddRecipeView: View {
    var body: some View {
        Text("Add Recipe View")
            .navigationTitle("Add Recipe")
    }
}

struct FiltersView: View {
    var body: some View {
        Text("Filters View")
            .navigationTitle("Filters")
    }
}

#Preview {
    let interactor = RecipeInteractor()
    let presenter = RecipePresenter()
    let router = RecipeRouter()
    
    let viewModel = RecipeListViewModel(
        interactor: interactor,
        router: router
    )
    
    interactor.presenter = presenter
    presenter.viewModel = viewModel
    
    return RecipeListView(viewModel: viewModel)
        .environment(AppState.shared)
}
