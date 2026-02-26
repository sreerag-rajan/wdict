import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/providers/ingredient_provider.dart';
import 'package:wdict/repositories/ingredient_repository.dart';

// A simple mock since we just need to verify the provider calls methods and updates state
class MockIngredientRepository implements IngredientRepository {
  List<Ingredient> ingredients = [];

  @override
  Future<List<Ingredient>> getAllIngredients() async {
    return ingredients;
  }

  @override
  Future<Ingredient?> getIngredientById(int id) async {
    try {
      return ingredients.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Ingredient> insertIngredient(Ingredient ingredient) async {
    final newIngredient = Ingredient(
      id: ingredients.length + 1,
      name: ingredient.name,
      imagePath: ingredient.imagePath,
    );
    ingredients.add(newIngredient);
    return newIngredient;
  }

  @override
  Future<int> updateIngredient(Ingredient ingredient) async {
    final index = ingredients.indexWhere((i) => i.id == ingredient.id);
    if (index != -1) {
      ingredients[index] = ingredient;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteIngredient(int id) async {
    final initialLength = ingredients.length;
    ingredients.removeWhere((i) => i.id == id);
    return initialLength > ingredients.length ? 1 : 0;
  }

  // To fix override error, providing any other required methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('IngredientProvider Tests', () {
    late MockIngredientRepository mockRepository;
    late IngredientProvider provider;

    setUp(() {
      mockRepository = MockIngredientRepository();
      provider = IngredientProvider(mockRepository);
    });

    test('initial state is empty and not loading', () {
      expect(provider.ingredients, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('loadIngredients updates state correctly', () async {
      mockRepository.ingredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Onion'),
      ];

      final future = provider.loadIngredients();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.ingredients.length, 2);
      expect(provider.ingredients.first.name, 'Tomato');
    });

    test('addIngredient inserts and updates lists', () async {
      final newIngredient = Ingredient(name: 'Potato');

      await provider.addIngredient(newIngredient);

      expect(provider.isLoading, isFalse);
      expect(provider.ingredients.length, 1);
      expect(provider.ingredients.first.name, 'Potato');
      expect(provider.ingredients.first.id, 1);
    });

    test('updateIngredient modifies existing ingredient', () async {
      await provider.addIngredient(Ingredient(name: 'Beef'));

      // The added ingredient will have ID 1 based on our mock
      final addedIngredient = provider.ingredients.first;
      final updatedIngredient = Ingredient(
        id: addedIngredient.id,
        name: 'Ground Beef',
      );

      await provider.updateIngredient(updatedIngredient);

      expect(provider.ingredients.length, 1);
      expect(provider.ingredients.first.name, 'Ground Beef');
    });

    test('deleteIngredient removes ingredient from list', () async {
      await provider.addIngredient(Ingredient(name: 'Salt'));
      final id = provider.ingredients.first.id!;

      expect(provider.ingredients.length, 1);

      await provider.deleteIngredient(id);

      expect(provider.ingredients.length, 0);
    });
  });
}
