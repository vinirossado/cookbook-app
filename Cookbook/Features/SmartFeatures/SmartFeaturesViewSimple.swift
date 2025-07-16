//
//  SmartFeaturesViewSimple.swift
//  CookBook Pro
//
//  Created by GitHub Copilot on 17/07/2025.
//

import SwiftUI

struct SmartFeaturesViewSimple: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Smart Features")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    VStack(spacing: 16) {
                        // AI Features Section
                        sectionCard(
                            title: "AI Recipe Analysis",
                            subtitle: "Get smart insights about your recipes",
                            icon: "brain.head.profile",
                            color: .blue
                        )
                        
                        // Cultural Features Section
                        sectionCard(
                            title: "Cultural Insights",
                            subtitle: "Explore world cuisines and traditions",
                            icon: "globe.americas",
                            color: .green
                        )
                        
                        // Nutrition Features Section
                        sectionCard(
                            title: "Nutrition Tracking",
                            subtitle: "Monitor your health and nutrition goals",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        // Smart Tips Section
                        sectionCard(
                            title: "Smart Cooking Tips",
                            subtitle: "Get personalized cooking recommendations",
                            icon: "lightbulb.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Smart Features")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func sectionCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Coming Soon")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .cornerRadius(8)
            }
            
            Text("These advanced features are currently under development and will be available in a future update.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    SmartFeaturesViewSimple()
        .environment(AppState.shared)
}
