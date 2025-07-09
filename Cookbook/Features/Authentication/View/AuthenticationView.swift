//
//  AuthenticationView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @State private var viewModel: AuthenticationViewModel
    @State private var isShowingSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var confirmPassword = ""
    @State private var isSecureField = true
    
    init(viewModel: AuthenticationViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                        .frame(height: geometry.size.height * 0.4)
                    
                    // Form Section
                    formSection
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    Spacer(minLength: 50)
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .background(
            LinearGradient(
                colors: [CookBookColors.primary.opacity(0.1), CookBookColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("Authentication Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // App Logo/Icon
            ZStack {
                Circle()
                    .fill(CookBookColors.primary)
                    .frame(width: 120, height: 120)
                    .shadow(color: CookBookColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("CookBook Pro")
                    .font(CookBookFonts.largeTitle)
                    .foregroundColor(CookBookColors.text)
                    .fontWeight(.bold)
                
                Text("Discover, Cook, Share")
                    .font(CookBookFonts.subheadline)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 24) {
            // Toggle between Sign In and Sign Up
            segmentedControl
            
            // Form Fields
            VStack(spacing: 16) {
                if isShowingSignUp {
                    signUpFields
                } else {
                    signInFields
                }
            }
            
            // Action Buttons
            actionButtons
            
            // Demo Account Info
            demoAccountInfo
            
            // Terms and Privacy
            if isShowingSignUp {
                termsAndPrivacy
            }
        }
    }
    
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            Button(action: { withAnimation { isShowingSignUp = false } }) {
                Text("Sign In")
                    .font(CookBookFonts.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isShowingSignUp ? Color.clear : CookBookColors.primary)
                    )
                    .foregroundColor(isShowingSignUp ? CookBookColors.textSecondary : .white)
            }
            
            Button(action: { withAnimation { isShowingSignUp = true } }) {
                Text("Sign Up")
                    .font(CookBookFonts.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(!isShowingSignUp ? Color.clear : CookBookColors.primary)
                    )
                    .foregroundColor(!isShowingSignUp ? CookBookColors.textSecondary : .white)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.surface)
        )
        .padding(.horizontal, 4)
    }
    
    private var signInFields: some View {
        VStack(spacing: 16) {
            CustomTextField(
                title: "Email",
                text: $email,
                placeholder: "Enter your email",
                keyboardType: .emailAddress,
                systemImage: "envelope"
            )
            
            CustomSecureField(
                title: "Password",
                text: $password,
                placeholder: "Enter your password",
                isSecure: $isSecureField,
                systemImage: "lock"
            )
            
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .font(CookBookFonts.caption1)
                .foregroundColor(CookBookColors.primary)
            }
        }
    }
    
    private var signUpFields: some View {
        VStack(spacing: 16) {
            CustomTextField(
                title: "Full Name",
                text: $name,
                placeholder: "Enter your full name",
                keyboardType: .default,
                systemImage: "person"
            )
            
            CustomTextField(
                title: "Email",
                text: $email,
                placeholder: "Enter your email",
                keyboardType: .emailAddress,
                systemImage: "envelope"
            )
            
            CustomSecureField(
                title: "Password",
                text: $password,
                placeholder: "Create a password",
                isSecure: $isSecureField,
                systemImage: "lock"
            )
            
            CustomSecureField(
                title: "Confirm Password",
                text: $confirmPassword,
                placeholder: "Confirm your password",
                isSecure: .constant(true),
                systemImage: "lock.fill"
            )
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                if isShowingSignUp {
                    handleSignUp()
                } else {
                    handleSignIn()
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(isShowingSignUp ? "Create Account" : "Sign In")
                        .font(CookBookFonts.buttonText)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [CookBookColors.primary, CookBookColors.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .foregroundColor(.white)
                .shadow(color: CookBookColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
        }
    }
    
    private var demoAccountInfo: some View {
        VStack(spacing: 12) {
            Text("Demo Account")
                .font(CookBookFonts.headline)
                .foregroundColor(CookBookColors.text)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Email:")
                        .font(CookBookFonts.callout)
                        .foregroundColor(CookBookColors.textSecondary)
                    
                    Spacer()
                    
                    Text("demo@cookbookpro.com")
                        .font(CookBookFonts.callout)
                        .fontWeight(.medium)
                        .foregroundColor(CookBookColors.text)
                }
                
                HStack {
                    Text("Password:")
                        .font(CookBookFonts.callout)
                        .foregroundColor(CookBookColors.textSecondary)
                    
                    Spacer()
                    
                    Text("password")
                        .font(CookBookFonts.callout)
                        .fontWeight(.medium)
                        .foregroundColor(CookBookColors.text)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.primary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(CookBookColors.primary.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Button("Use Demo Account") {
                email = "demo@cookbookpro.com"
                password = "password"
            }
            .font(CookBookFonts.callout)
            .foregroundColor(CookBookColors.primary)
        }
    }
    
    private var termsAndPrivacy: some View {
        VStack(spacing: 8) {
            Text("By creating an account, you agree to our")
                .font(CookBookFonts.caption2)
                .foregroundColor(CookBookColors.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Button("Terms of Service") {
                    // Handle terms of service
                }
                .foregroundColor(CookBookColors.primary)
                
                Text("and")
                    .foregroundColor(CookBookColors.textSecondary)
                
                Button("Privacy Policy") {
                    // Handle privacy policy
                }
                .foregroundColor(CookBookColors.primary)
            }
            .font(CookBookFonts.caption2)
        }
    }
    
    // MARK: - Form Validation
    private var isFormValid: Bool {
        if isShowingSignUp {
            return !name.isEmpty && 
                   !email.isEmpty && 
                   !password.isEmpty && 
                   !confirmPassword.isEmpty &&
                   password == confirmPassword &&
                   isValidEmail(email) &&
                   password.count >= 6
        } else {
            return !email.isEmpty && 
                   !password.isEmpty &&
                   isValidEmail(email)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Actions
    private func handleSignIn() {
        Task {
            await viewModel.signIn(email: email, password: password)
        }
    }
    
    private func handleSignUp() {
        guard password == confirmPassword else {
            viewModel.showError("Passwords do not match")
            return
        }
        
        Task {
            await viewModel.signUp(name: name, email: email, password: password)
        }
    }
}

// MARK: - Custom Components
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(CookBookFonts.callout)
                .foregroundColor(CookBookColors.text)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(CookBookColors.textSecondary)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.cardBackground)
                    .stroke(CookBookColors.textSecondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @Binding var isSecure: Bool
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(CookBookFonts.callout)
                .foregroundColor(CookBookColors.text)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(CookBookColors.textSecondary)
                    .frame(width: 20)
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                if title.contains("Password") && !title.contains("Confirm") {
                    Button(action: { isSecure.toggle() }) {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(CookBookColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.cardBackground)
                    .stroke(CookBookColors.textSecondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    let interactor = AuthenticationInteractor()
    let presenter = AuthenticationPresenter()
    let router = AuthenticationRouter()
    
    let viewModel = AuthenticationViewModel(
        interactor: interactor,
        router: router
    )
    
    interactor.presenter = presenter
    presenter.viewModel = viewModel
    
    return AuthenticationView(viewModel: viewModel)
}
