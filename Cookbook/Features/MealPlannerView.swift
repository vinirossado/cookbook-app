//
//  MealPlannerView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct MealPlannerView: View {
    @State private var viewModel: MealPlannerViewModel
    @Environment(AppState.self) private var appState
    @State private var selectedDate = Date()
    @State private var showingRecipeSelector = false
    @State private var selectedMealType: MealType = .breakfast
    
    init(viewModel: MealPlannerViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Week Calendar
                weekCalendarSection
                
                // Day Overview
                dayOverviewSection
                
                // Meal Planning for Selected Day
                mealPlanningSection
                
                // Quick Actions
                quickActionsSection
            }
            .padding()
        }
        .navigationTitle("Meal Planner")
        .sheet(isPresented: $showingRecipeSelector) {
            RecipeSelectorView(mealType: selectedMealType, date: selectedDate)
        }
    }
    
    private var weekCalendarSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Week of \(formattedWeekRange)")
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { changeWeek(-1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(CookBookColors.primary)
                    }
                    
                    Button(action: { changeWeek(1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(CookBookColors.primary)
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDays, id: \.self) { date in
                        DayCalendarCard(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            mealCount: mealsCount(for: date)
                        ) {
                            selectedDate = date
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var dayOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedDate, style: .date)
                    .font(CookBookFonts.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(mealsCount(for: selectedDate)) meals planned")
                    .font(CookBookFonts.subheadline)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            if let nutrition = dailyNutritionSummary {
                NutritionSummaryCard(nutrition: nutrition)
            }
        }
    }
    
    private var mealPlanningSection: some View {
        VStack(spacing: 16) {
            ForEach(MealType.allCases, id: \.self) { mealType in
                MealPlanCard(
                    mealType: mealType,
                    meal: plannedMeal(for: mealType, on: selectedDate),
                    onAddMeal: {
                        selectedMealType = mealType
                        showingRecipeSelector = true
                    },
                    onRemoveMeal: { meal in
                        appState.removeMealFromPlan(meal)
                    },
                    onWantToday: { meal in
                        appState.markWantToday(meal)
                    }
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(CookBookFonts.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Auto-Plan Week",
                    icon: "wand.and.stars",
                    color: CookBookColors.primary
                ) {
                    viewModel.autoGenerateWeekPlan()
                }
                
                QuickActionCard(
                    title: "Add to Shopping",
                    icon: "cart.badge.plus",
                    color: CookBookColors.secondary
                ) {
                    viewModel.addWeekToShopping()
                }
                
                QuickActionCard(
                    title: "Meal Prep Guide",
                    icon: "list.clipboard",
                    color: CookBookColors.accent
                ) {
                    viewModel.showMealPrepGuide()
                }
                
                QuickActionCard(
                    title: "Nutrition Goals",
                    icon: "chart.pie",
                    color: CookBookColors.info
                ) {
                    viewModel.showNutritionGoals()
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfWeek(for: selectedDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private var formattedWeekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startOfWeek = Calendar.current.startOfWeek(for: selectedDate)
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private var dailyNutritionSummary: NutritionData? {
        let _ = appState.currentMealPlan?.meals(for: selectedDate) ?? []
        // Calculate total nutrition from all meals for the day
        // This is a simplified calculation
        return nil
    }
    
    // MARK: - Helper Methods
    private func changeWeek(_ offset: Int) {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: selectedDate) ?? selectedDate
    }
    
    private func mealsCount(for date: Date) -> Int {
        return appState.currentMealPlan?.meals(for: date).count ?? 0
    }
    
    private func plannedMeal(for mealType: MealType, on date: Date) -> PlannedMeal? {
        return appState.currentMealPlan?.meals(for: date).first { $0.mealType == mealType }
    }
}

struct DayCalendarCard: View {
    let date: Date
    let isSelected: Bool
    let mealCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayOfWeek)
                    .font(CookBookFonts.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : CookBookColors.textSecondary)
                
                Text(dayNumber)
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : CookBookColors.text)
                
                Circle()
                    .fill(mealCount > 0 ? CookBookColors.accent : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 50, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? CookBookColors.primary : CookBookColors.surface)
            )
        }
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct MealPlanCard: View {
    let mealType: MealType
    let meal: PlannedMeal?
    let onAddMeal: () -> Void
    let onRemoveMeal: (PlannedMeal) -> Void
    let onWantToday: (PlannedMeal) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: mealType.icon)
                        .foregroundColor(mealType.color)
                    
                    VStack(alignment: .leading) {
                        Text(mealType.rawValue)
                            .font(CookBookFonts.headline)
                            .fontWeight(.semibold)
                        
                        Text(mealType.timeRange)
                            .font(CookBookFonts.caption1)
                            .foregroundColor(CookBookColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if meal == nil {
                    Button(action: onAddMeal) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(CookBookColors.primary)
                            .font(.title2)
                    }
                }
            }
            
            if let meal = meal {
                PlannedMealRow(
                    meal: meal,
                    onRemove: { onRemoveMeal(meal) },
                    onWantToday: { onWantToday(meal) }
                )
            } else {
                EmptyMealRow(mealType: mealType)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct PlannedMealRow: View {
    let meal: PlannedMeal
    let onRemove: () -> Void
    let onWantToday: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.recipeName)
                    .font(CookBookFonts.callout)
                    .fontWeight(.medium)
                
                Text("Serves \(meal.servings)")
                    .font(CookBookFonts.caption1)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onWantToday) {
                    Image(systemName: meal.wantToday ? "heart.fill" : "heart")
                        .foregroundColor(meal.wantToday ? CookBookColors.accent : CookBookColors.textSecondary)
                }
                
                Menu {
                    Button("View Recipe", action: {})
                    Button("Edit Servings", action: {})
                    Button("Add to Shopping", action: {})
                    Button("Remove", role: .destructive, action: onRemove)
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(CookBookColors.textSecondary)
                }
            }
        }
    }
}

