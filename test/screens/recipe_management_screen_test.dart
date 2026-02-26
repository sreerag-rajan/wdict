import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wdict/models/recipe.dart';
import 'package:wdict/providers/recipe_provider.dart';
import 'package:wdict/screens/recipe_management_screen.dart';
import 'package:wdict/widgets/custom_list_tile.dart';
import 'package:wdict/widgets/loading_indicator.dart';

class MockRecipeProvider extends ChangeNotifier implements RecipeProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  List<Recipe> recipes = [];

  @override
  Future<void> loadRecipes() async {}

  @override
  Future<void> addRecipe(Recipe recipe) async {}

  @override
  Future<void> updateRecipe(Recipe recipe) async {}

  @override
  Future<void> deleteRecipe(int id) async {
    recipes.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}

void main() {
  Widget createTestWidget(RecipeProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<RecipeProvider>.value(
        value: provider,
        child: const RecipeManagementScreen(),
      ),
    );
  }

  testWidgets('shows loading indicator when isLoading is true', (
    WidgetTester tester,
  ) async {
    final provider = MockRecipeProvider();
    provider.isLoading = true;

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.byType(SketchyLoadingIndicator), findsOneWidget);
  });

  testWidgets('shows error message when error is present', (
    WidgetTester tester,
  ) async {
    final provider = MockRecipeProvider();
    provider.error = 'Something went wrong';

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Oops! Something went wrong'), findsOneWidget);
  });

  testWidgets('shows empty state when recipes list is empty', (
    WidgetTester tester,
  ) async {
    final provider = MockRecipeProvider();

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.textContaining('No recipes yet'), findsOneWidget);
  });

  testWidgets('displays list of recipes when loaded', (
    WidgetTester tester,
  ) async {
    final provider = MockRecipeProvider();
    provider.recipes = [
      Recipe(id: 1, name: 'Pasta'),
      Recipe(id: 2, name: 'Salad'),
    ];

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('Salad'), findsOneWidget);
    expect(find.byType(SketchyListTile), findsNWidgets(2));
  });

  testWidgets('swiping recipe dismisses it and calls delete', (
    WidgetTester tester,
  ) async {
    final provider = MockRecipeProvider();
    provider.recipes = [Recipe(id: 1, name: 'Pasta')];

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Pasta'), findsOneWidget);

    // Swipe right to delete
    await tester.drag(find.byType(Dismissible), const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Confirm Deletion'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete "Pasta"?'),
      findsOneWidget,
    );

    // Tap DELETE
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    expect(find.text('Pasta'), findsNothing);
    expect(provider.recipes.isEmpty, true);
    expect(find.text('Pasta deleted'), findsOneWidget); // SnackBar
  });

  testWidgets('shows Add Recipe FloatingActionButton', (
    WidgetTester tester,
  ) async {
    final provider = MockRecipeProvider();
    await tester.pumpWidget(createTestWidget(provider));

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('shows search bar and filters list correctly', (
    WidgetTester tester,
  ) async {
    final provider = MockRecipeProvider();
    provider.recipes = [
      Recipe(id: 1, name: 'Pasta'),
      Recipe(id: 2, name: 'Salad'),
      Recipe(id: 3, name: 'Pizza'),
    ];

    await tester.pumpWidget(createTestWidget(provider));

    // Verify all items are shown initially
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('Salad'), findsOneWidget);
    expect(find.text('Pizza'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'piz');

    // Wait for debouncer (300ms)
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify filtered results
    expect(find.text('Pasta'), findsNothing);
    expect(find.text('Salad'), findsNothing);
    expect(find.text('Pizza'), findsOneWidget);

    // Enter query with no matches
    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify empty state text
    expect(find.text('No matches found.'), findsOneWidget);
  });
}
