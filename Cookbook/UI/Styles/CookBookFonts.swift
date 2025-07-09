//
//  CookBookFonts.swift
//  CookBook Pro
//
//  Created by Vinicius Rossado on 08/07/2025.
//

import SwiftUI

struct CookBookFonts {
    // Typography Scale
    static let largeTitle = Font.custom("Avenir-Heavy", size: 34, relativeTo: .largeTitle)
    static let title1 = Font.custom("Avenir-Heavy", size: 28, relativeTo: .title)
    static let title2 = Font.custom("Avenir-Medium", size: 22, relativeTo: .title2)
    static let title3 = Font.custom("Avenir-Medium", size: 20, relativeTo: .title3)
    static let headline = Font.custom("Avenir-Medium", size: 17, relativeTo: .headline)
    static let body = Font.custom("Avenir-Book", size: 17, relativeTo: .body)
    static let callout = Font.custom("Avenir-Book", size: 16, relativeTo: .callout)
    static let subheadline = Font.custom("Avenir-Book", size: 15, relativeTo: .subheadline)
    static let footnote = Font.custom("Avenir-Book", size: 13, relativeTo: .footnote)
    static let caption1 = Font.custom("Avenir-Book", size: 12, relativeTo: .caption)
    static let caption2 = Font.custom("Avenir-Book", size: 11, relativeTo: .caption2)
    
    // Specialized fonts
    static let recipeTitle = Font.custom("Avenir-Heavy", size: 24, relativeTo: .title2)
    static let ingredientText = Font.custom("Avenir-Book", size: 16, relativeTo: .body)
    static let instructionText = Font.custom("Avenir-Book", size: 16, relativeTo: .body)
    static let timerText = Font.custom("Avenir-Medium", size: 18, relativeTo: .headline)
    static let buttonText = Font.custom("Avenir-Medium", size: 16, relativeTo: .callout)
    
    // Fallback system fonts when custom fonts aren't available
    static let systemLargeTitle = Font.largeTitle.weight(.heavy)
    static let systemTitle1 = Font.title.weight(.heavy)
    static let systemTitle2 = Font.title2.weight(.medium)
    static let systemTitle3 = Font.title3.weight(.medium)
    static let systemHeadline = Font.headline.weight(.medium)
    static let systemBody = Font.body
    static let systemCallout = Font.callout
    static let systemSubheadline = Font.subheadline
    static let systemFootnote = Font.footnote
    static let systemCaption1 = Font.caption
    static let systemCaption2 = Font.caption2
}

// MARK: - Font Weight Extensions
extension Font {
    static func avenirHeavy(size: CGFloat) -> Font {
        return Font.custom("Avenir-Heavy", size: size)
    }
    
    static func avenirMedium(size: CGFloat) -> Font {
        return Font.custom("Avenir-Medium", size: size)
    }
    
    static func avenirBook(size: CGFloat) -> Font {
        return Font.custom("Avenir-Book", size: size)
    }
    
    static func avenirLight(size: CGFloat) -> Font {
        return Font.custom("Avenir-Light", size: size)
    }
}

// MARK: - Text Style Modifiers
struct CookBookTextStyle: ViewModifier {
    let style: TextStyleType
    
    enum TextStyleType {
        case recipeTitle
        case sectionHeader
        case ingredient
        case instruction
        case timer
        case metadata
        case button
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .recipeTitle:
            content
                .font(CookBookFonts.recipeTitle)
                .foregroundColor(CookBookColors.text)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        case .sectionHeader:
            content
                .font(CookBookFonts.headline)
                .foregroundColor(CookBookColors.text)
                .fontWeight(.semibold)
        case .ingredient:
            content
                .font(CookBookFonts.ingredientText)
                .foregroundColor(CookBookColors.text)
                .lineLimit(3)
        case .instruction:
            content
                .font(CookBookFonts.instructionText)
                .foregroundColor(CookBookColors.text)
                .lineSpacing(4)
        case .timer:
            content
                .font(CookBookFonts.timerText)
                .foregroundColor(CookBookColors.primary)
                .fontWeight(.medium)
        case .metadata:
            content
                .font(CookBookFonts.caption1)
                .foregroundColor(CookBookColors.textSecondary)
        case .button:
            content
                .font(CookBookFonts.buttonText)
                .fontWeight(.medium)
        }
    }
}

extension View {
    func cookBookTextStyle(_ style: CookBookTextStyle.TextStyleType) -> some View {
        modifier(CookBookTextStyle(style: style))
    }
}
