//
//  AuthenticationRouter.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

// MARK: - Protocol
protocol AuthenticationRouterProtocol {
    func navigateToMain()
    func navigateToForgotPassword()
    func navigateToTermsOfService()
    func navigateToPrivacyPolicy()
}

// MARK: - Implementation
class AuthenticationRouter: AuthenticationRouterProtocol {
    
    // MARK: - Static Factory Method
    @MainActor
    static func createModule() -> AnyView {
        let interactor = AuthenticationInteractor()
        let presenter = AuthenticationPresenter()
        let router = AuthenticationRouter()
        
        let viewModel = AuthenticationViewModel(
            interactor: interactor,
            router: router
        )
        
        // Set up VIP dependencies
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        let view = AuthenticationView(viewModel: viewModel)
        
        return AnyView(view)
    }
    
    // MARK: - Navigation Methods
    func navigateToMain() {
        // In a real app, this would trigger navigation to the main app
        // The navigation is handled by the AppCoordinator observing authentication state
        DispatchQueue.main.async {
            AppState.shared.isAuthenticated = true
        }
    }
    
    func navigateToForgotPassword() {
        // In a more complex app, this would present a forgot password screen
        // For now, we'll handle it in the current screen
        print("Navigate to forgot password screen")
    }
    
    func navigateToTermsOfService() {
        // Navigate to terms of service screen or open web view
        if let url = URL(string: "https://cookbookpro.app/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    func navigateToPrivacyPolicy() {
        // Navigate to privacy policy screen or open web view
        if let url = URL(string: "https://cookbookpro.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
}
