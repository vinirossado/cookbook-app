//
//  RecipeListView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation

struct RecipeListView: View {
    @State private var viewModel: RecipeListViewModel
    @Environment(AppState.self) private var appState
    @State private var showingAddRecipe = false
    @State private var showingFilters = false
    @State private var selectedRecipe: Recipe?
    
    // Visual feedback states
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastIcon = ""
    @State private var recentlyTappedCards: Set<UUID> = []
    
    init(viewModel: RecipeListViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Search Bar
                searchSection
                    .padding(.top, 16)
                
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
        .navigationDestination(item: $selectedRecipe) { recipe in
            RecipeDetailRouter.createModule(for: recipe)
        }
        .overlay(
            // Toast notification
            VStack {
                Spacer()
                if showingToast {
                    ToastView(message: toastMessage, icon: toastIcon)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.easeInOut(duration: 0.3), value: showingToast)
                        .padding(.bottom, 100)
                }
            }
        )
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
            
            // Clear All Filters Button
            if hasActiveFilters {
                Button(action: clearAllFilters) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(CookBookColors.accent)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(CookBookColors.surface)
                        )
                }
            }
            
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
    
    private var quickFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Country filter button
                Button(action: { showingFilters = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "flag")
                            .font(.caption)
                        
                        if let selectedCountry = appState.selectedCountry {
                            Text(selectedCountry.flag)
                                .font(.caption)
                            Text(selectedCountry.rawValue)
                                .font(CookBookFonts.caption1)
                                .fontWeight(.medium)
                        } else if let selectedContinent = appState.selectedContinent {
                            Image(systemName: selectedContinent.icon)
                                .font(.caption)
                            Text(selectedContinent.rawValue)
                                .font(CookBookFonts.caption1)
                                .fontWeight(.medium)
                        } else {
                            Text("By Country")
                                .font(CookBookFonts.caption1)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(appState.countryFilterEnabled ? CookBookColors.primary : CookBookColors.surface)
                    )
                    .foregroundColor(appState.countryFilterEnabled ? .white : CookBookColors.text)
                }
                
                // Category filter buttons
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        category: category,
                        isSelected: appState.selectedCategory == category
                    ) {
                        if appState.selectedCategory == category {
                            appState.selectedCategory = nil
                        } else {
                            appState.selectedCategory = category
                        }
                    }
                }
                
                // Difficulty filter buttons
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    DifficultyFilterChip(
                        difficulty: difficulty,
                        isSelected: appState.selectedDifficulty == difficulty
                    ) {
                        if appState.selectedDifficulty == difficulty {
                            appState.selectedDifficulty = nil
                        } else {
                            appState.selectedDifficulty = difficulty
                        }
                    }
                }
                
                // Other quick filter options
                ForEach(FilterOption.allCases.filter { $0 != .byCountry && $0 != .byContinent }, id: \.self) { filter in
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
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appState.toggleFavorite(recipe)
                        }
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        // Show toast
                        let isFavorite = appState.favoriteRecipes.contains(recipe.id)
                        showToast(
                            message: isFavorite ? "Added to favorites" : "Removed from favorites",
                            icon: isFavorite ? "heart.fill" : "heart"
                        )
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
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        // Show toast
                        showToast(
                            message: "Added to Want Today",
                            icon: "clock.fill"
                        )
                        
                        // Mark as recently tapped for visual feedback
                        recentlyTappedCards.insert(recipe.id)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            recentlyTappedCards.remove(recipe.id)
                        }
                    },
                    onTap: {
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        selectedRecipe = recipe
                        print("✅ selectedRecipe is now: \(selectedRecipe?.title ?? "nil")")
                    },
                    isRecentlyTapped: recentlyTappedCards.contains(recipe.id)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    private var filteredRecipes: [Recipe] {
        return appState.filteredRecipes()
    }
    
    private var hasActiveFilters: Bool {
        return !appState.searchText.isEmpty ||
               appState.selectedCategory != nil ||
               appState.selectedDifficulty != nil ||
               !appState.filterOptions.isEmpty ||
               appState.countryFilterEnabled
    }
    
    // MARK: - Helper Methods
    private func clearAllFilters() {
        appState.searchText = ""
        appState.selectedCategory = nil
        appState.selectedDifficulty = nil
        appState.filterOptions.removeAll()
        appState.clearCountryFilters()
        
        // Show feedback
        showToast(message: "All filters cleared", icon: "xmark.circle")
    }
    
    private func showToast(message: String, icon: String) {
        toastMessage = message
        toastIcon = icon
        withAnimation(.easeInOut(duration: 0.3)) {
            showingToast = true
        }
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingToast = false
            }
        }
    }
}

// MARK: - Recipe Card Component
struct RecipeCard: View {
    let recipe: Recipe
    let onFavoriteToggle: () -> Void
    let onWantToday: () -> Void
    let onTap: () -> Void
    let isRecentlyTapped: Bool
    
    @State private var isFavorite: Bool
    
