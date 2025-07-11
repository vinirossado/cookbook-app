# CookBook Pro - Technical Documentation 📚

## Project Overview

**CookBook Pro** is a comprehensive iOS recipe management application built with **SwiftUI** and **VIP (View-Interactor-Presenter) architecture**. The app includes meal planning, shopping lists, cooking mode, and Apple Watch integration.

### Key Features
- 📱 Recipe management with detailed nutrition info
- 🍽️ Meal planning and scheduling
- 🛒 Smart shopping lists with categorization
- 👨‍🍳 Cooking mode with timers
- ⌚ Apple Watch companion app
- 🔐 Authentication with Apple/Google Sign-In
- 🌙 Dark mode support
- 🌍 Localization ready

## Project Structure 🏗️

```
CookBook Pro/
├── 📱 Cookbook/                           # Main iOS App
│   ├── 🎨 Assets.xcassets/               # App icons, colors, images
│   ├── 🧩 Components/                    # Reusable SwiftUI components
│   ├── 📺 Media.xcassets/                # Large media assets
│   ├── 🌍 Resources/                     # Localization, app resources
│   ├── 🏢 Services/                      # Business services layer
│   ├── 💾 State/                         # App state management
│   ├── 🛠️ Utils/                         # Utility functions & extensions
│   ├── 👁️ Views/                         # SwiftUI views and screens
│   ├── 🎯 Core/                          # Core business logic
│   │   ├── 📊 MockData/                  # Development mock data
│   │   ├── 📄 Models/                    # Data models and entities
│   │   └── 🔧 Services/                  # System services
│   ├── 🎭 Features/                      # Feature modules (VIP)
│   │   ├── 🔐 Authentication/            # User authentication
│   │   ├── 👨‍🍳 CookingMode/              # Cooking interface
│   │   ├── 📋 RecipeDetail/              # Recipe details
│   │   ├── 📚 RecipeManagement/          # Recipe CRUD
│   │   ├── 📅 MealPlannerView.swift      # Meal planning
│   │   ├── 🛒 ShoppingListView.swift     # Shopping lists
│   │   ├── 🏠 TodayView.swift            # Today's meals
│   │   └── 🧭 TodayRouter.swift          # Navigation routing
│   ├── 🗺️ Navigation/                    # App navigation & coordination
│   │   └── AppCoordinator.swift
│   └── 🎨 UI/                            # Design system
│       ├── Components/                   # UI components
│       └── Styles/                       # Colors, fonts, themes
├── ⌚ CookbookWatch Watch App/            # Apple Watch App
├── 🧪 CookbookTests/                     # Unit tests
└── 🔍 CookbookUITests/                   # UI tests
```

## Architecture Details 🏛️

### VIP Pattern Implementation

#### **View Layer** (`Views/`, `Components/`)
- **SwiftUI Views**: Pure UI presentation
- **Responsibilities**:
  - Render user interface
  - Handle user interactions
  - Display data from ViewModel
- **Key Files**:
  - `MealPlannerView.swift`
  - `RecipeDetailView.swift`
  - `ShoppingListView.swift`

```swift
struct RecipeDetailView: View {
    @State private var viewModel: RecipeDetailViewModel
    
    var body: some View {
        ScrollView {
            // UI implementation
        }
        .onAppear {
            viewModel.loadRecipeDetails(recipe)
        }
    }
}
```

#### **ViewModel Layer** (Inside feature modules)
- **Observable Classes**: State management and coordination
- **Responsibilities**:
  - Manage view state
  - Coordinate with Interactor
  - Handle presentation logic
- **Key Features**:
  - `@Observable` for state management
  - `@MainActor` for UI thread safety

```swift
@MainActor
@Observable
class RecipeDetailViewModel {
    private let interactor: RecipeDetailInteractorProtocol
    private let router: RecipeDetailRouterProtocol
    
    var recipe: Recipe?
    var isFavorite = false
    var isLoading = false
    
    func toggleFavorite() {
        interactor.toggleFavorite(recipeId: recipe.id, isFavorite: !isFavorite)
    }
}
```

#### **Interactor Layer** (Business Logic)
- **Protocol-Based**: Easy testing and dependency injection
- **Responsibilities**:
  - Business logic execution
  - Data validation
  - API communication via Workers
- **Pattern**: Request → Business Logic → Response

```swift
class RecipeDetailInteractor: RecipeDetailInteractorProtocol {
    var presenter: RecipeDetailPresenterProtocol?
    private let worker: RecipeDetailWorkerProtocol
    
    func toggleFavorite(recipeId: UUID, isFavorite: Bool) {
        Task {
            do {
                try await worker.toggleFavorite(recipeId, isFavorite)
                let response = RecipeDetail.ToggleFavorite.Response.success(isFavorite)
                await presenter?.presentFavoriteToggled(response: response)
            } catch {
                let response = RecipeDetail.ToggleFavorite.Response.failure(error)
                await presenter?.presentError(response: response)
            }
        }
    }
}
```

