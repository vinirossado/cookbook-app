//
//  AddRecipeView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI
import Foundation

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var title = ""
    @State private var description = ""
    @State private var category = RecipeCategory.dinner
    @State private var difficulty = DifficultyLevel.beginner
    @State private var prepTime: TimeInterval = 15
    @State private var cookTime: TimeInterval = 30
    @State private var servings = 4
    @State private var country = Country.unitedStates
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Recipe Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Classification")) {
                    Picker("Category", selection: $category) {
                        ForEach(RecipeCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                            HStack {
                                Image(systemName: difficulty.icon)
                                Text(difficulty.rawValue)
                            }
                            .tag(difficulty)
                        }
                    }
                    
                    Picker("Country of Origin", selection: $country) {
                        ForEach(Array(Country.allCases.prefix(20)), id: \.self) { country in
                            HStack {
                                Text(country.flag)
                                Text(country.rawValue)
                            }
                            .tag(country)
                        }
                    }
                }
                
                Section(header: Text("Timing & Servings")) {
                    HStack {
                        Text("Prep Time")
                        Spacer()
                        Stepper("\(Int(prepTime)) min", value: $prepTime, in: 5...120, step: 5)
                    }
                    
                    HStack {
                        Text("Cook Time")
                        Spacer()
                        Stepper("\(Int(cookTime)) min", value: $cookTime, in: 5...240, step: 5)
                    }
                    
                    HStack {
                        Text("Servings")
                        Spacer()
                        Stepper("\(servings)", value: $servings, in: 1...12)
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveRecipe() {
        let newRecipe = Recipe(
            title: title,
            description: description,
            images: [RecipeImage(url: "placeholder", isMain: true)],
            ingredients: [], // Would be filled in a more complete form
            instructions: [], // Would be filled in a more complete form
            category: category,
            difficulty: difficulty,
            cookingTime: cookTime * 60, // Convert to seconds
            prepTime: prepTime * 60, // Convert to seconds
            servingSize: servings,
            nutritionalInfo: nil,
            tags: [],
            rating: 0.0,
            reviews: [],
            createdBy: UUID(), // Would be current user ID
            isPublic: false,
            isFavorite: false,
            createdAt: Date(),
            updatedAt: Date(),
            countryOfOrigin: country
        )
        
        appState.addRecipe(newRecipe)
    }
}

#Preview {
    AddRecipeView()
        .environment(AppState.shared)
}
