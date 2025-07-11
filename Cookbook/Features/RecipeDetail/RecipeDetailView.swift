//
//  RecipeDetailView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var viewModel: RecipeDetailViewModel
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingCookingMode = false
    @State private var showingEditMode = false
    @State private var showingShareSheet = false
    
    // Visual feedback states
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastIcon = ""
    
    init(recipe: Recipe, viewModel: RecipeDetailViewModel) {
        self.recipe = recipe
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                heroImageSection
                
                // Content
                VStack(spacing: 24) {
                    // Header Info
                    headerSection
                    
                    // Tabs
                    tabSelector
                    
                    // Tab Content
                    Group {
                        switch selectedTab {
                        case 0:
                            overviewTab
                        case 1:
                            ingredientsTab
                        case 2:
                            instructionsTab
                        case 3:
                            nutritionTab
                        default:
                            overviewTab
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: { 
                        viewModel.toggleFavorite() 
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        // Show toast
                        showToast(
                            message: viewModel.isFavorite ? "Added to favorites" : "Removed from favorites",
                            icon: viewModel.isFavorite ? "heart.fill" : "heart"
                        )
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorite ? CookBookColors.accent : CookBookColors.textSecondary)
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(CookBookColors.primary)
                    }
                    
                    Menu {
                        Button("Edit Recipe") {
                            showingEditMode = true
                        }
                        
                        Button("Add to Shopping List") {
                            viewModel.addIngredientsToShoppingList()
                            
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                                                        
                            // Show toast
                            showToast(
                                message: "Added \(viewModel.uncheckedIngredientsAmount) ingredients to cart",
                                icon: "cart.fill"
                            )
                        }
                        
                        Button("Add to Meal Plan") {
                            Task {
                                await viewModel.showMealPlanPicker()
                            }
                        }
                        
                        Button("Want to Cook Today") {
                            viewModel.addToWantToday()
                            
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            // Show toast
                            showToast(
                                message: "Added to today's meal plan",
                                icon: "clock.fill"
                            )
                        }
                        
                        Button("Duplicate Recipe") {
                            viewModel.duplicateRecipe()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(CookBookColors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCookingMode) {
            CookingModeDetailView(recipe: recipe, viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditMode) {
            // TODO: Create RecipeEditView
            Text("Recipe Edit View - Coming Soon")
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [viewModel.shareContent])
        }
        .onAppear {
            viewModel.loadRecipeDetails(recipe)
        }
        .overlay(
            // Toast notification
            VStack {
                Spacer()
                if showingToast {
                    ToastView(message: toastMessage, icon: toastIcon)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.easeInOut(duration: 0.3), value: showingToast)
                        .padding(.bottom, 100)
                }
            }
        )
    }
    
    private var heroImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            RecipeImageView(
                imageUrl: recipe.images.first?.url ?? "photo",
                height: 250,
                cornerRadius: 0
            )
            
            // Difficulty Badge
            Text(recipe.difficulty.rawValue)
                .font(CookBookFonts.caption1)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(recipe.difficulty.color)
                )
                .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Title and Rating
            VStack(spacing: 8) {
                Text(recipe.title)
                    .font(CookBookFonts.title1)
                    .fontWeight(.bold)
                    .foregroundColor(CookBookColors.text)
                    .multilineTextAlignment(.center)
                
                HStack {
                    StarRatingView(rating: recipe.rating, maxRating: 5)
                    
                    Text("(\(recipe.reviews.count) reviews)")
                        .font(CookBookFonts.caption1)
                        .foregroundColor(CookBookColors.textSecondary)
                }
                
                // Country of Origin
                HStack(spacing: 8) {
                    Text(recipe.countryOfOrigin.flag)
                        .font(.title2)
                    
                    Text(recipe.countryOfOrigin.rawValue)
                        .font(CookBookFonts.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(CookBookColors.textSecondary)
                    
                    Text("•")
                        .font(CookBookFonts.caption1)
                        .foregroundColor(CookBookColors.textSecondary)
                    
                    Text(recipe.countryOfOrigin.regionDescription)
                        .font(CookBookFonts.caption1)
                        .foregroundColor(CookBookColors.textSecondary)
                }
            }
            
            // Quick Stats
            HStack(spacing: 32) {
                quickStatItem(
                    icon: "clock",
                    title: "Cook Time",
                    value: formatTime(recipe.cookingTime)
                )
                
                quickStatItem(
                    icon: "person.2",
                    title: "Serves",
                    value: "\(recipe.servingSize)"
                )
                
                quickStatItem(
                    icon: "flame",
                    title: "Calories",
                    value: "\(recipe.nutritionalInfo?.calories ?? 0)"
                )
            }
            
            // Cook Button
            Button(action: { showingCookingMode = true }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.headline)
                    
                    Text("Start Cooking")
                        .font(CookBookFonts.headline)
                        .fontWeight(.semibold)
                }
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
            }
        }
    }
    
    private var tabSelector: some View {
        HStack {
            TabButton(title: "Overview", isSelected: selectedTab == 0) { selectedTab = 0 }
            TabButton(title: "Ingredients", isSelected: selectedTab == 1) { selectedTab = 1 }
            TabButton(title: "Steps", isSelected: selectedTab == 2) { selectedTab = 2 }
            TabButton(title: "Nutrition", isSelected: selectedTab == 3) { selectedTab = 3 }
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.surface)
        )
    }
    
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                
                Text(recipe.description)
                    .font(CookBookFonts.body)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            // Categories and Dietary Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    detailItem(title: "Category", value: recipe.category.rawValue)
                    detailItem(title: "Cuisine", value: recipe.category.rawValue)
                    detailItem(title: "Prep Time", value: formatTime(recipe.prepTime))
                    detailItem(title: "Total Time", value: formatTime(recipe.totalTime))
                }
            }
            
            // Dietary Restrictions
            if !recipe.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dietary Information")
                        .font(CookBookFonts.headline)
                        .fontWeight(.semibold)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(CookBookFonts.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(CookBookColors.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(CookBookColors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(CookBookColors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var ingredientsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Ingredients")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                ServingSizeAdjuster(
                    currentServings: viewModel.adjustedServings,
                    originalServings: recipe.servingSize
                ) { newServings in
                    viewModel.adjustServings(to: newServings)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.adjustedIngredients, id: \.id) { ingredient in
                    IngredientRow(
                        ingredient: ingredient,
                        isChecked: viewModel.checkedIngredients.contains(ingredient.id)
                    ) {
                        viewModel.toggleIngredientCheck(ingredient.id)
                    }
                }
            }
            
            Button("Add ingredients to Shopping List") {
                viewModel.addIngredientsToShoppingList()
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                // Show toast
                showToast(
                    message: "Added \(viewModel.uncheckedIngredientsAmount) ingredients to cart",
                    icon: "cart.fill"
                )
            }
            .font(CookBookFonts.callout)
            .fontWeight(.medium)
            .foregroundColor(CookBookColors.primary)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(CookBookColors.primary, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var instructionsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Instructions")
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    InstructionStepView(
                        stepNumber: index + 1,
                        instruction: instruction.instruction,
                        isCompleted: viewModel.completedSteps.contains(index)
                    ) {
                        viewModel.toggleStepCompletion(index)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var nutritionTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Nutrition Facts")
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                NutritionFactRow(
                    title: "Calories",
                    value: "\(recipe.nutritionalInfo?.calories ?? 0)",
                    unit: "kcal",
                    dailyValue: nil
                )
                
                NutritionFactRow(
                    title: "Protein",
                    value: String(format: "%.1f", recipe.nutritionalInfo?.protein ?? 0),
                    unit: "g",
                    dailyValue: calculateDailyValue(recipe.nutritionalInfo?.protein ?? 0, recommendedDaily: 50)
                )
                
                NutritionFactRow(
                    title: "Carbohydrates",
                    value: String(format: "%.1f", recipe.nutritionalInfo?.carbohydrates ?? 0),
                    unit: "g",
                    dailyValue: calculateDailyValue(recipe.nutritionalInfo?.carbohydrates ?? 0, recommendedDaily: 300)
                )
                
                NutritionFactRow(
                    title: "Fat",
                    value: String(format: "%.1f", recipe.nutritionalInfo?.fat ?? 0),
                    unit: "g",
                    dailyValue: calculateDailyValue(recipe.nutritionalInfo?.fat ?? 0, recommendedDaily: 65)
                )
                
                NutritionFactRow(
                    title: "Fiber",
                    value: String(format: "%.1f", recipe.nutritionalInfo?.fiber ?? 0),
                    unit: "g",
                    dailyValue: calculateDailyValue(recipe.nutritionalInfo?.fiber ?? 0, recommendedDaily: 25)
                )
                
                NutritionFactRow(
                    title: "Sugar",
                    value: String(format: "%.1f", recipe.nutritionalInfo?.sugar ?? 0),
                    unit: "g",
                    dailyValue: nil
                )
                
                NutritionFactRow(
                    title: "Sodium",
                    value: String(format: "%.0f", recipe.nutritionalInfo?.sodium ?? 0),
                    unit: "mg",
                    dailyValue: calculateDailyValue(recipe.nutritionalInfo?.sodium ?? 0, recommendedDaily: 2300)
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.surface)
            )
            
            Text("* Daily Values are based on a 2000 calorie diet")
                .font(CookBookFonts.caption2)
                .foregroundColor(CookBookColors.textSecondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Helper Views
    private func quickStatItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(CookBookColors.primary)
            
            Text(value)
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(CookBookColors.text)
            
            Text(title)
                .font(CookBookFonts.caption1)
                .foregroundColor(CookBookColors.textSecondary)
        }
    }
    
    private func detailItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(CookBookFonts.caption1)
                .foregroundColor(CookBookColors.textSecondary)
            
            Text(value)
                .font(CookBookFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(CookBookColors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(CookBookColors.surface)
        )
    }
    
    private func calculateDailyValue(_ amount: Double, recommendedDaily: Double) -> Int {
        return Int((amount / recommendedDaily) * 100)
    }
    
    private func formatTime(_ minutes: Double) -> String {
        let totalMinutes = Int(minutes)
        
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let remainingMinutes = totalMinutes % 60
            
            if remainingMinutes == 0 {
                return hours == 1 ? "1 hour" : "\(hours) hours"
            } else {
                return hours == 1 ? "1 hour \(remainingMinutes) min" : "\(hours) hours \(remainingMinutes) min"
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showToast(message: String, icon: String) {
        toastMessage = message
        toastIcon = icon
        withAnimation(.easeInOut(duration: 0.3)) {
            showingToast = true
        }
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingToast = false
            }
        }
    }
}

// MARK: - Supporting Views
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CookBookFonts.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? CookBookColors.primary : CookBookColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? CookBookColors.primary.opacity(0.1) : Color.clear)
                )
        }
    }
}

