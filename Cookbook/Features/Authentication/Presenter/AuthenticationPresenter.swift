//
//  AuthenticationPresenter.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation

// MARK: - Protocol
protocol AuthenticationPresenterProtocol {
    var viewModel: AuthenticationViewModel? { get set }
    
    func presentSignInResult(response: Authentication.SignIn.Response) async
    func presentSignUpResult(response: Authentication.SignUp.Response) async
    func presentAppleSignInResult(response: Authentication.AppleSignIn.Response) async
    func presentGoogleSignInResult(response: Authentication.GoogleSignIn.Response) async
    func presentSignOutResult(response: Authentication.SignOut.Response) async
    func presentForgotPasswordResult(response: Authentication.ForgotPassword.Response) async
}

// MARK: - Implementation
class AuthenticationPresenter: AuthenticationPresenterProtocol {
    weak var viewModel: AuthenticationViewModel?
    
    // MARK: - Sign In Presentation
    @MainActor
    func presentSignInResult(response: Authentication.SignIn.Response) async {
        switch response {
        case .success(let user):
            // Update app state with authenticated user
            AppState.shared.currentUser = user
            AppState.shared.isAuthenticated = true
            
            // Update view model
            viewModel?.presentSignInSuccess()
            
        case .failure(let error):
            let errorMessage = mapErrorToUserFriendlyMessage(error)
            viewModel?.presentSignInFailure(error: errorMessage)
        }
    }
    
    // MARK: - Sign Up Presentation
    @MainActor
    func presentSignUpResult(response: Authentication.SignUp.Response) async {
        switch response {
        case .success(let user):
            // Update app state with new user
            AppState.shared.currentUser = user
            AppState.shared.isAuthenticated = true
            
            // Update view model
            viewModel?.presentSignUpSuccess()
            
        case .failure(let error):
            let errorMessage = mapErrorToUserFriendlyMessage(error)
            viewModel?.presentSignUpFailure(error: errorMessage)
        }
    }
    
    // MARK: - Apple Sign In Presentation
    @MainActor
    func presentAppleSignInResult(response: Authentication.AppleSignIn.Response) async {
        switch response {
        case .success(let user):
            // Update app state with authenticated user
            AppState.shared.currentUser = user
            AppState.shared.isAuthenticated = true
            
            // Update view model
            viewModel?.presentAppleSignInSuccess()
            
        case .failure(let error):
            let errorMessage = mapErrorToUserFriendlyMessage(error)
            viewModel?.presentAppleSignInFailure(error: errorMessage)
        }
    }
    
    // MARK: - Google Sign In Presentation
    @MainActor
    func presentGoogleSignInResult(response: Authentication.GoogleSignIn.Response) async {
        switch response {
        case .success(let user):
            // Update app state with authenticated user
            AppState.shared.currentUser = user
            AppState.shared.isAuthenticated = true
            
            // Update view model
            viewModel?.presentGoogleSignInSuccess()
            
        case .failure(let error):
            let errorMessage = mapErrorToUserFriendlyMessage(error)
            viewModel?.presentGoogleSignInFailure(error: errorMessage)
        }
    }
    
    // MARK: - Sign Out Presentation
    @MainActor
    func presentSignOutResult(response: Authentication.SignOut.Response) {
        // Update app state
        AppState.shared.signOut()
    }
    
    // MARK: - Forgot Password Presentation
    @MainActor
    func presentForgotPasswordResult(response: Authentication.ForgotPassword.Response) async {
        switch response {
        case .success:
            viewModel?.presentForgotPasswordSuccess()
            
        case .failure(let error):
            let errorMessage = mapErrorToUserFriendlyMessage(error)
            viewModel?.presentForgotPasswordFailure(error: errorMessage)
        }
    }
    
    // MARK: - Error Mapping
    private func mapErrorToUserFriendlyMessage(_ error: Error) -> String {
        if let authError = error as? AuthenticationError {
            return authError.localizedDescription
        }
        
        // Handle other error types
        switch error.localizedDescription {
        case let description where description.contains("network"):
            return "Network connection error. Please check your internet and try again."
        case let description where description.contains("timeout"):
            return "Request timed out. Please try again."
        default:
            return "Something went wrong. Please try again later."
        }
    }
}
