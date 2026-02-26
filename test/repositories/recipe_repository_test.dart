import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wdict/database/database_helper.dart';
import 'package:wdict/models/recipe.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/repositories/recipe_repository.dart';
import 'package:wdict/repositories/ingredient_repository.dart';

void main() {
  late Directory tempDir;
  late RecipeRepository recipeRepository;
  late IngredientRepository ingredientRepository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    tempDir = await Directory.systemTemp.createTemp('wdict_test_repo_recipe');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );

    recipeRepository = RecipeRepository();
    ingredientRepository = IngredientRepository();
  });

  tearDownAll(() async {
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
      debugPrint('Warning: unable to delete temp directory: $e');
    }
  });

  tearDown(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(DatabaseHelper.tableRecipeIngredients);
    await db.delete(DatabaseHelper.tableRecipes);
    await db.delete(DatabaseHelper.tableIngredients);
    // clear copied image files
    for (var entity in tempDir.listSync()) {
      if (entity is File &&
          !entity.path.endsWith('.db') &&
          !entity.path.endsWith('-journal')) {
        entity.deleteSync();
      }
    }
  });

  test('CRUD operations work correctly for recipes with ingredients', () async {
    // 1. Insert ingredients
    final insertedIngredient1 = await ingredientRepository.insertIngredient(
      Ingredient(name: 'Tomato'),
    );
    final insertedIngredient2 = await ingredientRepository.insertIngredient(
      Ingredient(name: 'Onion'),
    );

    // 2. Insert recipe
    final newRecipe = Recipe(
      name: 'Tomato Soup',
      ingredients: [insertedIngredient1, insertedIngredient2],
    );
    final insertedRecipe = await recipeRepository.insertRecipe(newRecipe);

    expect(insertedRecipe.id, isNotNull);
    expect(insertedRecipe.name, 'Tomato Soup');
    expect(insertedRecipe.imagePath, isNull);
    expect(insertedRecipe.ingredients!.length, 2);

    // 3. Retrieve All Recipes
    var all = await recipeRepository.getAllRecipes();
    expect(all.length, 1);
    expect(all.first.name, 'Tomato Soup');
    expect(all.first.ingredients!.length, 2);
    expect(
      all.first.ingredients!.map((i) => i.name).toList(),
      containsAll(['Tomato', 'Onion']),
    );

    // 4. Retrieve By Id
    var fetched = await recipeRepository.getRecipeById(insertedRecipe.id!);
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Tomato Soup');
    expect(fetched.ingredients!.length, 2);

    // 5. Update Recipe
    final insertedIngredient3 = await ingredientRepository.insertIngredient(
      Ingredient(name: 'Garlic'),
    );
    final updatedRecipe = Recipe(
      id: insertedRecipe.id,
      name: 'Garlic Tomato Soup',
      ingredients: [
        insertedIngredient1,
        insertedIngredient3,
      ], // Replaced Onion with Garlic
    );
    await recipeRepository.updateRecipe(updatedRecipe);

    var afterUpdate = await recipeRepository.getRecipeById(insertedRecipe.id!);
    expect(afterUpdate!.name, 'Garlic Tomato Soup');
    expect(afterUpdate.ingredients!.length, 2);
    expect(
      afterUpdate.ingredients!.map((i) => i.name).toList(),
      containsAll(['Tomato', 'Garlic']),
    );

    // 6. Delete Recipe and check cascading delete
    await recipeRepository.deleteRecipe(insertedRecipe.id!);
    all = await recipeRepository.getAllRecipes();
    expect(all.isEmpty, isTrue);

    // Verify cascading deletes on recipe_ingredients
    final db = await DatabaseHelper.instance.database;
    final joinRows = await db.query(
      DatabaseHelper.tableRecipeIngredients,
      where: 'recipe_id = ?',
      whereArgs: [insertedRecipe.id],
    );
    expect(joinRows.isEmpty, isTrue);

    // Verify ingredients still exist
    final allIngredients = await ingredientRepository.getAllIngredients();
    expect(allIngredients.length, 3);
  });

  test('Recipe image handling works correctly', () async {
    // Create a dummy image file outside documents directory
    final dummyImageDir = await Directory.systemTemp.createTemp(
      'dummy_images_recipe',
    );
    final originalFile = File(join(dummyImageDir.path, 'recipe_image.jpg'));
    await originalFile.writeAsString('fake image data');

    final recipeWithImage = Recipe(name: 'Salad', imagePath: originalFile.path);

    // Insert
    final inserted = await recipeRepository.insertRecipe(recipeWithImage);

    // Image path should be updated
    expect(inserted.imagePath, isNotNull);
    expect(inserted.imagePath!.startsWith(tempDir.path), isTrue);
    expect(basename(inserted.imagePath!), contains('recipe_image.jpg'));

    // DB should hold filename
    final db = await DatabaseHelper.instance.database;
    final row = await db.query(
      DatabaseHelper.tableRecipes,
      where: 'id = ?',
      whereArgs: [inserted.id],
    );
    expect(
      row.first['image_path'] as String,
      equals(basename(inserted.imagePath!)),
    );

    // Cleanup
    dummyImageDir.deleteSync(recursive: true);
  });

  test('Recommendation algorithm works correctly', () async {
    // 1. Insert ingredients
    final tomato = await ingredientRepository.insertIngredient(
      Ingredient(name: 'Tomato'),
    );
    final onion = await ingredientRepository.insertIngredient(
      Ingredient(name: 'Onion'),
    );
    final garlic = await ingredientRepository.insertIngredient(
      Ingredient(name: 'Garlic'),
    );
    final chicken = await ingredientRepository.insertIngredient(
      Ingredient(name: 'Chicken'),
    );

    // 2. Insert recipes
    await recipeRepository.insertRecipe(
      Recipe(name: 'Tomato Soup', ingredients: [tomato, onion]),
    );

    await recipeRepository.insertRecipe(
      Recipe(name: 'Garlic Chicken', ingredients: [garlic, chicken]),
    );

    await recipeRepository.insertRecipe(
      Recipe(name: 'Complex Soup', ingredients: [tomato, onion, garlic]),
    );

    // 3. Test exact match
    var recommendations = await recipeRepository.getRecommendations([
      tomato.id!,
      onion.id!,
    ]);
    expect(recommendations.length, 1);
    expect(recommendations.first.name, 'Tomato Soup');

    // 4. Test extra ingredients (user has more than needed)
    recommendations = await recipeRepository.getRecommendations([
      tomato.id!,
      onion.id!,
      chicken.id!,
    ]);
    expect(recommendations.length, 1);
    expect(recommendations.first.name, 'Tomato Soup');

    // 5. Test multiple matches
    recommendations = await recipeRepository.getRecommendations([
      tomato.id!,
      onion.id!,
      garlic.id!,
      chicken.id!,
    ]);
    expect(recommendations.length, 3);

    // 6. Test partial match (should not return)
    recommendations = await recipeRepository.getRecommendations([tomato.id!]);
    expect(recommendations.isEmpty, isTrue);

    // 7. Test empty list
    recommendations = await recipeRepository.getRecommendations([]);
    expect(recommendations.isEmpty, isTrue);
  });
}
