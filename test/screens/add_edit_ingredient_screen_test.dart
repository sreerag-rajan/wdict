import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/providers/ingredient_provider.dart';
import 'package:wdict/screens/add_edit_ingredient_screen.dart';

class MockIngredientProvider extends ChangeNotifier
    implements IngredientProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  List<Ingredient> ingredients = [];

  bool addCalled = false;
  bool updateCalled = false;
  Ingredient? lastIngredient;

  @override
  Future<void> loadIngredients() async {}

  @override
  Future<void> addIngredient(Ingredient ingredient) async {
    addCalled = true;
    lastIngredient = ingredient;
  }

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {
    updateCalled = true;
    lastIngredient = ingredient;
  }

  @override
  Future<void> deleteIngredient(int id) async {}
}

void main() {
  Widget createTestWidget(
    IngredientProvider provider, {
    Ingredient? ingredient,
  }) {
    return MaterialApp(
      home: ChangeNotifierProvider<IngredientProvider>.value(
        value: provider,
        child: AddEditIngredientScreen(ingredient: ingredient),
      ),
    );
  }

  testWidgets('renders add ingredient screen components', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    await tester.pumpWidget(createTestWidget(provider));

    expect(find.text('Add Ingredient'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Save Ingredient'), findsOneWidget);
  });

  testWidgets('renders edit ingredient screen components', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    final ingredient = Ingredient(id: 1, name: 'Salt');
    await tester.pumpWidget(createTestWidget(provider, ingredient: ingredient));

    expect(find.text('Edit Ingredient'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget); // Text field should be populated
    expect(find.text('Save Ingredient'), findsOneWidget);
  });

  testWidgets('shows validation error when name is empty', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    await tester.pumpWidget(createTestWidget(provider));

    // Tap save without entering a name
    await tester.tap(find.text('Save Ingredient'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a name for the ingredient.'),
      findsOneWidget,
    );
    expect(provider.addCalled, isFalse);
  });

  testWidgets('calls addIngredient when form is valid', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    await tester.pumpWidget(createTestWidget(provider));

    // Enter a name
    await tester.enterText(find.byType(TextFormField), 'Pepper');
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.text('Save Ingredient'));
    await tester.pumpAndSettle();

    expect(provider.addCalled, isTrue);
    expect(provider.lastIngredient?.name, 'Pepper');
  });

  testWidgets('calls updateIngredient when editing', (
    WidgetTester tester,
  ) async {
    final provider = MockIngredientProvider();
    final ingredient = Ingredient(id: 1, name: 'Salt');
    await tester.pumpWidget(createTestWidget(provider, ingredient: ingredient));

    // Change the name
    await tester.enterText(find.byType(TextFormField), 'Sea Salt');
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.text('Save Ingredient'));
    await tester.pumpAndSettle();

    expect(provider.updateCalled, isTrue);
    expect(provider.lastIngredient?.name, 'Sea Salt');
    expect(provider.lastIngredient?.id, 1);
  });
}
