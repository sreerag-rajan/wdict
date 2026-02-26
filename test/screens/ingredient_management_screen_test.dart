import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/providers/ingredient_provider.dart';
import 'package:wdict/screens/ingredient_management_screen.dart';
import 'package:wdict/widgets/custom_list_tile.dart';
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
  Future<void> deleteIngredient(int id) async {
    ingredients.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}

void main() {
  Widget createTestWidget(IngredientProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<IngredientProvider>.value(
        value: provider,
        child: const IngredientManagementScreen(),
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

  testWidgets('shows error message when error is present', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    provider.error = 'Something went wrong';

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Oops! Something went wrong'), findsOneWidget);
  });

  testWidgets('shows empty state when ingredients list is empty', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.textContaining('Your pantry is empty'), findsOneWidget);
  });

  testWidgets('displays list of ingredients when loaded', (
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
  });

  testWidgets('swiping ingredient dismisses it and calls delete', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    provider.ingredients = [Ingredient(id: 1, name: 'Salt')];

    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Salt'), findsOneWidget);

    // Swipe right to delete
    await tester.drag(find.byType(Dismissible), const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Confirm Deletion'), findsOneWidget);
    expect(
      find.textContaining('Are you sure you want to delete "Salt"?'),
      findsOneWidget,
    );

    // Tap DELETE
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    expect(find.text('Salt'), findsNothing);
    expect(provider.ingredients.isEmpty, true);
    expect(find.text('Salt deleted'), findsOneWidget); // SnackBar
  });

  testWidgets('shows Add Ingredient FloatingActionButton', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    await tester.pumpWidget(createTestWidget(provider));

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
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
}