#### **Presenter Layer** (Data Formatting)
- **Formatting Logic**: Convert business data to display data
- **Responsibilities**:
  - Format data for UI
  - Handle error presentation
  - Update ViewModel with results

```swift
@MainActor
class RecipeDetailPresenter: RecipeDetailPresenterProtocol {
    weak var viewModel: RecipeDetailViewModel?
    
    func presentFavoriteToggled(response: RecipeDetail.ToggleFavorite.Response) {
        switch response {
        case .success(let isFavorite):
            viewModel?.isFavorite = isFavorite
        case .failure(let error):
            viewModel?.errorMessage = error.localizedDescription
        }
    }
}
```

#### **Router Layer** (Navigation)
- **Navigation Logic**: Screen transitions and module creation
- **Factory Pattern**: Module creation and dependency injection

```swift
class RecipeDetailRouter: RecipeDetailRouterProtocol {
    @MainActor
    static func createModule(for recipe: Recipe) -> RecipeDetailView {
        let interactor = RecipeDetailInteractor()
        let presenter = RecipeDetailPresenter()
        let router = RecipeDetailRouter()
        let viewModel = RecipeDetailViewModel(interactor: interactor, router: router)
        
        // Wire VIP dependencies
        interactor.presenter = presenter
        presenter.viewModel = viewModel
        
        return RecipeDetailView(recipe: recipe, viewModel: viewModel)
    }
}
```

#### **Worker Layer** (External Services)
- **Service Abstraction**: Database, API, file operations
- **Protocol-Based**: Easy mocking for tests

```swift
protocol RecipeDetailWorkerProtocol {
    func fetchRecipeDetails(_ recipeId: UUID) async throws -> Recipe
    func toggleFavorite(_ recipeId: UUID, _ isFavorite: Bool) async throws
}

class RecipeDetailWorker: RecipeDetailWorkerProtocol {
    func toggleFavorite(_ recipeId: UUID, _ isFavorite: Bool) async throws {
        // Database or API operations
        AppState.shared.toggleFavorite(recipeId)
    }
}
```

## Data Models 📊

### Core Models (`Core/Models/CoreModels.swift`)

#### **Recipe Model**
```swift
struct Recipe: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    var images: [RecipeImage]
    var ingredients: [Ingredient]
    var instructions: [CookingStep]
    var category: RecipeCategory
    var difficulty: DifficultyLevel
    var cookingTime: TimeInterval
    var prepTime: TimeInterval
    var servingSize: Int
    var nutritionalInfo: NutritionData?
    var tags: [String]
    var rating: Double
    var reviews: [Review]
    var createdBy: UUID
    var isPublic: Bool
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
}
```

#### **User Model**
```swift
struct User: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var email: String
    var profileImage: String?
    var preferences: UserPreferences
    var createdAt: Date
    var updatedAt: Date
}
```

#### **Meal Planning Models**
```swift
struct MealPlan: Identifiable, Codable {
    var id = UUID()
    var meals: [PlannedMeal]
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    var updatedAt: Date
}

struct PlannedMeal: Identifiable, Codable {
    var id = UUID()
    var recipeId: UUID
    var recipeName: String
    var mealType: MealType
    var scheduledDate: Date
    var servings: Int
    var notes: String?
    var isCompleted: Bool
    var wantToday: Bool
}
```

### Enums (`Core/Models/Enums.swift`)

#### **Recipe Categories**
```swift
enum RecipeCategory: String, CaseIterable, Codable, Hashable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case dessert = "Dessert"
    case snack = "Snack"
    case beverage = "Beverage"
}
```

#### **Difficulty Levels**
```swift
enum DifficultyLevel: String, CaseIterable, Codable, Hashable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case professional = "Professional"
}
```

#### **Measurement Units**
```swift
enum MeasurementUnit: String, CaseIterable, Codable, Hashable {
    // Volume - Metric
    case milliliters = "ml"
    case liters = "L"
    
    // Volume - Imperial
    case teaspoons = "tsp"
    case tablespoons = "tbsp"
    case cups = "cup"
    
    // Weight - Metric
    case grams = "g"
    case kilograms = "kg"
    
    // Weight - Imperial
    case ounces = "oz"
    case pounds = "lb"
}
```

## State Management 💾

### AppState (`State/AppState.swift`)
**Global app state using `@Observable`**

