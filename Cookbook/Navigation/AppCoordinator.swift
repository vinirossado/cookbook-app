//
//  AppCoordinator.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct AppCoordinator: View {
    @Environment(AppState.self) private var appState
    @State private var notificationManager = NotificationManager.shared
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                AuthenticationRouter.createModule()
                    .transition(.opacity.combined(with: .slide))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.isAuthenticated)
        .onAppear {
            setupNotifications()
            setupNotificationObservers()
        }
        .environmentObject(notificationManager)
    }
    
    private func setupNotifications() {
        Task {
            await notificationManager.requestAuthorization()
        }
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = notificationManager
    }
    
    private func setupNotificationObservers() {
        // Listen for notification-triggered navigation
        NotificationCenter.default.addObserver(forName: .navigateToMeal, object: nil, queue: .main) { notification in
            if notification.object is String {
                // Navigate to meal planner with specific meal
                Task { @MainActor in
                    appState.selectedTab = .planner
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .navigateToShopping, object: nil, queue: .main) { _ in
            Task { @MainActor in
                appState.selectedTab = .shopping
            }
        }
        
        NotificationCenter.default.addObserver(forName: .navigateToTodayMeal, object: nil, queue: .main) { notification in
            if notification.object is String {
                Task { @MainActor in
                    appState.selectedTab = .today
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .cookingTimerCompleted, object: nil, queue: .main) { notification in
            // Handle cooking timer completion
            notificationManager.triggerHapticFeedback(.success)
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var bindableAppState = appState
        return TabView(selection: $bindableAppState.selectedTab) {
            // Recipes Tab
            RecipeRouter.createModule()
                .tabItem {
                    Image(systemName: appState.selectedTab == .recipes ? TabItem.recipes.selectedIcon : TabItem.recipes.icon)
                    Text(TabItem.recipes.rawValue)
                }
                .tag(TabItem.recipes)
            
            // Shopping Tab
            ShoppingRouter.createModule()
                .tabItem {
                    Image(systemName: appState.selectedTab == .shopping ? TabItem.shopping.selectedIcon : TabItem.shopping.icon)
                    Text(TabItem.shopping.rawValue)
                    
                    // Badge for shopping items count
                    if appState.shoppingCart.totalItems > 0 {
                        Text("\(appState.shoppingCart.totalItems)")
                    }
                }
                .tag(TabItem.shopping)
            
            // Meal Planner Tab
            MealPlannerRouter.createModule()
                .tabItem {
                    Image(systemName: appState.selectedTab == .planner ? TabItem.planner.selectedIcon : TabItem.planner.icon)
                    Text(TabItem.planner.rawValue)
                }
                .tag(TabItem.planner)
            
            // Today Tab
            TodayView(viewModel: createTodayViewModel())
                .tabItem {
                    Image(systemName: appState.selectedTab == .today ? TabItem.today.selectedIcon : TabItem.today.icon)
                    Text(TabItem.today.rawValue)
                    
                    // Badge for want today items
                    if appState.wantTodayMeals.count > 0 {
                        Text("\(appState.wantTodayMeals.count)")
                    }
                }
                .tag(TabItem.today)
            
            // Profile Tab
            Text("Profile - Coming Soon")
                .tabItem {
                    Image(systemName: appState.selectedTab == .profile ? TabItem.profile.selectedIcon : TabItem.profile.icon)
                    Text(TabItem.profile.rawValue)
                }
                .tag(TabItem.profile)
        }
        .accentColor(CookBookColors.primary)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(CookBookColors.surface)
        
        // Configure selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(CookBookColors.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(CookBookColors.primary)
        ]
        
        // Configure normal item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(CookBookColors.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(CookBookColors.textSecondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func createTodayViewModel() -> TodayViewModel {
        let interactor = TodayInteractor()
        let presenter = TodayPresenter()
        let router = TodayRouter()
        
        let viewModel = TodayViewModel(
            interactor: interactor,
            router: router
        )
        
        presenter.viewModel = viewModel
        interactor.presenter = presenter
        
        return viewModel
    }
}

#Preview {
    AppCoordinator()
        .environment(AppState.shared)
}
