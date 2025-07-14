//
//  CookbookWatchApp.swift
//  CookbookWatch Watch App
//
//  Created by Vinicius Rossado on 14/07/2025.
//

import SwiftUI

@main
struct CookbookWatchApp: App {
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
