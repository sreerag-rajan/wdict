import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wdict/models/recipe.dart';
import 'package:wdict/repositories/recipe_repository.dart';
import 'package:wdict/screens/wdict_result_screen.dart';
import 'package:wdict/widgets/custom_button.dart';
import 'package:wdict/widgets/custom_list_tile.dart';
import 'package:wdict/widgets/image_placeholder.dart';
import 'package:wdict/widgets/loading_indicator.dart';

// Mock repository
class MockRecipeRepository extends RecipeRepository {
  final Future<List<Recipe>> Function(List<int>) getRecommendationsCallback;

  MockRecipeRepository({required this.getRecommendationsCallback});

  @override
  Future<List<Recipe>> getRecommendations(List<int> availableIngredientIds) {
    return getRecommendationsCallback(availableIngredientIds);
  }
}

void main() {
  Widget createWidgetUnderTest({
    required RecipeRepository recipeRepository,
    required List<int> selectedIngredientIds,
  }) {
    return MultiProvider(
      providers: [Provider<RecipeRepository>.value(value: recipeRepository)],
      child: MaterialApp(
        home: WdictResultScreen(selectedIngredientIds: selectedIngredientIds),
      ),
    );
  }

  group('WdictResultScreen', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      final mockRepo = MockRecipeRepository(
        getRecommendationsCallback: (_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return [];
        },
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          recipeRepository: mockRepo,
          selectedIngredientIds: [1],
        ),
      );

      expect(find.byType(SketchyLoadingIndicator), findsOneWidget);
      expect(find.text('Finding perfect matches...'), findsOneWidget);

      await tester.pumpAndSettle(); // Wait for future to complete
    });

    testWidgets('shows empty state when no matches found', (
      WidgetTester tester,
    ) async {
      final mockRepo = MockRecipeRepository(
        getRecommendationsCallback: (_) async => [],
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          recipeRepository: mockRepo,
          selectedIngredientIds: [1, 2],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No perfect matches found.'), findsOneWidget);
      expect(find.byType(SketchyImagePlaceholder), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('shows list of recipes when matches found', (
      WidgetTester tester,
    ) async {
      final mockRecipes = [
        Recipe(
          id: 1,
          name: 'Spaghetti Bolognese',
          imagePath: null,
          ingredients: [],
        ),
        Recipe(id: 2, name: 'Tomato Soup', imagePath: null, ingredients: []),
      ];

      final mockRepo = MockRecipeRepository(
        getRecommendationsCallback: (_) async => mockRecipes,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          recipeRepository: mockRepo,
          selectedIngredientIds: [1, 2, 3],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SketchyListTile), findsNWidgets(2));
      expect(find.text('Spaghetti Bolognese'), findsOneWidget);
      expect(find.text('Tomato Soup'), findsOneWidget);
    });

    testWidgets('back to dashboard button works', (WidgetTester tester) async {
      final mockRepo = MockRecipeRepository(
        getRecommendationsCallback: (_) async => [],
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          recipeRepository: mockRepo,
          selectedIngredientIds: [1],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back to Dashboard'), findsOneWidget);
      expect(find.byType(SketchyButton), findsWidgets);
    });
  });
}
