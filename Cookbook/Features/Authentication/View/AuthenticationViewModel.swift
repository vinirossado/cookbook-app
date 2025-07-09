//
//  AuthenticationViewModel.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
@Observable
class AuthenticationViewModel {
    // MARK: - Published Properties
    var isLoading = false
    var errorMessage: String?
    var isAuthenticated = false
    
    // MARK: - Dependencies
    private let interactor: AuthenticationInteractorProtocol
    private let router: AuthenticationRouterProtocol
    
    // MARK: - Initialization
    init(interactor: AuthenticationInteractorProtocol, router: AuthenticationRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Authentication Actions
    func signIn(email: String, password: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = Authentication.SignIn.Request(email: email, password: password)
        await interactor.signIn(request: request)
    }
    
    func signUp(name: String, email: String, password: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = Authentication.SignUp.Request(name: name, email: email, password: password)
        await interactor.signUp(request: request)
    }
    
    func signInWithApple(result: Result<ASAuthorization, Error>) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = Authentication.AppleSignIn.Request(authorizationResult: result)
        await interactor.signInWithApple(request: request)
    }
    
    func signInWithGoogle() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = Authentication.GoogleSignIn.Request()
        await interactor.signInWithGoogle(request: request)
    }
    
    func signOut() async  {
        let request = Authentication.SignOut.Request()
        await interactor.signOut(request: request)
    }
    
    func forgotPassword(email: String) async {
        let request = Authentication.ForgotPassword.Request(email: email)
        await interactor.forgotPassword(request: request)
    }
    
    // MARK: - Error Handling
    func showError(_ message: String) {
        errorMessage = message
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Navigation
    func navigateToMain() {
        router.navigateToMain()
    }
    
    func navigateToForgotPassword() {
        router.navigateToForgotPassword()
    }
    
    func navigateToTermsOfService() {
        router.navigateToTermsOfService()
    }
    
    func navigateToPrivacyPolicy() {
        router.navigateToPrivacyPolicy()
    }
}

// MARK: - Presentation Methods
extension AuthenticationViewModel {
    func presentSignInSuccess() {
        isLoading = false
        isAuthenticated = true
    }
    
    func presentSignInFailure(error: String) {
        isLoading = false
        errorMessage = error
    }
    
    func presentSignUpSuccess() {
        isLoading = false
        isAuthenticated = true
    }
    
    func presentSignUpFailure(error: String) {
        isLoading = false
        errorMessage = error
    }
    
    func presentAppleSignInSuccess() {
        isLoading = false
        isAuthenticated = true
    }
    
    func presentAppleSignInFailure(error: String) {
        isLoading = false
        errorMessage = error
    }
    
    func presentGoogleSignInSuccess() {
        isLoading = false
        isAuthenticated = true
    }
    
    func presentGoogleSignInFailure(error: String) {
        isLoading = false
        errorMessage = error
    }
    
    func presentForgotPasswordSuccess() {
        isLoading = false
        // Show success message or navigate to email sent screen
    }
    
    func presentForgotPasswordFailure(error: String) {
        isLoading = false
        errorMessage = error
    }
}
