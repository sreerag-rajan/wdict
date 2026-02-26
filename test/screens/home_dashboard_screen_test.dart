import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wdict/screens/home_dashboard_screen.dart';
import 'package:wdict/screens/ingredient_management_screen.dart';
import 'package:wdict/screens/recipe_management_screen.dart';
import 'package:wdict/screens/wdict_engine_screen.dart';
import 'package:wdict/providers/ingredient_provider.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/providers/recipe_provider.dart';
import 'package:wdict/models/recipe.dart';

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
  Future<void> deleteRecipe(int id) async {}
}

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<IngredientProvider>(
          create: (_) => MockIngredientProvider(),
        ),
        ChangeNotifierProvider<RecipeProvider>(
          create: (_) => MockRecipeProvider(),
        ),
      ],
      child: const MaterialApp(home: HomeDashboardScreen()),
    );
  }

  group('HomeDashboardScreen Widget Tests', () {
    testWidgets('renders three navigation cards with correct titles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('WDICT'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets(
      'navigates to IngredientManagementScreen when Ingredients card is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final title = find.text('Ingredients');
        await tester.tap(title);
        await tester.pumpAndSettle();

        expect(find.byType(IngredientManagementScreen), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to RecipeManagementScreen when Recipes card is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final title = find.text('Recipes');
        await tester.tap(title);
        await tester.pumpAndSettle();

        expect(find.byType(RecipeManagementScreen), findsOneWidget);
      },
    );

    testWidgets('navigates to WdictEngineScreen when WDICT card is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final title = find.text('WDICT');
      await tester.tap(title);
      await tester.pumpAndSettle();

      expect(find.byType(WdictEngineScreen), findsOneWidget);
    });
  });
}
