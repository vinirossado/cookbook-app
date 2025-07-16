//
//  SmartFeaturesComponents.swift
//  CookBook Pro
//
//  Created by GitHub Copilot on 16/07/2025.
//

import SwiftUI

// MARK: - AI Recipe Analysis Card
struct AIRecipeAnalysisCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    @StateObject private var aiAnalyzer = AIRecipeAnalyzer.shared
    @State private var analysis: RecipeAnalysis?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsyncImage(url: URL(string: recipe.images.first?.url ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(CookBookColors.surface)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(CookBookColors.textSecondary)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text(recipe.countryOfOrigin.displayText)
                        .font(.caption)
                        .foregroundColor(CookBookColors.textSecondary)
                    
                    if let analysis = analysis {
                        HStack(spacing: 8) {
                            // Health Score
                            HStack(spacing: 2) {
                                Image(systemName: "heart.fill")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                Text("\(Int(analysis.nutritionOptimization.healthScore))%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            // Difficulty
                            HStack(spacing: 2) {
                                Image(systemName: analysis.difficultyAssessment.suggestedDifficulty.icon)
                                    .font(.caption2)
                                    .foregroundColor(analysis.difficultyAssessment.suggestedDifficulty.color)
                                Text(analysis.difficultyAssessment.suggestedDifficulty.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button(action: onTap) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(CookBookColors.primary)
                            .font(.caption)
                    }
                }
            }
            
            if let analysis = analysis, !analysis.cookingTips.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(analysis.cookingTips.prefix(3), id: \.id) { tip in
                            Text(tip.tip)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(tip.category.icon == "flame" ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                                )
                                .foregroundColor(tip.category.icon == "flame" ? .orange : .blue)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .onTapGesture {
            onTap()
        }
        .onAppear {
            loadAnalysis()
        }
    }
    
    private func loadAnalysis() {
        isLoading = true
        Task {
            let result = await aiAnalyzer.analyzeRecipe(recipe)
            await MainActor.run {
                analysis = result
                isLoading = false
            }
        }
    }
}

// MARK: - Cultural Recipe Card
struct CulturalRecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: recipe.images.first?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.surface)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(CookBookColors.textSecondary)
                    )
            }
            .frame(width: 140, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                // Country flag overlay
                VStack {
                    HStack {
                        Spacer()
                        Text(recipe.countryOfOrigin.flag)
                            .font(.title3)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    Spacer()
                }
                .padding(8)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(recipe.countryOfOrigin.rawValue)
                    .font(.caption2)
                    .foregroundColor(CookBookColors.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(recipe.formattedTotalTime)
                        .font(.caption2)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(0..<Int(recipe.rating), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .foregroundColor(CookBookColors.textSecondary)
            }
        }
        .frame(width: 140)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Continent Card
struct ContinentCard: View {
    let continent: Continent
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: continent.icon)
                .font(.title)
                .foregroundColor(continent.color)
            
            Text(continent.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("\(continent.countries.count) countries")
                .font(.caption2)
                .foregroundColor(CookBookColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(continent.color.opacity(0.1))
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Seasonal Recipe Card
struct SeasonalRecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var currentSeason: Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .fall
        default: return .winter
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: recipe.images.first?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(CookBookColors.surface)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(CookBookColors.textSecondary)
                    )
            }
            .frame(width: 120, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                // Season badge
                VStack {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: currentSeason.icon)
                                .font(.caption2)
                            Text(currentSeason.rawValue)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(currentSeason.color.opacity(0.9))
                        )
                        .foregroundColor(.white)
                        
                        Spacer()
                    }
                    Spacer()
                }
                .padding(6)
            )
            
            Text(recipe.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Cultural Learning Path Card
struct CulturalLearningPathCard: View {
    let country: Country
    let onTap: () -> Void
    
    @StateObject private var culturalService = CulturalRecipeService.shared
    
    var recipes: [Recipe] {
        culturalService.getCulturalLearningPath(for: country)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(country.flag)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Learn \(country.rawValue) Cuisine")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(recipes.count) recipes • Beginner to Advanced")
                        .font(.caption)
                        .foregroundColor(CookBookColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: onTap) {
                    Text("Start")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(CookBookColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            // Recipe progression
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recipes.prefix(5), id: \.id) { recipe in
                        VStack(spacing: 4) {
                            AsyncImage(url: URL(string: recipe.images.first?.url ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(CookBookColors.surface)
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            Text(recipe.difficulty.rawValue)
                                .font(.caption2)
                                .foregroundColor(recipe.difficultyColor)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Nutrition Components
struct NutritionMetric: View {
    let title: String
    let current: Int
    let goal: Int
    let unit: String
    let color: Color
    
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(CookBookColors.textSecondary)
            
            Text("\(current)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("/ \(goal) \(unit)")
                .font(.caption2)
                .foregroundColor(CookBookColors.textSecondary)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 0.5)
        }
    }
}

struct ConsumedMealRow: View {
    let meal: ConsumedMeal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.recipeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text(meal.mealType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(meal.mealType.color.opacity(0.2))
                        )
                        .foregroundColor(meal.mealType.color)
                    
                    Text("\(meal.servings, specifier: "%.1f") servings")
                        .font(.caption)
                        .foregroundColor(CookBookColors.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(meal.adjustedNutrition.calories)) cal")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(meal.consumedAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(CookBookColors.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ProgressBar: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CookBookColors.surface)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct NutritionRecommendedRecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    @StateObject private var healthService = HealthNutritionService.shared
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: recipe.images.first?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(CookBookColors.surface)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(CookBookColors.textSecondary)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                if let nutrition = recipe.nutritionalInfo {
                    HStack(spacing: 12) {
                        Text("\(Int(nutrition.calories)) cal")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("\(Int(nutrition.protein))g protein")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                        
                        Spacer()
                    }
                }
                
                // Nutrition density score
                let densityScore = healthService.calculateNutritionDensity(recipe)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    
                    Text("Nutrition Score: \(Int(densityScore))")
                        .font(.caption)
                        .foregroundColor(CookBookColors.textSecondary)
                }
            }
            
            Spacer()
            
            Button(action: onTap) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(CookBookColors.primary)
                    .font(.title2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Smart Suggestions Components
struct SmartSuggestionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(CookBookColors.textSecondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

struct SubstitutionRow: View {
    let original: String
    let substitute: String
    let reason: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(original)
                        .font(.caption)
                        .strikethrough()
                        .foregroundColor(CookBookColors.textSecondary)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(CookBookColors.primary)
                    
                    Text(substitute)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(CookBookColors.primary)
                }
                
                Text(reason)
                    .font(.caption2)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct CookingTipRow: View {
    let icon: String
    let tip: String
    let category: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(CookBookColors.accent)
                .font(.subheadline)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tip)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(category)
                    .font(.caption2)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