```swift
@MainActor
@Observable
class AppState {
    static let shared = AppState()
    
    // MARK: - Authentication State
    var currentUser: User?
    var isAuthenticated: Bool = false
    
    // MARK: - Recipe State
    var recipes: [Recipe] = []
    var favoriteRecipes: Set<UUID> = []
    var recentlyViewedRecipes: [UUID] = []
    
    // MARK: - Shopping Cart State
    var shoppingCart: ShoppingCart = ShoppingCart()
    
    // MARK: - Meal Planning State
    var currentMealPlan: MealPlan?
    var todayMeals: [PlannedMeal] = []
    var wantTodayMeals: [PlannedMeal] = []
    
    // MARK: - UI State
    var selectedTab: TabItem = .recipes
    var navigationPath: [String] = []
    var presentedSheets: Set<SheetType> = []
}
```

### Persistence
- **UserDefaults**: App settings and simple data
- **JSON Encoding**: Complex data structures
- **Keychain**: Secure user credentials

## Navigation System 🗺️

### AppCoordinator (`Navigation/AppCoordinator.swift`)
**Central navigation management**

```swift
struct AppCoordinator: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationRouter.createModule()
            }
        }
        .onAppear {
            setupNotificationObservers()
        }
    }
}
```

### Tab-Based Navigation
```swift
TabView(selection: $bindableAppState.selectedTab) {
    RecipeRouter.createModule()
        .tabItem { /* Recipes */ }
        .tag(TabItem.recipes)
    
    ShoppingRouter.createModule()
        .tabItem { /* Shopping */ }
        .tag(TabItem.shopping)
    
    MealPlannerRouter.createModule()
        .tabItem { /* Meal Planner */ }
        .tag(TabItem.planner)
    
    TodayRouter.createModule()
        .tabItem { /* Today */ }
        .tag(TabItem.today)
}
```

## UI Design System 🎨

### Colors (`UI/Styles/CookBookColors.swift`)
```swift
struct CookBookColors {
    static let primary = Color("CookBookGreen")
    static let secondary = Color("CookBookOrange")
    static let surface = Color("CookBookLightGray")
    static let background = Color("CookBookWhite")
    static let text = Color("CookBookDarkGray")
    static let textSecondary = Color("CookBookMediumGray")
}
```

### Typography (`UI/Styles/CookBookFonts.swift`)
```swift
struct CookBookFonts {
    static let largeTitle = Font.largeTitle
    static let title = Font.title
    static let title2 = Font.title2
    static let headline = Font.headline
    static let subheadline = Font.subheadline
    static let body = Font.body
    static let callout = Font.callout
    static let caption1 = Font.caption
    static let caption2 = Font.caption2
}
```

### Component Library (`Components/`)
- **RecipeImageView**: Async image loading with placeholder
- **ImageDebugView**: Development debugging tools

## Apple Watch Integration ⌚

### WatchConnectivityManager
**Bidirectional communication between iPhone and Apple Watch**

```swift
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    func sendTodayMeals(_ meals: [PlannedMeal]) {
        guard WCSession.default.isReachable else { return }
        
        let message = ["todayMeals": meals.compactMap { $0.watchRepresentation }]
        WCSession.default.sendMessage(message, replyHandler: nil)
    }
}
```

### Watch App Features
- Today's meal overview
- Shopping list sync
- Cooking timers
- Quick recipe access

## Services Layer 🔧

### NotificationManager (`Core/Services/NotificationManager.swift`)
**Local and push notifications**

```swift
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    func sendWantTodayNotification(meal: PlannedMeal) {
        let content = UNMutableNotificationContent()
        content.title = "Meal Reminder"
        content.body = "Don't forget: \(meal.recipeName) for \(meal.mealType.rawValue)"
        
        // Schedule notification
        scheduleNotification(content: content, trigger: trigger)
    }
    
    func triggerHapticFeedback(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}
```

## Development Guidelines 📋

### Code Organization Rules

#### **VIP Layer Responsibilities**

| Layer | Responsibilities | What NOT to do |
|-------|-----------------|----------------|
| **View** | UI rendering, user interactions | ❌ Business logic, data processing |
| **ViewModel** | State management, coordination | ❌ Direct API calls, complex business logic |
| **Interactor** | Business logic, data validation | ❌ UI updates, presentation formatting |
| **Presenter** | Data formatting, error handling | ❌ Business logic, UI manipulation |
| **Router** | Navigation, module creation | ❌ Business logic, data processing |

