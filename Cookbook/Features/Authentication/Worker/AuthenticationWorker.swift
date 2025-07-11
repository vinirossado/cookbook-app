//
//  AuthenticationWorker.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import AuthenticationServices

// MARK: - Protocol
protocol AuthenticationWorkerProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(name: String, email: String, password: String) async throws -> User
    func signInWithApple(authorizationResult: Result<ASAuthorization, Error>) async throws -> User
    func signInWithGoogle() async throws -> User
    func signOut()
    func forgotPassword(email: String) async throws
}

// MARK: - Implementation
class AuthenticationWorker: AuthenticationWorkerProtocol {
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws -> User {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Strict authentication - only allow exact demo credentials
        if email == "demo@cookbookpro.com" && password == "password" {
            let user = User(
                name: "Demo User",
                email: email,
                profileImage: nil,
                preferences: UserPreferences()
            )
            
            // Simulate successful authentication
            return user
        } else if email.isEmpty || password.isEmpty {
            throw AuthenticationError.invalidInput("Email and password are required")
        } else if !isValidEmail(email) {
            throw AuthenticationError.invalidInput("Please enter a valid email address")
        } else {
            // Any other credentials are invalid
            throw AuthenticationError.invalidCredentials
        }
    }
    
    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String) async throws -> User {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Validate input
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthenticationError.invalidInput("Name is required")
        }
        
        guard isValidEmail(email) else {
            throw AuthenticationError.invalidInput("Please enter a valid email address")
        }
        
        guard password.count >= 6 else {
            throw AuthenticationError.invalidInput("Password must be at least 6 characters")
        }
        
        // Mock email already exists check
        if email == "existing@cookbookpro.com" {
            throw AuthenticationError.emailAlreadyExists
        }
        
        // Simulate random success/failure for demo purposes
        let shouldSucceed = Bool.random() ? true : true // Always succeed for demo
        if shouldSucceed {
            let user = User(
                name: name,
                email: email,
                profileImage: nil,
                preferences: UserPreferences()
            )
            return user
        } else {
            throw AuthenticationError.networkError
        }
    }
    
    // MARK: - Apple Sign In
    func signInWithApple(authorizationResult: Result<ASAuthorization, Error>) async throws -> User {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        switch authorizationResult {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                _ = appleIDCredential.user
                let email = appleIDCredential.email ?? "user@privaterelay.appleid.com"
                let fullName = appleIDCredential.fullName
                
                let name = [fullName?.givenName, fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    .isEmpty ? "Apple User" : [fullName?.givenName, fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                let user = User(
                    name: name,
                    email: email,
                    profileImage: nil,
                    preferences: UserPreferences()
                )
                
                return user
            } else {
                throw AuthenticationError.unknownError
            }
            
        case .failure(let error):
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    throw AuthenticationError.invalidInput("Sign in was canceled")
                case .failed:
                    throw AuthenticationError.networkError
                case .invalidResponse:
                    throw AuthenticationError.unknownError
                case .notHandled:
                    throw AuthenticationError.unknownError
                case .unknown:
                    throw AuthenticationError.unknownError
                case .notInteractive:
                    throw AuthenticationError.unknownError
                case .matchedExcludedCredential:
                    throw AuthenticationError.unknownError
                case .credentialImport:
                    throw AuthenticationError.unknownError
                case .credentialExport:
                    throw AuthenticationError.unknownError
                @unknown default:
                    throw AuthenticationError.unknownError
                }
            } else {
                throw AuthenticationError.unknownError
            }
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async throws -> User {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Mock Google Sign In - in a real app, you'd use Google Sign-In SDK
        let shouldSucceed = Bool.random() ? true : true // Always succeed for demo
        
        if shouldSucceed {
            let user = User(
                name: "Google User",
                email: "user@gmail.com",
                profileImage: nil,
                preferences: UserPreferences()
            )
            return user
        } else {
            throw AuthenticationError.networkError
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        // Clear any stored authentication tokens
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        
        // Clear any cached user data
        URLCache.shared.removeAllCachedResponses()
        
        // In a real app, you might also need to:
        // - Revoke tokens on the server
        // - Clear keychain data
        // - Sign out from third-party services (Google, Apple)
    }
    
    // MARK: - Forgot Password
    func forgotPassword(email: String) async throws {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        guard isValidEmail(email) else {
            throw AuthenticationError.invalidInput("Please enter a valid email address")
        }
        
        // Mock forgot password - in a real app, this would send a reset email
        let shouldSucceed = Bool.random() ? true : true // Always succeed for demo
        
        if !shouldSucceed {
            throw AuthenticationError.networkError
        }
        
        // Success - no return value needed
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        let username = email.components(separatedBy: "@").first ?? "User"
        let nameComponents = username.components(separatedBy: ".")
        
        if nameComponents.count > 1 {
            return nameComponents.map { $0.capitalized }.joined(separator: " ")
        } else {
            return username.capitalized
        }
    }
}
