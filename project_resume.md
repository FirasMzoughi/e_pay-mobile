# E-Pay Project Documentation

## Project Overview
**E-Pay** is a Flutter-based mobile application designed for purchasing digital goods (likely gaming currency or similar, given references to "Diamonds" and specific game aesthetics). The app features a modern, glassmorphic UI with both Light and Dark modes, multi-language support (English, Arabic, French, Italian), and a seamless user flow from onboarding to payment verification.

## Architecture & Structure
The project follows a standard Flutter architecture with a clear separation of concerns:
- **`lib/main.dart`**: Application entry point.
- **`lib/models/`**: Data definitions.
- **`lib/screens/`**: UI screens (Pages).
- **`lib/services/`**: Business logic and state management (Singleton pattern).
- **`lib/utils/`**: Constants, themes, and configuration.
- **`lib/widgets/`**: Reusable UI components.
- **`lib/l10n/`**: Localization files (inferred).

---

## Detailed File Analysis

### 1. Root (`lib/`)

#### `main.dart`
- **Purpose**: Initializes the application, binds services, and sets up the root widget tree.
- **Key Functions**:
  - `main()`: 
    - Calls `WidgetsFlutterBinding.ensureInitialized()` to prepare the engine.
    - Awaits initialization of `LanguageService` and `ThemeService`.
    - Runs the `EPayApp` widget.
  - `EPayApp` (Class):
    - Sets up `ValueListenableBuilder` listeners for both Language and Theme changes to ensure the app rebuilds dynamically.
    - Returns a `MaterialApp` configured with:
      - `theme`: Light theme from `AppTheme`.
      - `darkTheme`: Dark theme from `AppTheme`.
      - `locale`: Current active locale.
      - `localizationsDelegates`: For translation support.
      - `home`: Sets `OnboardingScreen` as the initial screen.

### 2. Models (`lib/models/`)

#### `models.dart`
- **Purpose**: Defines the data structures used throughout the app.
- **Classes**:
  - `Category`: Represents a product category (id, name, icon).
  - `Offer`: Represents a specific price point/package (e.g., "100 Diamonds" for "4.5 DT").
  - `Product`: Represents a sellable item containing detailed info (`imageUrl`, `description`, `rating`) and a list of `offers`.

### 3. Screens (`lib/screens/`)

#### `onboarding_screen.dart`
- **Purpose**: The first screen a user sees. Displays a tutorial/introduction carousel.
- **Key Components**:
  - `PageView.builder`: Displays 3 swipeable pages defined in the `pages` list.
  - `GradientButton`: "Next" button that advances the page or navigates to `LoginScreen` on the last step.
  - **State**: Tracks `_currentPage` to update the page indicator dots.

#### `login_screen.dart`
- **Purpose**: User authentication screen.
- **Key Flow**:
  - Displays the App Logo and a "Sign in with Google" button.
  - **Action**: Tapping the button navigates to `HomeScreen` (currently a value replacement, likely to be connected to actual Auth logic later).
  - Uses `GlassContainer` for a modern UI effect over a background image.

#### `home_screen.dart`
- **Purpose**: The main dashboard.
- **Key Components**:
  - `Header`: Shows user greeting, Theme Toggle, Language Selector, and Profile icon.
  - `Category List` (Horizontal): Allows filtering products by category (`_selectedCategory` state).
  - `Product Grid`: Displays products. Filters `MockData.products` based on the selected category.
  - **Navigation**: Tapping a product card navigates to `ProductDetailsScreen`.

#### `product_details_screen.dart`
- **Purpose**: Displays full details for a selected product.
- **Key Components**:
  - `Hero Image`: Large header image with a gradient overlay.
  - `Description`: Scrollable text description.
  - `Offers List`: Maps through `product.offers` to create cards.
  - **Action**: Tapping an offer opens the `PaymentBottomSheet`.

#### `chat_screen.dart`
- **Purpose**: Handles the "Transaction Details" and proof of payment. 
- **Note**: Despite the name "Chat", it acts more as a "Upload Receipt" screen.
- **Key Components**:
  - `Status Card`: Shows "Pending Verification".
  - `Upload Area`: A large touchable area to upload a screenshot of the payment.
  - `Confirm Button`: Shows a snackbar confirming the upload.

### 4. Services (`lib/services/`)

#### `language_service.dart`
- **Purpose**: Manages the app's active locale.
- **Pattern**: Singleton.
- **Key Functions**:
  - `init()`: Loads the saved language code from `SharedPreferences`.
  - `changeLanguage(String code)`: Updates the `localeNotifier` and persists the new code to local storage.

#### `theme_service.dart`
- **Purpose**: Manages the app's Light/Dark mode state.
- **Pattern**: Singleton.
- **Key Functions**:
  - `init()`: Loads the saved theme mode from `SharedPreferences`.
  - `toggleTheme()`: Switches between Light and Dark mode, updates `themeModeNotifier`, and saves the preference.

### 5. Utilities (`lib/utils/`)

#### `constants.dart`
- **Purpose**: Central definition of static values.
- **Classes**:
  - `AppColors`: Defines the color palette (Green accents, Blue secondary, various Gradients).
  - `AppConstants`: Global values like `borderRadius` (24.0) and padding.

#### `theme.dart`
- **Purpose**: Defines the Flutter `ThemeData` for the app.
- **Key Getters**:
  - `lightTheme`: Configures colors, fonts (Cairo), and component styles for Light Mode.
  - `darkTheme`: Equivalent configuration for Dark Mode.

#### `mock_data.dart`
- **Purpose**: Provides static lists of Dummy Data (`categories`, `products`) to populate the UI before a backend is connected.

### 6. Widgets (`lib/widgets/`)

#### `glass_container.dart`
- **Purpose**: A core UI building block that implements the "Glassmorphism" effect.
- **Implementation**: Uses `BackdropFilter` with `ImageFilter.blur` and semi-transparent white/black colors to create a frosted glass look.

#### `payment_bottom_sheet.dart`
- **Purpose**: A modal sheet showing payment methods (D17, Banque Zitouna).
- **Navigation**: Tapping an option closes the sheet and pushes `ChatScreen`.

#### `custom_buttons.dart`
- **Classes**:
  - `GradientButton`: A styled button with a linear gradient background and shadow.
  - `GlowingButton`: Wrapper for GradientButton (same logic).

#### `language_selector.dart`
- **Purpose**: A popup menu button to switch languages.
- **Logic**: Listens to `LanguageService` to show the current flag and updates language on selection.

#### `theme_toggle.dart`
- **Purpose**: A button to switch between Light and Dark modes.
- **Animation**: Uses `AnimatedSwitcher` to smoothly transition the icon between Sun and Moon.

---

## User Flow Summary
1. **Start**: App opens `OnboardingScreen`.
2. **Onboarding**: User swipes through 3 intro slides -> clicks "Get Started" -> `LoginScreen`.
3. **Login**: User clicks "Sign in with Google" -> `HomeScreen`.
4. **Browse**: User sees categories and products. Filters by category.
5. **Select**: User taps a product -> `ProductDetailsScreen`.
6. **Buy**: User taps a price offer -> `PaymentBottomSheet` appears.
7. **Pay**: User selects "D17" or "Zitouna" -> `ChatScreen`.
8. **Verify**: User uploads payment screenshot -> Transaction confirmed (mocked).
