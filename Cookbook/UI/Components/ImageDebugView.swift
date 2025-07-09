//
//  ImageDebugView.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 09/07/2025.
//

import SwiftUI

struct ImageDebugView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(appState.recipes.prefix(3)) { recipe in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title)
                            .font(.headline)
                        
                        Text("Image Count: \(recipe.images.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(recipe.images.indices, id: \.self) { index in
                            let image = recipe.images[index]
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Image \(index + 1): \(image.isMain ? "Main" : "Secondary")")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Text("URL: \(image.url)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                
                                // Test AsyncImage directly
                                AsyncImage(url: URL(string: image.url)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 75)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 75)
                                            .clipped()
                                            .cornerRadius(8)
                                    case .failure(let error):
                                        VStack {
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundColor(.red)
                                            Text("Failed")
                                                .font(.caption2)
                                            Text(error.localizedDescription)
                                                .font(.caption2)
                                                .foregroundColor(.red)
                                        }
                                        .frame(width: 100, height: 75)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                        
                        Divider()
                    }
                }
            }
            .navigationTitle("Image Debug")
        }
    }
}

#Preview {
    ImageDebugView()
        .environment(AppState.shared)
}