    init(recipe: Recipe, onFavoriteToggle: @escaping () -> Void, onWantToday: @escaping () -> Void, onTap: @escaping () -> Void, isRecentlyTapped: Bool = false) {
        self.recipe = recipe
        self.onFavoriteToggle = onFavoriteToggle
        self.onWantToday = onWantToday
        self.onTap = onTap
        self.isRecentlyTapped = isRecentlyTapped
        self._isFavorite = State(initialValue: recipe.isFavorite)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe Image with overlay buttons
            ZStack(alignment: .topTrailing) {
                RecipeImageView(
                    imageUrl: recipe.images.first?.url ?? "placeholder",
                    height: 120
                )
                
                // Overlay buttons
                HStack(spacing: 8) {
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
                    // Country flag
                    Text(recipe.countryOfOrigin.flag)
                        .font(.caption2)
                    
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
        .scaleEffect(isRecentlyTapped ? 0.98 : 1.0)
        .onTapGesture {
            onTap()
        }
        .onAppear {
            isFavorite = AppState.shared.favoriteRecipes.contains(recipe.id)
        }
        .onChange(of: AppState.shared.favoriteRecipes) { _, _ in
            isFavorite = AppState.shared.favoriteRecipes.contains(recipe.id)
        }
    }
}

// MARK: - Filter Components
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
                    .font(CookBookFonts.caption1)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? CookBookColors.primary : CookBookColors.surface)
            )
            .foregroundColor(isSelected ? .white : CookBookColors.text)
        }
    }
}

struct CategoryFilterChip: View {
    let category: RecipeCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
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
                    .fill(isSelected ? CookBookColors.primary : CookBookColors.surface)
            )
            .foregroundColor(isSelected ? .white : CookBookColors.text)
        }
    }
}

struct DifficultyFilterChip: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: difficulty.icon)
                    .font(.caption)
                
                Text(difficulty.rawValue)
                    .font(CookBookFonts.caption1)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? CookBookColors.primary : CookBookColors.surface)
            )
            .foregroundColor(isSelected ? .white : CookBookColors.text)
        }
    }
}

// MARK: - FiltersView (Country & Region Only)
struct FiltersView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Country & Region Filters
                    countryFilterSection
                    
                    // Clear Country Filters Button
                    clearCountryFiltersSection
                }
                .padding()
            }
            .navigationTitle("Country & Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var countryFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Country & Region")
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(CookBookColors.text)
            
            // Country Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Filter by Country")
                    .font(CookBookFonts.subheadline)
                    .foregroundColor(CookBookColors.textSecondary)
                
                if appState.availableCountries().isEmpty {
                    Text("No recipes available")
                        .font(CookBookFonts.caption1)
                        .foregroundColor(CookBookColors.textSecondary)
                        .italic()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        // Clear selection option
                        CountryFilterChip(
                            country: nil,
                            isSelected: appState.selectedCountry == nil && appState.selectedContinent == nil,
                            action: {
                                appState.clearCountryFilters()
                            }
                        )
                        
                        ForEach(appState.availableCountries(), id: \.self) { country in
                            CountryFilterChip(
                                country: country,
                                isSelected: appState.selectedCountry == country,
                                action: {
                                    appState.setCountryFilter(country)
                                }
                            )
                        }
                    }
                }
            }
            
            // Continent Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Filter by Continent")
                    .font(CookBookFonts.subheadline)
                    .foregroundColor(CookBookColors.textSecondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(appState.availableContinents(), id: \.self) { continent in
                        ContinentFilterChip(
                            continent: continent,
                            isSelected: appState.selectedContinent == continent,
                            action: {
                                appState.setContinentFilter(continent)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.surface)
        )
    }
    
    private var clearCountryFiltersSection: some View {
        Button(action: {
            appState.clearCountryFilters()
        }) {
            Text("Clear Country Filters")
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CookBookColors.accent)
                )
        }
    }
}

// MARK: - Country Filter Components
struct CountryFilterChip: View {
    let country: Country?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let country = country {
                    Text(country.flag)
                        .font(.caption)
                    
                    Text(country.rawValue)
                        .font(CookBookFonts.caption1)
                        .fontWeight(.medium)
                        .lineLimit(1)
                } else {
                    Image(systemName: "xmark.circle")
                        .font(.caption)
                    
                    Text("All Countries")
                        .font(CookBookFonts.caption1)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? CookBookColors.primary : CookBookColors.cardBackground)
            )
            .foregroundColor(isSelected ? .white : CookBookColors.text)
        }
    }
}

struct ContinentFilterChip: View {
    let continent: Continent
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: continent.icon)
                    .font(.caption)
                
                Text(continent.rawValue)
                    .font(CookBookFonts.caption1)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? CookBookColors.primary : CookBookColors.cardBackground)
            )
            .foregroundColor(isSelected ? .white : CookBookColors.text)
        }
    }
}

// MARK: - Toast Component
struct ToastView: View {
    let message: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(CookBookColors.primary)
            
            Text(message)
                .font(CookBookFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(CookBookColors.text)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(CookBookColors.primary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
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