#### **File Naming Conventions**
```
Feature/
├── View/
│   ├── FeatureView.swift
│   └── FeatureViewModel.swift
├── Interactor/
│   ├── FeatureInteractor.swift
│   └── FeatureInteractorProtocol.swift
├── Presenter/
│   ├── FeaturePresenter.swift
│   └── FeaturePresenterProtocol.swift
├── Router/
│   ├── FeatureRouter.swift
│   └── FeatureRouterProtocol.swift
└── Worker/
    ├── FeatureWorker.swift
    └── FeatureWorkerProtocol.swift
```

### Swift Best Practices

#### **Property Wrappers**
```swift
// State management
@State private var selectedDate = Date()
@Environment(AppState.self) private var appState
@Observable class ViewModel { }

// Async operations
@MainActor
func updateUI() { }
```

#### **Error Handling**
```swift
// Result type for operations
enum RecipeError: Error {
    case notFound
    case invalidData
    case networkError(String)
}

// Async/await pattern
func fetchRecipe() async throws -> Recipe {
    // Implementation
}
```

#### **Protocol-Oriented Programming**
```swift
// Protocol for dependency injection
protocol RecipeServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
    func saveRecipe(_ recipe: Recipe) async throws
}

// Implementation
class RecipeService: RecipeServiceProtocol {
    // Implementation
}

// Mock for testing
class MockRecipeService: RecipeServiceProtocol {
    // Mock implementation
}
```

### Testing Strategy 🧪

#### **Unit Tests Structure**
```
Tests/
├── InteractorTests/
│   └── RecipeDetailInteractorTests.swift
├── PresenterTests/
│   └── RecipeDetailPresenterTests.swift
├── ViewModelTests/
│   └── RecipeDetailViewModelTests.swift
└── WorkerTests/
    └── RecipeDetailWorkerTests.swift
```

#### **Test Example**
```swift
class RecipeDetailInteractorTests: XCTestCase {
    var sut: RecipeDetailInteractor!
    var mockPresenter: MockRecipeDetailPresenter!
    var mockWorker: MockRecipeDetailWorker!
    
    override func setUp() {
        super.setUp()
        mockPresenter = MockRecipeDetailPresenter()
        mockWorker = MockRecipeDetailWorker()
        sut = RecipeDetailInteractor(worker: mockWorker)
        sut.presenter = mockPresenter
    }
    
    func testToggleFavorite_Success() async {
        // Given
        let recipeId = UUID()
        
        // When
        await sut.toggleFavorite(recipeId: recipeId, isFavorite: true)
        
        // Then
        XCTAssertTrue(mockWorker.toggleFavoriteCalled)
        XCTAssertTrue(mockPresenter.presentFavoriteToggledCalled)
    }
}
```

## Performance Optimization ⚡

### SwiftUI Performance
- **LazyVGrid/LazyVStack**: For large lists
- **@ViewBuilder**: For conditional views
- **Image caching**: AsyncImage with custom cache
- **State optimization**: Minimize @Published properties

### Memory Management
- **Weak references**: Prevent retain cycles in VIP
- **Actor isolation**: @MainActor for UI updates
- **Async operations**: Proper task cancellation

### Build Optimization
- **Asset catalogs**: Optimized image delivery
- **Xcode build settings**: Release optimization
- **App size**: Asset compression and unused code removal

## Deployment & Distribution 📦

### Build Configurations
- **Debug**: Development with mock data
- **Release**: Production with real services
- **TestFlight**: Beta testing configuration

### App Store Requirements
- **Privacy manifest**: Data usage disclosure
- **App icons**: All required sizes (iOS + watchOS)
- **Screenshots**: iPhone and Apple Watch
- **App Store description**: Feature highlights

## Architecture Benefits ✨

### **Maintainability**
- Clear separation of concerns
- Easy to locate and fix bugs
- Predictable code structure

### **Testability**
- Protocol-based dependency injection
- Each layer can be tested independently
- Easy mocking and stubbing

### **Scalability**
- New features follow established patterns
- Team members can work on different layers
- Consistent development approach

### **Reusability**
- Components can be reused across features
- Business logic separated from UI
- Platform-agnostic business layer

## Development Workflow 🔄

### **Module Creation Process**
1. Create feature folder structure
2. Define protocols for each layer
3. Implement VIP components
4. Wire dependencies in Router
5. Add to navigation system
6. Write tests
7. Add to UI/UX flow

### **Code Review Checklist**
- [ ] Follows VIP architecture
- [ ] Proper error handling
- [ ] Protocol-based design
- [ ] Unit tests included
- [ ] No retain cycles
- [ ] Performance considerations
- [ ] Accessibility support

---

*This documentation provides a comprehensive guide to understanding and developing with the CookBook Pro architecture. Follow these patterns and guidelines to maintain consistency and quality across the application.* 📚✨