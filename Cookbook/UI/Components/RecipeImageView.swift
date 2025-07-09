//
//  RecipeImageView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 09/07/2025.
//

import SwiftUI

struct RecipeImageView: View {
    let imageUrl: String
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(imageUrl: String, width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = 0) {
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if imageUrl.hasPrefix("http") {
                // Handle network images
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderView
                }
            } else {
                // Handle SF Symbols
                sfSymbolView
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(
                LinearGradient(
                    colors: [CookBookColors.surface, CookBookColors.surface.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: imageUrl.contains(".") ? imageUrl : "photo")
                    .font(.system(size: min(height * 0.3, 60)))
                    .foregroundColor(CookBookColors.textSecondary)
            )
    }
    
    private var sfSymbolView: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(
                LinearGradient(
                    colors: [CookBookColors.primary.opacity(0.15), CookBookColors.primary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: imageUrl)
                    .font(.system(size: min(height * 0.4, 80)))
                    .foregroundColor(CookBookColors.primary)
                    .symbolRenderingMode(.hierarchical)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        RecipeImageView(
            imageUrl: "sun.and.horizon.fill",
            height: 200,
            cornerRadius: 16
        )
        
        RecipeImageView(
            imageUrl: "birthday.cake.fill",
            height: 150,
            cornerRadius: 12
        )
        
        RecipeImageView(
            imageUrl: "https://picsum.photos/400/300",
            height: 200,
            cornerRadius: 16
        )
    }
    .padding()
}
