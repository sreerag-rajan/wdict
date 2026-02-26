import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/providers/ingredient_provider.dart';
import 'package:wdict/screens/wdict_engine_screen.dart';
import 'package:wdict/widgets/custom_list_tile.dart';
import 'package:wdict/widgets/custom_button.dart';
import 'package:wdict/widgets/loading_indicator.dart';

class MockIngredientProvider extends ChangeNotifier
    implements IngredientProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  List<Ingredient> ingredients = [];

  @override
  Future<void> loadIngredients() async {}

  @override
  Future<void> addIngredient(Ingredient ingredient) async {}

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {}

  @override
  Future<void> deleteIngredient(int id) async {}
}

void main() {
  Widget createTestWidget(IngredientProvider provider) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/wdict-results') {
          return MaterialPageRoute(
            builder: (context) =>
                const Scaffold(body: Text('Mock Result Screen')),
          );
        }
        return null;
      },
      home: ChangeNotifierProvider<IngredientProvider>.value(
        value: provider,
        child: const WdictEngineScreen(),
      ),
    );
  }

  testWidgets('shows loading indicator when isLoading is true', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    provider.isLoading = true;

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.byType(SketchyLoadingIndicator), findsOneWidget);
  });

  testWidgets('shows error message', (WidgetTester tester) async {
    final provider = MockIngredientProvider();
    provider.error = 'Test error';

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Oops! Test error'), findsOneWidget);
  });

  testWidgets('shows empty state message', (WidgetTester tester) async {
    final provider = MockIngredientProvider();

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.textContaining('Your pantry is empty.'), findsOneWidget);
  });

  testWidgets('displays ingredients and allows toggling selection', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    provider.ingredients = [
      Ingredient(id: 1, name: 'Salt'),
      Ingredient(id: 2, name: 'Pepper'),
    ];

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Salt'), findsOneWidget);
    expect(find.text('Pepper'), findsOneWidget);
    expect(find.byType(SketchyListTile), findsNWidgets(2));

    // Initially unselected, icons should be circle_outlined
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    // Tap 'Salt'
    await tester.tap(find.text('Salt'));
    await tester.pumpAndSettle();

    // Now 'Salt' should be selected
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

    // Tap 'Salt' again
    await tester.tap(find.text('Salt'));
    await tester.pumpAndSettle();

    // Should be unselected again
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });

  testWidgets('What can I cook button interactions', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    provider.ingredients = [Ingredient(id: 1, name: 'Salt')];

    await tester.pumpWidget(createTestWidget(provider));

    final buttonFinder = find.widgetWithText(SketchyButton, 'What can I cook?');
    expect(buttonFinder, findsOneWidget);

    // Tap when nothing is selected
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Route should not change
    expect(find.text('Mock Result Screen'), findsNothing);

    // Tap the ingredient to select it
    await tester.tap(find.text('Salt'));
    await tester.pumpAndSettle();

    // Tap the button again
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Route SHOULD change to mock result screen
    expect(find.text('Mock Result Screen'), findsOneWidget);
  });

  testWidgets('shows search bar and filters list correctly', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    provider.ingredients = [
      Ingredient(id: 1, name: 'Salt'),
      Ingredient(id: 2, name: 'Pepper'),
      Ingredient(id: 3, name: 'Paprika'),
    ];

    await tester.pumpWidget(createTestWidget(provider));

    // Verify all items are shown initially
    expect(find.text('Salt'), findsOneWidget);
    expect(find.text('Pepper'), findsOneWidget);
    expect(find.text('Paprika'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'pap');

    // Wait for debouncer (300ms)
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify filtered results
    expect(find.text('Salt'), findsNothing);
    expect(find.text('Pepper'), findsNothing);
    expect(find.text('Paprika'), findsOneWidget);

    // Enter query with no matches
    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify empty state text
    expect(find.text('No matches found.'), findsOneWidget);
  });

  testWidgets('pins selected items to the top and filters unselected items', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    provider.ingredients = [
      Ingredient(id: 1, name: 'Salt'),
      Ingredient(id: 2, name: 'Pepper'),
      Ingredient(id: 3, name: 'Paprika'),
    ];

    await tester.pumpWidget(createTestWidget(provider));

    // Select 'Salt'
    await tester.tap(find.text('Salt'));
    await tester.pumpAndSettle();

    // Verify it is selected
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    // Enter search query that doesn't match 'Salt' but matches 'Paprika'
    await tester.enterText(find.byType(TextField), 'pap');

    // Wait for debouncer (300ms)
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 'Salt' should still be visible because it's selected (pinned to top)
    expect(find.text('Salt'), findsOneWidget);
    // 'Paprika' should be visible because it matches query
    expect(find.text('Paprika'), findsOneWidget);
    // 'Pepper' should NOT be visible
    expect(find.text('Pepper'), findsNothing);
  });
}
