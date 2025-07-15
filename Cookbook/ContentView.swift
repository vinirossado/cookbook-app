//
//  ContentView.swift
//  Cookbook
//
//  Created by Vinicius Rossado on 08.07.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        if appState.isAuthenticated {
            AppCoordinator()
        } else {
            AuthenticationView(
                viewModel: AuthenticationViewModel(
                    interactor: AuthenticationInteractor(),
                    router: AuthenticationRouter()
                )
            )
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState.shared)
}
