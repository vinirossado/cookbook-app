//
//  CookBookColors.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct CookBookColors {
    // Primary Colors
    static let primary = color(named: "CookBookOrange", fallback: Color(red: 0.98, green: 0.45, blue: 0.16))
    static let secondary = color(named: "CookBookGreen", fallback: Color(red: 0.30, green: 0.69, blue: 0.31))
    static let accent = color(named: "CookBookRed", fallback: Color(red: 0.96, green: 0.26, blue: 0.21))
    
    // Background Colors
    static let background = color(named: "CookBookCream", fallback: Color(red: 0.98, green: 0.97, blue: 0.95))
    static let surface = color(named: "CookBookLightGray", fallback: Color(red: 0.95, green: 0.95, blue: 0.97))
    static let cardBackground = color(named: "CookBookWhite", fallback: Color.white)
    
    // Text Colors
    static let text = color(named: "CookBookDarkGray", fallback: Color(red: 0.2, green: 0.2, blue: 0.2))
    static let textSecondary = color(named: "CookBookMediumGray", fallback: Color(red: 0.5, green: 0.5, blue: 0.5))
    static let textLight = color(named: "CookBookLightText", fallback: Color(red: 0.7, green: 0.7, blue: 0.7))
    
    // Status Colors
    static let success = color(named: "CookBookSuccess", fallback: Color(red: 0.30, green: 0.69, blue: 0.31))
    static let warning = color(named: "CookBookWarning", fallback: Color(red: 1.0, green: 0.76, blue: 0.03))
    static let error = color(named: "CookBookError", fallback: Color(red: 0.96, green: 0.26, blue: 0.21))
    static let info = color(named: "CookBookInfo", fallback: Color(red: 0.20, green: 0.60, blue: 0.86))
    
    // Difficulty Colors
    static let beginner = color(named: "DifficultyBeginner", fallback: Color(red: 0.30, green: 0.69, blue: 0.31))
    static let intermediate = color(named: "DifficultyIntermediate", fallback: Color(red: 1.0, green: 0.76, blue: 0.03))
    static let advanced = color(named: "DifficultyAdvanced", fallback: Color(red: 0.98, green: 0.45, blue: 0.16))
    static let professional = color(named: "DifficultyProfessional", fallback: Color(red: 0.96, green: 0.26, blue: 0.21))
    
    // Category Colors
    static let breakfast = color(named: "CategoryBreakfast", fallback: Color(red: 1.0, green: 0.76, blue: 0.03))
    static let lunch = color(named: "CategoryLunch", fallback: Color(red: 0.30, green: 0.69, blue: 0.31))
    static let dinner = color(named: "CategoryDinner", fallback: Color(red: 0.98, green: 0.45, blue: 0.16))
    static let dessert = color(named: "CategoryDessert", fallback: Color(red: 0.85, green: 0.33, blue: 0.83))
    static let snack = color(named: "CategorySnack", fallback: Color(red: 0.20, green: 0.60, blue: 0.86))
    static let beverage = color(named: "CategoryBeverage", fallback: Color(red: 0.35, green: 0.78, blue: 0.98))
    
    // Dynamic color provider
    static func color(named: String, fallback: Color) -> Color {
        if let _ = UIColor(named: named) {
            return Color(named)
        }
        return fallback
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