struct EmptyMealRow: View {
    let mealType: MealType
    
    var body: some View {
        HStack {
            Text("No \(mealType.rawValue.lowercased()) planned")
                .font(CookBookFonts.subheadline)
                .foregroundColor(CookBookColors.textSecondary)
                .italic()
            
            Spacer()
        }
        .frame(height: 40)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(CookBookFonts.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(CookBookColors.text)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(CookBookColors.surface)
            )
        }
    }
}

struct NutritionSummaryCard: View {
    let nutrition: NutritionData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Daily Nutrition")
                    .font(CookBookFonts.subheadline)
                    .fontWeight(.medium)
                
                Text("\(nutrition.formattedCalories) calories")
                    .font(CookBookFonts.caption1)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                ForEach(nutrition.macronutrients, id: \.name) { macro in
                    VStack {
                        Text(macro.amount)
                            .font(CookBookFonts.caption2)
                            .fontWeight(.semibold)
                        
                        Text(macro.name)
                            .font(CookBookFonts.caption2)
                            .foregroundColor(CookBookColors.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CookBookColors.surface)
        )
    }
}

struct RecipeSelectorView: View {
    let mealType: MealType
    let date: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Recipe Selector for \(mealType.rawValue)")
                .navigationTitle("Select Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

@MainActor
@Observable
class MealPlannerViewModel {
    private let interactor: MealPlannerInteractorProtocol
    private let router: MealPlannerRouterProtocol
    
    init(interactor: MealPlannerInteractorProtocol, router: MealPlannerRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func autoGenerateWeekPlan() {
        // Implementation for auto-generating week meal plan
    }
    
    func addWeekToShopping() {
        // Implementation for adding week's meals to shopping list
    }
    
    func showMealPrepGuide() {
        // Implementation for showing meal prep guide
    }
    
    func showNutritionGoals() {
        // Implementation for showing nutrition goals
    }
}

protocol MealPlannerInteractorProtocol {
    var presenter: MealPlannerPresenterProtocol? { get set }
}

class MealPlannerInteractor: MealPlannerInteractorProtocol {
    var presenter: MealPlannerPresenterProtocol?
}

@MainActor
protocol MealPlannerPresenterProtocol {
    var viewModel: MealPlannerViewModel? { get set }
}

class MealPlannerPresenter: MealPlannerPresenterProtocol {
    weak var viewModel: MealPlannerViewModel?
}

#Preview {
    let interactor = MealPlannerInteractor()
    let presenter = MealPlannerPresenter()
    let router = MealPlannerRouter()
    
    let viewModel = MealPlannerViewModel(
        interactor: interactor,
        router: router
    )
    
    // Wire VIP dependencies
    interactor.presenter = presenter
    presenter.viewModel = viewModel
    
    return MealPlannerView(viewModel: viewModel)
        .environment(AppState.shared)
}
