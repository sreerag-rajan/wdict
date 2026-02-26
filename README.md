# WDICT (What Do I Cook Today)

**WDICT** is a Flutter application that helps you answer the daily question: "What do I cook today?". It acts as a personal recommendation engine that matches your currently available ingredients with your saved recipes.

## Features

- 🥕 **Ingredient Management**: Add, manage, and delete ingredients you have at home.
- 🍲 **Recipe Management**: Create and manage recipes, including adding images and mapping required ingredients.
- 🔍 **Smart Search**: Debounced search functionality across ingredients and recipes for quick access.
- 💡 **Recommendation Engine (WDICT)**: Select the ingredients you currently have, and the app will recommend recipes you can cook with a 100% ingredient match!
- 📌 **Pinning & Selection**: Easily pin selected ingredients while browsing.
- 📱 **Sketchy UI Aesthetics**: A unique chalk/pencil sketch visual style using custom fonts and UI elements.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Programming Language**: Dart
- **State Management**: Provider (`provider`)
- **Local Storage**: SQLite (`sqflite`, `sqflite_common_ffi`)
- **UI & Styling**: Custom Google Fonts (`google_fonts`), Cupertino Icons
- **Device Features**: Camera/Gallery integration (`image_picker`)

## Project Structure

```text
lib/
├── database/     # SQLite database connection and initialization setup
├── models/       # Data models definition (Ingredient, Recipe)
├── providers/    # State management providers (IngredientState, RecipeState)
├── repositories/ # Data access layer and algorithm logic
├── screens/      # UI Screens (Home Dashboard, Lists, Forms, WDICT Engine screen)
├── theme/        # App theming and styling configurations
├── utils/        # Helper classes and utility functions (e.g., Debouncer)
├── widgets/      # Reusable UI components
└── main.dart     # Entry point of the application
```

## Getting Started

### Prerequisites

- Flutter SDK (version `^3.11.0`)
- Dart SDK
- Android Studio / Xcode / VS Code for development and emulation

### Installation

1. Navigate to the `app` directory where this README is located:
   ```bash
   cd path/to/wdict/app
   ```

2. Install flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Release

To generate a release APK for Android:
```bash
flutter build apk --release
```
