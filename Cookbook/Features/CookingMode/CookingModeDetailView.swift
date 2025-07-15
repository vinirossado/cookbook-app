//
//  CookingModeDetailView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct CookingModeDetailView: View {
    let recipe: Recipe
    let viewModel: RecipeDetailViewModel
    @State private var cookingViewModel = CookingModeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                CookBookColors.background.ignoresSafeArea()
                
                if cookingViewModel.currentStep < recipe.instructions.count {
                    // Active cooking mode
                    VStack(spacing: 0) {
                        // Progress Bar
                        progressBar
                        
                        // Current Step Content
                        currentStepView
                        
                        // Navigation Controls
                        navigationControls
                    }
                } else {
                    // Completion View
                    completionView
                }
            }
            .navigationTitle("Cooking Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        cookingViewModel.exitCookingMode()
                        dismiss()
                    }
                    .foregroundColor(CookBookColors.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { cookingViewModel.toggleKeepScreenOn() }) {
                        Image(systemName: cookingViewModel.keepScreenOn ? "sun.max.fill" : "sun.max")
                            .foregroundColor(cookingViewModel.keepScreenOn ? CookBookColors.warning : CookBookColors.textSecondary)
                    }
                }
            }
        }
        .onAppear {
            cookingViewModel.startCookingMode(for: recipe)
        }
        .onDisappear {
            cookingViewModel.exitCookingMode()
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 12) {
            // Progress Indicator
            HStack {
                Text("Step \(cookingViewModel.currentStep + 1) of \(recipe.instructions.count)")
                    .font(CookBookFonts.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.textSecondary)
                
                Spacer()
                
                Text("\(Int(cookingViewModel.progress * 100))% Complete")
                    .font(CookBookFonts.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.primary)
            }
            
            // Progress Bar
            ProgressView(value: cookingViewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: CookBookColors.primary))
                .scaleEffect(y: 2.0)
        }
        .padding()
        .background(CookBookColors.surface)
    }
    
    private var currentStepView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Recipe Image (smaller in cooking mode)
                RecipeImageView(
                    imageUrl: recipe.images.first?.url ?? "photo",
                    height: 120,
                    cornerRadius: 16
                )
                
                // Current Step
                VStack(spacing: 16) {
                    // Step Number Badge
                    ZStack {
                        Circle()
                            .fill(CookBookColors.primary)
                            .frame(width: 60, height: 60)
                        
                        Text("\(cookingViewModel.currentStep + 1)")
                            .font(CookBookFonts.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Step Instructions
                    Text(recipe.instructions[cookingViewModel.currentStep].instruction)
                        .font(CookBookFonts.title3)
                        .fontWeight(.medium)
                        .foregroundColor(CookBookColors.text)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                }
                
                // Timer Section (if step has timing)
                if let timerDuration = cookingViewModel.currentStepTimer {
                    timerSection(duration: timerDuration)
                }
                
                // Ingredients for Current Step (if any)
                if !cookingViewModel.currentStepIngredients.isEmpty {
                    currentStepIngredientsView
                }
                
                // Tips or Notes for Current Step
                if let tip = cookingViewModel.currentStepTip {
                    tipSection(tip: tip)
                }
                
                Spacer(minLength: 120) // Space for controls
            }
            .padding()
        }
    }
    
    private func timerSection(duration: TimeInterval) -> some View {
        VStack(spacing: 16) {
            // Timer Display
            VStack(spacing: 8) {
                Text("Timer")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(CookBookColors.text)
                
                Text(cookingViewModel.formattedTimerTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(cookingViewModel.timerState == .expired ? CookBookColors.accent : CookBookColors.primary)
                    .animation(.easeInOut(duration: 0.3), value: cookingViewModel.formattedTimerTime)
            }
            
            // Timer Controls
            HStack(spacing: 20) {
                if cookingViewModel.timerState == .stopped {
                    Button("Start Timer") {
                        cookingViewModel.startTimer(duration: duration)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button(cookingViewModel.timerState == .running ? "Pause" : "Resume") {
                        cookingViewModel.toggleTimer()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Reset") {
                        cookingViewModel.resetTimer()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cookingViewModel.timerState == .expired ? CookBookColors.accent.opacity(0.1) : CookBookColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(cookingViewModel.timerState == .expired ? CookBookColors.accent : Color.clear, lineWidth: 2)
                )
        )
        .overlay(
            // Pulsing animation when timer expires
            Group {
                if cookingViewModel.timerState == .expired {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(CookBookColors.accent, lineWidth: 3)
                        .scaleEffect(cookingViewModel.pulseAnimation ? 1.05 : 1.0)
                        .opacity(cookingViewModel.pulseAnimation ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: cookingViewModel.pulseAnimation)
                }
            }
        )
    }
    
    private var currentStepIngredientsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients for this step:")
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(CookBookColors.text)
            
            VStack(spacing: 8) {
                ForEach(cookingViewModel.currentStepIngredients, id: \.id) { ingredient in
                    HStack {
                        Text("• \(ingredient.amount) \(ingredient.unit) \(ingredient.name)")
                            .font(CookBookFonts.callout)
                            .foregroundColor(CookBookColors.text)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.primary.opacity(0.1))
        )
    }
    
    private func tipSection(tip: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(CookBookColors.warning)
                
                Text("Tip")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(CookBookColors.text)
            }
            
            Text(tip)
                .font(CookBookFonts.callout)
                .foregroundColor(CookBookColors.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.warning.opacity(0.1))
        )
    }
    
    private var navigationControls: some View {
        HStack(spacing: 16) {
            // Previous Step
            Button(action: { cookingViewModel.previousStep() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(CookBookFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(cookingViewModel.canGoPrevious ? CookBookColors.primary : CookBookColors.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cookingViewModel.canGoPrevious ? CookBookColors.surface : CookBookColors.surface.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(cookingViewModel.canGoPrevious ? CookBookColors.primary.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }
            .disabled(!cookingViewModel.canGoPrevious)
            
            // Next Step / Complete
            Button(action: { cookingViewModel.nextStep() }) {
                HStack {
                    Text(cookingViewModel.isLastStep ? "Complete" : "Next")
                    
                    if !cookingViewModel.isLastStep {
                        Image(systemName: "chevron.right")
                    }
                }
                .font(CookBookFonts.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: cookingViewModel.isLastStep ? 
                                    [CookBookColors.success, CookBookColors.success.opacity(0.8)] :
                                    [CookBookColors.primary, CookBookColors.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding()
        .background(CookBookColors.surface)
    }
    
    private var completionView: some View {
        VStack(spacing: 32) {
            // Success Animation
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(CookBookColors.success.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(CookBookColors.success)
                }
                .scaleEffect(cookingViewModel.completionAnimation ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: cookingViewModel.completionAnimation)
                
                Text("Recipe Complete!")
                    .font(CookBookFonts.title1)
                    .fontWeight(.bold)
                    .foregroundColor(CookBookColors.text)
                
                Text("Congratulations! You've successfully prepared \(recipe.title)")
                    .font(CookBookFonts.callout)
                    .foregroundColor(CookBookColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Completion Actions
            VStack(spacing: 16) {
                Button("Rate this Recipe") {
                    cookingViewModel.showRatingSheet()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Share Your Creation") {
                    cookingViewModel.shareRecipe()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Cook Again") {
                    cookingViewModel.restartCookingMode()
                }
                .buttonStyle(TertiaryButtonStyle())
                
                Button("Done") {
                    dismiss()
                }
                .font(CookBookFonts.callout)
                .foregroundColor(CookBookColors.textSecondary)
            }
        }
        .padding()
        .onAppear {
            cookingViewModel.startCompletionAnimation()
        }
    }
}

// MARK: - Cooking Mode View Model
@MainActor
@Observable
class CookingModeViewModel {
    // State
    var currentStep = 0
    var timerState: TimerState = .stopped
    var currentStepTimer: TimeInterval?
    var timerDuration: TimeInterval = 0
    var remainingTime: TimeInterval = 0
    var keepScreenOn = true
    var pulseAnimation = false
    var completionAnimation = false
    
    // Timer
    private var timer: Timer?
    private var timerStartTime: Date?
    private var pausedTime: TimeInterval = 0
    
    // Recipe context
    private var recipe: Recipe?
    
    var progress: Double {
        guard let recipe = recipe else { return 0 }
        return Double(currentStep) / Double(recipe.instructions.count)
    }
    
    var canGoPrevious: Bool {
        return currentStep > 0
    }
    
    var isLastStep: Bool {
        guard let recipe = recipe else { return false }
        return currentStep >= recipe.instructions.count - 1
    }
    
    var formattedTimerTime: String {
        return TimeInterval.formatTime(remainingTime)
    }
    
    var currentStepIngredients: [Ingredient] {
        guard let recipe = recipe else { return [] }
        // In a real app, this would be determined by analyzing the instruction text
        // For demo purposes, we'll return some ingredients for certain steps
        if currentStep < 3 && !recipe.ingredients.isEmpty {
            let startIndex = min(currentStep * 2, recipe.ingredients.count - 1)
            let endIndex = min(startIndex + 2, recipe.ingredients.count)
            return Array(recipe.ingredients[startIndex..<endIndex])
        }
        return []
    }
    
    var currentStepTip: String? {
        // In a real app, these would be stored with the recipe
        let tips = [
            "Make sure all ingredients are at room temperature for best results.",
            "Preheat your oven if needed for upcoming steps.",
            "Taste as you go and adjust seasoning accordingly.",
            "Keep your workspace clean and organized.",
            "Don't rush - good cooking takes time!"
        ]
        
        if currentStep < tips.count {
            return tips[currentStep]
        }
        return nil
    }
    
    func startCookingMode(for recipe: Recipe) {
        self.recipe = recipe
        self.currentStep = 0
        
        // Analyze first step for timer requirements
        analyzeStepForTimer()
        
        // Keep screen on during cooking
        if keepScreenOn {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func exitCookingMode() {
        stopTimer()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func nextStep() {
        guard let recipe = recipe else { return }
        
        if currentStep < recipe.instructions.count - 1 {
            currentStep += 1
            stopTimer()
            analyzeStepForTimer()
        } else {
            // Recipe completed
            currentStep = recipe.instructions.count
            stopTimer()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            stopTimer()
            analyzeStepForTimer()
        }
    }
    
    func toggleKeepScreenOn() {
        keepScreenOn.toggle()
        UIApplication.shared.isIdleTimerDisabled = keepScreenOn
    }
    
    func startTimer(duration: TimeInterval) {
        timerDuration = duration
        remainingTime = duration
        timerState = .running
        timerStartTime = Date()
        pausedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.updateTimer()
            }
        }
        
        // Send timer to watch
        NotificationCenter.default.post(
            name: .timerStarted,
            object: nil,
            userInfo: [
                "duration": duration, 
                "recipeName": recipe?.title ?? "",
                "stepNumber": currentStep + 1,
                "stepDescription": recipe?.instructions[currentStep].instruction ?? ""
            ]
        )
    }
    
    func toggleTimer() {
        switch timerState {
        case .running:
            pauseTimer()
        case .paused:
            resumeTimer()
        case .stopped, .expired:
            break
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        timerState = .paused
        
        if let startTime = timerStartTime {
            pausedTime += Date().timeIntervalSince(startTime)
        }
    }
    
    func resumeTimer() {
        timerState = .running
        timerStartTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.updateTimer()
            }
        }
    }
    
    func resetTimer() {
        stopTimer()
        if let duration = currentStepTimer {
            remainingTime = duration
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerState = .stopped
        timerStartTime = nil
        pausedTime = 0
        pulseAnimation = false
    }
    
    private func updateTimer() {
        guard let startTime = timerStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime) + pausedTime
        remainingTime = max(0, timerDuration - elapsed)
        
        if remainingTime <= 0 {
            timerExpired()
        }
    }
    
    private func timerExpired() {
        timerState = .expired
        timer?.invalidate()
        timer = nil
        pulseAnimation = true
        
        // Show notification
        NotificationManager.shared.scheduleLocalNotification(
            id: "timer_finished_\(UUID().uuidString)",
            title: "Timer Finished!",
            body: "Step \(currentStep + 1) timer has finished",
            timeInterval: 0.1
        )
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    private func analyzeStepForTimer() {
        guard let recipe = recipe, currentStep < recipe.instructions.count else {
            currentStepTimer = nil
            return
        }
        
        let instruction = recipe.instructions[currentStep].instruction.lowercased()
        
        // Simple pattern matching for common timer durations
        if instruction.contains("15 minutes") || instruction.contains("15 mins") {
            currentStepTimer = 15 * 60
        } else if instruction.contains("10 minutes") || instruction.contains("10 mins") {
            currentStepTimer = 10 * 60
        } else if instruction.contains("5 minutes") || instruction.contains("5 mins") {
            currentStepTimer = 5 * 60
        } else if instruction.contains("20 minutes") || instruction.contains("20 mins") {
            currentStepTimer = 20 * 60
        } else if instruction.contains("30 minutes") || instruction.contains("30 mins") {
            currentStepTimer = 30 * 60
        } else {
            currentStepTimer = nil
        }
        
        // Reset timer state for new step
        stopTimer()
        if let duration = currentStepTimer {
            remainingTime = duration
        }
    }
    
    func startCompletionAnimation() {
        completionAnimation = true
    }
    
    func restartCookingMode() {
        currentStep = 0
        stopTimer()
        analyzeStepForTimer()
    }
    
    func showRatingSheet() {
        // Show rating sheet
    }
    
    func shareRecipe() {
        // Share recipe
    }
}

enum TimerState {
    case stopped
    case running
    case paused
    case expired
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CookBookFonts.callout)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [CookBookColors.primary, CookBookColors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CookBookFonts.callout)
            .fontWeight(.medium)
            .foregroundColor(CookBookColors.primary)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(CookBookColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(CookBookColors.primary.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CookBookFonts.callout)
            .fontWeight(.medium)
            .foregroundColor(CookBookColors.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(CookBookColors.surface.opacity(0.5))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Notifications
//extension Notification.Name {
//    static let timerStarted = Notification.Name("timerStarted")
//    static let timerFinished = Notification.Name("timerFinished")
//}

#Preview {
    let interactor = RecipeDetailInteractor()
    let presenter = RecipeDetailPresenter()
    let router = RecipeDetailRouter()
    
    let viewModel = RecipeDetailViewModel(
        interactor: interactor,
        router: router
    )
    
    // Wire VIP dependencies
    interactor.presenter = presenter
    presenter.viewModel = viewModel
    
    return CookingModeDetailView(
        recipe: MockDataProvider.generateMockRecipes()[0],
        viewModel: viewModel
    )
}
