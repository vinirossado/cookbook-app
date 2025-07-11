//
//  ShoppingListView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct ShoppingListView: View {
    @State private var viewModel: ShoppingViewModel
    @Environment(AppState.self) private var appState
    @State private var showingShareSheet = false
    
    init(viewModel: ShoppingViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Progress Section
                progressSection
                
                // Shopping Items
                shoppingItemsSection
                
                // Quick Actions
                quickActionsSection
            }
            .padding()
        }
        .navigationTitle("Shopping List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Share List", action: { showingShareSheet = true })
                    Button("Clear Completed", action: viewModel.clearCompleted)
                    Button("Clear All", role: .destructive, action: viewModel.clearAll)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [viewModel.generateShoppingListText()])
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Shopping Progress")
                        .font(CookBookFonts.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(appState.shoppingCart.completedItems) of \(appState.shoppingCart.totalItems) items")
                        .font(CookBookFonts.subheadline)
                        .foregroundColor(CookBookColors.textSecondary)
                }
                
                Spacer()
                
                CircularProgressView(progress: appState.shoppingCart.progress)
                    .frame(width: 60, height: 60)
            }
            
            ProgressView(value: appState.shoppingCart.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: CookBookColors.primary))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CookBookColors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var shoppingItemsSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(groupedShoppingItems.keys.sorted(), id: \.self) { category in
                ShoppingCategorySection(
                    category: category,
                    items: groupedShoppingItems[category] ?? []
                ) { item in
                    appState.toggleShoppingItemCompleted(item)
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Button("Add from Recent Recipes") {
                viewModel.addFromRecentRecipes()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(CookBookColors.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button("Suggest Based on Meal Plan") {
                viewModel.suggestFromMealPlan()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(CookBookColors.secondary)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var groupedShoppingItems: [IngredientCategory: [ShoppingItem]] {
        Dictionary(grouping: appState.shoppingCart.items) { $0.ingredient.category }
    }
}

struct ShoppingCategorySection: View {
    let category: IngredientCategory
    let items: [ShoppingItem]
    let onItemToggle: (ShoppingItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                
                Text(category.rawValue)
                    .font(CookBookFonts.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(items.filter { !$0.isCompleted }.count)")
                    .font(CookBookFonts.caption1)
                    .foregroundColor(CookBookColors.textSecondary)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(items) { item in
                    ShoppingItemRow(item: item) {
                        onItemToggle(item)
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

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? CookBookColors.success : CookBookColors.textSecondary)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.ingredient.displayText)
                    .font(CookBookFonts.body)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? CookBookColors.textSecondary : CookBookColors.text)
                
                if item.recipes.count > 1 {
                    Text("For \(item.recipes.count) recipes")
                        .font(CookBookFonts.caption2)
                        .foregroundColor(CookBookColors.textSecondary)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(CookBookColors.surface, lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(CookBookColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(CookBookFonts.caption1)
                .fontWeight(.semibold)
                .foregroundColor(CookBookColors.text)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ShoppingRouter.createModule()
        .environment(AppState.shared)
}
