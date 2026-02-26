import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/models/recipe.dart';
import 'package:wdict/providers/ingredient_provider.dart';
import 'package:wdict/providers/recipe_provider.dart';
import 'package:wdict/screens/add_edit_recipe_screen.dart';

class MockIngredientProvider extends ChangeNotifier
    implements IngredientProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  List<Ingredient> ingredients = [
    Ingredient(id: 1, name: 'Salt'),
    Ingredient(id: 2, name: 'Pepper'),
  ];

  @override
  Future<void> loadIngredients() async {}

  @override
  Future<void> addIngredient(Ingredient ingredient) async {}

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {}

  @override
  Future<void> deleteIngredient(int id) async {}
}

class MockRecipeProvider extends ChangeNotifier implements RecipeProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  List<Recipe> recipes = [];

  bool addCalled = false;
  bool updateCalled = false;
  Recipe? lastRecipe;

  @override
  Future<void> loadRecipes() async {}

  @override
  Future<void> addRecipe(Recipe recipe) async {
    addCalled = true;
    lastRecipe = recipe;
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    updateCalled = true;
    lastRecipe = recipe;
  }

  @override
  Future<void> deleteRecipe(int id) async {}
}

void main() {
  Widget createTestWidget(
    IngredientProvider iProvider,
    RecipeProvider rProvider, {
    Recipe? recipe,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<IngredientProvider>.value(value: iProvider),
          ChangeNotifierProvider<RecipeProvider>.value(value: rProvider),
        ],
        child: AddEditRecipeScreen(recipe: recipe),
      ),
    );
  }

  testWidgets('renders add recipe screen components', (
    WidgetTester tester,
  ) async {
    final iProvider = MockIngredientProvider();
    final rProvider = MockRecipeProvider();
    await tester.pumpWidget(createTestWidget(iProvider, rProvider));

    expect(find.text('Add Recipe'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Required Ingredients'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget);
    expect(find.text('Pepper'), findsOneWidget);
    expect(find.text('Save Recipe'), findsOneWidget);
  });

  testWidgets('shows validation error when name is empty', (
    WidgetTester tester,
  ) async {
    final iProvider = MockIngredientProvider();
    final rProvider = MockRecipeProvider();
    await tester.pumpWidget(createTestWidget(iProvider, rProvider));

    // Tap save without entering a name
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a name for the recipe.'), findsOneWidget);
    expect(rProvider.addCalled, isFalse);
  });

  testWidgets('shows validation error when no ingredients selected', (
    WidgetTester tester,
  ) async {
    final iProvider = MockIngredientProvider();
    final rProvider = MockRecipeProvider();
    await tester.pumpWidget(createTestWidget(iProvider, rProvider));

    // Enter a name
    await tester.enterText(find.byType(TextFormField), 'Salt Water');
    await tester.pumpAndSettle();

    // Tap save without selecting ingredients
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Please select at least one ingredient.'), findsOneWidget);
    expect(rProvider.addCalled, isFalse);
  });

  testWidgets('calls addRecipe when form is valid', (
    WidgetTester tester,
  ) async {
    final iProvider = MockIngredientProvider();
    final rProvider = MockRecipeProvider();
    await tester.pumpWidget(createTestWidget(iProvider, rProvider));

    // Enter a name
    await tester.enterText(find.byType(TextFormField), 'Salt Water');
    await tester.pumpAndSettle();

    // Select an ingredient
    await tester.tap(find.text('Salt'));
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(rProvider.addCalled, isTrue);
    expect(rProvider.lastRecipe?.name, 'Salt Water');
    expect(rProvider.lastRecipe?.ingredients?.length, 1);
    expect(rProvider.lastRecipe?.ingredients?.first.name, 'Salt');
  });

  testWidgets('calls updateRecipe when editing', (WidgetTester tester) async {
    final iProvider = MockIngredientProvider();
    final rProvider = MockRecipeProvider();
    final recipe = Recipe(
      id: 1,
      name: 'Old Recipe',
      ingredients: [Ingredient(id: 1, name: 'Salt')],
    );

    await tester.pumpWidget(
      createTestWidget(iProvider, rProvider, recipe: recipe),
    );

    // Initial state check
    expect(find.text('Old Recipe'), findsOneWidget);
    // The checkbox for Salt should be checked, but testing visual state is tricky. Let's just modify the form.

    // Change the name
    await tester.enterText(find.byType(TextFormField), 'New Recipe');
    await tester.pumpAndSettle();

    // Add pepper
    await tester.tap(find.text('Pepper'));
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(rProvider.updateCalled, isTrue);
    expect(rProvider.lastRecipe?.id, 1);
    expect(rProvider.lastRecipe?.name, 'New Recipe');
    expect(rProvider.lastRecipe?.ingredients?.length, 2);
  });
}
