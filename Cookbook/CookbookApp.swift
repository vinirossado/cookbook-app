//
//  CookbookApp.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import UserNotifications

@main
struct CookBookProApp: App {
    @State private var appState = AppState.shared
    
    init() {
        setupNotifications()
        setupAppearance()
        setupWatchConnectivity()
    }
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator()
                .environment(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
    
    private func setupNotifications() {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    private func setupAppearance() {
        // Configure navigation appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(CookBookColors.surface)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(CookBookColors.text)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(CookBookColors.surface)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    private func setupWatchConnectivity() {
        // Initialize and activate Watch Connectivity
        WatchConnectivityManager.shared.activateSession()
    }
}
