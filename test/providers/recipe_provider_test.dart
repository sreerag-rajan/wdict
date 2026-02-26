import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/models/recipe.dart';
import 'package:wdict/providers/recipe_provider.dart';
import 'package:wdict/repositories/recipe_repository.dart';

class MockRecipeRepository implements RecipeRepository {
  List<Recipe> recipes = [];

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return recipes;
  }

  @override
  Future<Recipe?> getRecipeById(int id) async {
    try {
      return recipes.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Recipe> insertRecipe(Recipe recipe) async {
    final newRecipe = Recipe(
      id: recipes.length + 1,
      name: recipe.name,
      imagePath: recipe.imagePath,
      ingredients: recipe.ingredients,
    );
    recipes.add(newRecipe);
    return newRecipe;
  }

  @override
  Future<int> updateRecipe(Recipe recipe) async {
    final index = recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      recipes[index] = recipe;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteRecipe(int id) async {
    final initialLength = recipes.length;
    recipes.removeWhere((r) => r.id == id);
    return initialLength > recipes.length ? 1 : 0;
  }

  // To fix override error, providing any other required methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RecipeProvider Tests', () {
    late MockRecipeRepository mockRepository;
    late RecipeProvider provider;

    setUp(() {
      mockRepository = MockRecipeRepository();
      provider = RecipeProvider(mockRepository);
    });

    test('initial state is empty and not loading', () {
      expect(provider.recipes, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('loadRecipes updates state correctly', () async {
      mockRepository.recipes = [
        Recipe(id: 1, name: 'Pasta'),
        Recipe(id: 2, name: 'Burger'),
      ];

      final future = provider.loadRecipes();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.recipes.length, 2);
      expect(provider.recipes.first.name, 'Pasta');
    });

    test('addRecipe inserts and updates lists', () async {
      final newRecipe = Recipe(name: 'Salad');

      await provider.addRecipe(newRecipe);

      expect(provider.isLoading, isFalse);
      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'Salad');
      expect(provider.recipes.first.id, 1);
    });

    test('updateRecipe modifies existing recipe', () async {
      await provider.addRecipe(Recipe(name: 'Soup'));

      // The added recipe will have ID 1 based on our mock
      final addedRecipe = provider.recipes.first;
      final updatedRecipe = Recipe(id: addedRecipe.id, name: 'Chicken Soup');

      await provider.updateRecipe(updatedRecipe);

      expect(provider.recipes.length, 1);
      expect(provider.recipes.first.name, 'Chicken Soup');
    });

    test('deleteRecipe removes recipe from list', () async {
      await provider.addRecipe(Recipe(name: 'Pizza'));
      final id = provider.recipes.first.id!;

      expect(provider.recipes.length, 1);

      await provider.deleteRecipe(id);

      expect(provider.recipes.length, 0);
    });
  });
}