struct ServingSizeAdjuster: View {
    let currentServings: Int
    let originalServings: Int
    let onServingsChanged: (Int) -> Void
    
    var body: some View {
        HStack {
            Button(action: { 
                if currentServings > 1 {
                    onServingsChanged(currentServings - 1)
                }
            }) {
                Image(systemName: "minus.circle")
                    .foregroundColor(currentServings > 1 ? CookBookColors.primary : CookBookColors.textSecondary)
            }
            .disabled(currentServings <= 1)
            
            Text("\(currentServings) servings")
                .font(CookBookFonts.callout)
                .fontWeight(.medium)
                .frame(minWidth: 80)
            
            Button(action: { 
                onServingsChanged(currentServings + 1)
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(CookBookColors.primary)
            }
        }
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? CookBookColors.success : CookBookColors.textSecondary)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(ingredient.amount) \(ingredient.unit) \(ingredient.name)")
                        .font(CookBookFonts.callout)
                        .foregroundColor(isChecked ? CookBookColors.textSecondary : CookBookColors.text)
                        .strikethrough(isChecked)
                    
                    if let notes = ingredient.notes, !notes.isEmpty {
                        Text(notes)
                            .font(CookBookFonts.caption1)
                            .foregroundColor(CookBookColors.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

struct InstructionStepView: View {
    let stepNumber: Int
    let instruction: String
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? CookBookColors.success : CookBookColors.primary)
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    } else {
                        Text("\(stepNumber)")
                            .font(CookBookFonts.caption1)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Text(instruction)
                    .font(CookBookFonts.callout)
                    .foregroundColor(isCompleted ? CookBookColors.textSecondary : CookBookColors.text)
                    .strikethrough(isCompleted)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? CookBookColors.surface.opacity(0.5) : CookBookColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCompleted ? CookBookColors.success.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct NutritionFactRow: View {
    let title: String
    let value: String
    let unit: String
    let dailyValue: Int?
    
    var body: some View {
        HStack {
            Text(title)
                .font(CookBookFonts.callout)
                .foregroundColor(CookBookColors.text)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .font(CookBookFonts.callout)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.text)
                
                Text(unit)
                    .font(CookBookFonts.caption1)
                    .foregroundColor(CookBookColors.textSecondary)
                
                if let dailyValue = dailyValue {
                    Text("(\(dailyValue)%)")
                        .font(CookBookFonts.caption1)
                        .foregroundColor(CookBookColors.textSecondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StarRatingView: View {
    let rating: Double
    let maxRating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .foregroundColor(CookBookColors.warning)
                    .font(.caption)
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        let difference = rating - Double(index - 1)
        
        if difference >= 1.0 {
            return "star.fill"
        } else if difference >= 0.5 {
            return "star.lefthalf.fill"
        } else {
            return "star"
        }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.bounds
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var bounds = CGSize.zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            bounds = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

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
    
    return NavigationView {
        RecipeDetailView(
            recipe: MockDataProvider.generateMockRecipes()[0],
            viewModel: viewModel
        )
    }
    .environment(AppState.shared)
}
