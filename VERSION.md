# WDICT Version History

This document tracks the versions, features, and enhancements of the WDICT (What Do I Cook Today?) application. 

## [v1.0.0] - Initial Release

This is the foundational version of the WDICT app. It includes all the core functionalities required for ingredient management, recipe management, and the recommendation engine.

### MVP Features & Functionality

#### 🏠 Home Dashboard
* Custom "sketchy" UI aesthetic with custom Google Fonts and styling.
* Centered app logo in the app bar.
* Pyramid layout navigation (WDICT button centered at the top, Ingredients and Recipes buttons side-by-side below).

#### 🥕 Ingredient Management
* View a list of all saved ingredients.
* Add new ingredients.
* Delete ingredients (with swipe-to-delete and confirmation dialog).
* Debounced search bar to filter ingredients.
* SQLite local storage integration.

#### 🍲 Recipe Management
* View a list of all saved recipes.
* Create new recipes:
  * Add recipe name.
  * Attach recipe images (via device camera or gallery integration using `image_picker`).
  * Map required ingredients to the recipe.
* Delete recipes (with cascading updates and verification).
* Debounced search bar to filter recipes.
* Floating Action Button (FAB) for adding recipes and ingredients, styled and positioned above system navigation elements.

#### 💡 WDICT Recommendation Engine
* **Ingredient Selection UI**: 
  * Scrollable list of available ingredients.
  * Debounced search to quickly find ingredients.
  * Pinned selected ingredients (actively selected ingredients automatically pin to the top of the list).
* **Recommendation Algorithm**: 
  * Repository-level SQL logic that matches selected ingredients against recipe requirements. 
  * Returns a 100% match (recipes you have all the ingredients for).
* **Output Screen**: 
  * Loading states while checking recipes.
  * Displays a stylized list of matching recipes (names and images).
  * Graceful empty state when no matching recipes are found.

#### ⚙️ Technical Foundations
* **Framework**: Flutter (`^3.11.0`) with Dart.
* **State Management**: `provider` (IngredientState, RecipeState).
* **Database**: `sqflite` (SQLite) for robust local storage.
* Prepared for Android APK release builds with properly linked assets and fonts.
