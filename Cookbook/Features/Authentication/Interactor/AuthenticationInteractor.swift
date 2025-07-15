//
//  AuthenticationInteractor.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import Foundation
import AuthenticationServices

// MARK: - Protocol
protocol AuthenticationInteractorProtocol {
    var presenter: AuthenticationPresenterProtocol? { get set }
    func signIn(request: Authentication.SignIn.Request) async
    func signUp(request: Authentication.SignUp.Request) async
    func signInWithApple(request: Authentication.AppleSignIn.Request) async
    func signInWithGoogle(request: Authentication.GoogleSignIn.Request) async
    func signOut(request: Authentication.SignOut.Request) async
    func forgotPassword(request: Authentication.ForgotPassword.Request) async
}

// MARK: - Implementation
class AuthenticationInteractor: AuthenticationInteractorProtocol {
       func signOut(request: Authentication.SignOut.Request) async {
        worker.signOut()
        let response = Authentication.SignOut.Response()
        await presenter?.presentSignOutResult(response: response)
    }
    
    var presenter: AuthenticationPresenterProtocol?
    private let worker: AuthenticationWorkerProtocol
    
    init(worker: AuthenticationWorkerProtocol = AuthenticationWorker()) {
        self.worker = worker
    }
    
    // MARK: - Sign In
    func signIn(request: Authentication.SignIn.Request) async {
        do {
            let user = try await worker.signIn(email: request.email, password: request.password)
            let response = Authentication.SignIn.Response.success(user: user)
            await presenter?.presentSignInResult(response: response)
        } catch {
            let response = Authentication.SignIn.Response.failure(error: error)
            await presenter?.presentSignInResult(response: response)
        }
    }
    
    // MARK: - Sign Up
    func signUp(request: Authentication.SignUp.Request) async {
        // Validate input
        guard !request.name.isEmpty else {
            let error = AuthenticationError.invalidInput("Name cannot be empty")
            let response = Authentication.SignUp.Response.failure(error: error)
            await presenter?.presentSignUpResult(response: response)
            return
        }
        
        guard isValidEmail(request.email) else {
            let error = AuthenticationError.invalidInput("Please enter a valid email address")
            let response = Authentication.SignUp.Response.failure(error: error)
            await presenter?.presentSignUpResult(response: response)
            return
        }
        
        guard request.password.count >= 6 else {
            let error = AuthenticationError.invalidInput("Password must be at least 6 characters long")
            let response = Authentication.SignUp.Response.failure(error: error)
            await presenter?.presentSignUpResult(response: response)
            return
        }
        
        do {
            let user = try await worker.signUp(name: request.name, email: request.email, password: request.password)
            let response = Authentication.SignUp.Response.success(user: user)
            await presenter?.presentSignUpResult(response: response)
        } catch {
            let response = Authentication.SignUp.Response.failure(error: error)
            await presenter?.presentSignUpResult(response: response)
        }
    }
    
    // MARK: - Apple Sign In
    func signInWithApple(request: Authentication.AppleSignIn.Request) async {
        do {
            let user = try await worker.signInWithApple(authorizationResult: request.authorizationResult)
            let response = Authentication.AppleSignIn.Response.success(user: user)
            await presenter?.presentAppleSignInResult(response: response)
        } catch {
            let response = Authentication.AppleSignIn.Response.failure(error: error)
            await presenter?.presentAppleSignInResult(response: response)
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle(request: Authentication.GoogleSignIn.Request) async {
        do {
            let user = try await worker.signInWithGoogle()
            let response = Authentication.GoogleSignIn.Response.success(user: user)
            await presenter?.presentGoogleSignInResult(response: response)
        } catch {
            let response = Authentication.GoogleSignIn.Response.failure(error: error)
            await presenter?.presentGoogleSignInResult(response: response)
        }
    }
    
    // MARK: - Forgot Password
    func forgotPassword(request: Authentication.ForgotPassword.Request) async {
        guard isValidEmail(request.email) else {
            let error = AuthenticationError.invalidInput("Please enter a valid email address")
            let response = Authentication.ForgotPassword.Response.failure(error: error)
            await presenter?.presentForgotPasswordResult(response: response)
            return
        }
        
        do {
            try await worker.forgotPassword(email: request.email)
            let response = Authentication.ForgotPassword.Response.success
            await presenter?.presentForgotPasswordResult(response: response)
        } catch {
            let response = Authentication.ForgotPassword.Response.failure(error: error)
            await presenter?.presentForgotPasswordResult(response: response)
        }
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Authentication Models
enum Authentication {
    
    enum SignIn {
        struct Request {
            let email: String
            let password: String
        }
        
        enum Response {
            case success(user: User)
            case failure(error: Error)
        }
        
        struct ViewModel {
            let isLoading: Bool
            let errorMessage: String?
            let isAuthenticated: Bool
        }
    }
    
    enum SignUp {
        struct Request {
            let name: String
            let email: String
            let password: String
        }
        
        enum Response {
            case success(user: User)
            case failure(error: Error)
        }
        
        struct ViewModel {
            let isLoading: Bool
            let errorMessage: String?
            let isAuthenticated: Bool
        }
    }
    
    enum AppleSignIn {
        struct Request {
            let authorizationResult: Result<ASAuthorization, Error>
        }
        
        enum Response {
            case success(user: User)
            case failure(error: Error)
        }
        
        struct ViewModel {
            let isLoading: Bool
            let errorMessage: String?
            let isAuthenticated: Bool
        }
    }
    
    enum GoogleSignIn {
        struct Request {}
        
        enum Response {
            case success(user: User)
            case failure(error: Error)
        }
        
        struct ViewModel {
            let isLoading: Bool
            let errorMessage: String?
            let isAuthenticated: Bool
        }
    }
    
    enum SignOut {
        struct Request {}
        
        struct Response {}
        
        struct ViewModel {}
    }
    
    enum ForgotPassword {
        struct Request {
            let email: String
        }
        
        enum Response {
            case success
            case failure(error: Error)
        }
        
        struct ViewModel {
            let isLoading: Bool
            let errorMessage: String?
            let isSuccess: Bool
        }
    }
}

// MARK: - Authentication Errors
enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case invalidInput(String)
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .userNotFound:
            return "No account found with this email address."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .invalidInput(let message):
            return message
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
}
