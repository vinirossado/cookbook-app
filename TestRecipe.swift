import SwiftUI
import Foundation

// Test file to check Recipe ambiguity
struct TestRecipe {
    func testRecipeType() {
        let recipe: Recipe? = nil
        print("Recipe type resolved: \(String(describing: recipe))")
    }
}
