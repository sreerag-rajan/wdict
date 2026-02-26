import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/models/recipe.dart';
import 'package:wdict/models/ingredient.dart';

void main() {
  group('Recipe Model', () {
    test('toMap() should return a valid map with all base properties', () {
      final recipe = Recipe(
        id: 1,
        name: 'Pasta',
        imagePath: 'path/to/pasta.png',
      );
      final map = recipe.toMap();

      expect(map, {
        'id': 1,
        'name': 'Pasta',
        'image_path': 'path/to/pasta.png',
      });
    });

    test('toMap() should omit null properties', () {
      final recipe = Recipe(name: 'Salad');
      final map = recipe.toMap();

      expect(map, {'name': 'Salad'});
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('image_path'), isFalse);
    });

    test('fromMap() should create a Recipe from a valid map', () {
      final map = {'id': 2, 'name': 'Pizza', 'image_path': 'path/to/pizza.png'};
      final recipe = Recipe.fromMap(map);

      expect(recipe.id, 2);
      expect(recipe.name, 'Pizza');
      expect(recipe.imagePath, 'path/to/pizza.png');
      expect(recipe.ingredients, isNull);
    });

    test('fromMap() should handle missing optional values', () {
      final map = {'name': 'Soup'};
      final recipe = Recipe.fromMap(map);

      expect(recipe.id, isNull);
      expect(recipe.name, 'Soup');
      expect(recipe.imagePath, isNull);
      expect(recipe.ingredients, isNull);
    });

    test('Should optionally store associated ingredients', () {
      final ingredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Basil'),
      ];
      final recipe = Recipe(
        id: 3,
        name: 'Tomato Soup',
        ingredients: ingredients,
      );

      expect(recipe.ingredients, isNotNull);
      expect(recipe.ingredients!.length, 2);
      expect(recipe.ingredients![0].name, 'Tomato');
    });

    test(
      'Equality operator and hashCode should work correctly based on primitive fields',
      () {
        final recipe1 = Recipe(id: 1, name: 'Steak', imagePath: 'steak.png');
        final recipe2 = Recipe(id: 1, name: 'Steak', imagePath: 'steak.png');
        final recipe3 = Recipe(id: 2, name: 'Steak', imagePath: 'steak.png');

        expect(recipe1, equals(recipe2));
        expect(recipe1.hashCode, equals(recipe2.hashCode));
        expect(recipe1, isNot(equals(recipe3)));
        expect(recipe1.hashCode, isNot(equals(recipe3.hashCode)));
      },
    );
  });
}
