import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/models/ingredient.dart';

void main() {
  group('Ingredient Model', () {
    test('toMap() should return a valid map with all properties', () {
      final ingredient = Ingredient(
        id: 1,
        name: 'Tomato',
        imagePath: 'path/to/tomato.png',
      );
      final map = ingredient.toMap();

      expect(map, {
        'id': 1,
        'name': 'Tomato',
        'image_path': 'path/to/tomato.png',
      });
    });

    test('toMap() should omit null properties', () {
      final ingredient = Ingredient(name: 'Salt');
      final map = ingredient.toMap();

      expect(map, {'name': 'Salt'});
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('image_path'), isFalse);
    });

    test('fromMap() should create an Ingredient from a valid map', () {
      final map = {'id': 2, 'name': 'Onion', 'image_path': 'path/to/onion.png'};
      final ingredient = Ingredient.fromMap(map);

      expect(ingredient.id, 2);
      expect(ingredient.name, 'Onion');
      expect(ingredient.imagePath, 'path/to/onion.png');
    });

    test('fromMap() should handle missing optional values', () {
      final map = {'name': 'Pepper'};
      final ingredient = Ingredient.fromMap(map);

      expect(ingredient.id, isNull);
      expect(ingredient.name, 'Pepper');
      expect(ingredient.imagePath, isNull);
    });

    test('Equality operator and hashCode should work correctly', () {
      final ingredient1 = Ingredient(
        id: 1,
        name: 'Garlic',
        imagePath: 'garlic.png',
      );
      final ingredient2 = Ingredient(
        id: 1,
        name: 'Garlic',
        imagePath: 'garlic.png',
      );
      final ingredient3 = Ingredient(
        id: 2,
        name: 'Garlic',
        imagePath: 'garlic.png',
      );

      expect(ingredient1, equals(ingredient2));
      expect(ingredient1.hashCode, equals(ingredient2.hashCode));
      expect(ingredient1, isNot(equals(ingredient3)));
      expect(ingredient1.hashCode, isNot(equals(ingredient3.hashCode)));
    });
  });
}
