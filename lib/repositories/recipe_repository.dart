import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';

class RecipeRepository {
  /// Retrieve all recipes with their ingredients
  Future<List<Recipe>> getAllRecipes() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRecipes,
    );

    Directory docsDir = await getApplicationDocumentsDirectory();
    List<Recipe> recipes = [];

    for (var map in maps) {
      var editableMap = Map<String, dynamic>.from(map);
      if (editableMap['image_path'] != null) {
        editableMap['image_path'] = join(
          docsDir.path,
          editableMap['image_path'],
        );
      }

      // Fetch associated ingredients
      int recipeId = editableMap['id'];
      List<Ingredient> ingredients = await _getIngredientsForRecipe(
        db,
        recipeId,
        docsDir.path,
      );

      recipes.add(
        Recipe(
          id: recipeId,
          name: editableMap['name'],
          imagePath: editableMap['image_path'],
          ingredients: ingredients,
        ),
      );
    }

    return recipes;
  }

  /// Retrieve a single recipe by id
  Future<Recipe?> getRecipeById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRecipes,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      var map = Map<String, dynamic>.from(maps.first);
      Directory docsDir = await getApplicationDocumentsDirectory();
      if (map['image_path'] != null) {
        map['image_path'] = join(docsDir.path, map['image_path']);
      }

      List<Ingredient> ingredients = await _getIngredientsForRecipe(
        db,
        id,
        docsDir.path,
      );

      return Recipe(
        id: map['id'],
        name: map['name'],
        imagePath: map['image_path'],
        ingredients: ingredients,
      );
    }
    return null;
  }

  Future<List<Ingredient>> _getIngredientsForRecipe(
    Database db,
    int recipeId,
    String docsDirPath,
  ) async {
    final List<Map<String, dynamic>> ingredientMaps = await db.rawQuery(
      '''
      SELECT i.* FROM ${DatabaseHelper.tableIngredients} i
      INNER JOIN ${DatabaseHelper.tableRecipeIngredients} ri ON i.id = ri.ingredient_id
      WHERE ri.recipe_id = ?
    ''',
      [recipeId],
    );

    return List.generate(ingredientMaps.length, (i) {
      var map = Map<String, dynamic>.from(ingredientMaps[i]);
      if (map['image_path'] != null) {
        map['image_path'] = join(docsDirPath, map['image_path']);
      }
      return Ingredient.fromMap(map);
    });
  }

  /// Add a new recipe and its ingredients in a transaction
  Future<Recipe> insertRecipe(Recipe recipe) async {
    final db = await DatabaseHelper.instance.database;

    String? localFilename;
    if (recipe.imagePath != null) {
      localFilename = await _saveImageLocally(recipe.imagePath!);
    }

    Map<String, dynamic> recipeMap = recipe.toMap();
    if (localFilename != null) {
      recipeMap['image_path'] = localFilename;
    }

    int recipeId = 0;

    await db.transaction((txn) async {
      // Insert base recipe
      recipeId = await txn.insert(DatabaseHelper.tableRecipes, recipeMap);

      // Insert ingredients into join table
      if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) {
        for (var ingredient in recipe.ingredients!) {
          if (ingredient.id != null) {
            await txn.insert(DatabaseHelper.tableRecipeIngredients, {
              'recipe_id': recipeId,
              'ingredient_id': ingredient.id,
            });
          }
        }
      }
    });

    // Return updated recipe with local filename resolved to full path
    String? fullPath;
    if (localFilename != null) {
      Directory docsDir = await getApplicationDocumentsDirectory();
      fullPath = join(docsDir.path, localFilename);
    }

    return Recipe(
      id: recipeId,
      name: recipe.name,
      imagePath: fullPath,
      ingredients: recipe.ingredients,
    );
  }

  /// Update an existing recipe
  Future<int> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) return 0;

    final db = await DatabaseHelper.instance.database;

    String? localFilename;
    if (recipe.imagePath != null) {
      localFilename = await _saveImageLocally(recipe.imagePath!);
    }

    Map<String, dynamic> recipeMap = recipe.toMap();
    if (localFilename != null) {
      recipeMap['image_path'] = localFilename;
    }

    int rowsAffected = 0;

    await db.transaction((txn) async {
      // Update base recipe
      rowsAffected = await txn.update(
        DatabaseHelper.tableRecipes,
        recipeMap,
        where: 'id = ?',
        whereArgs: [recipe.id],
      );

      // Update ingredients: a simple way is to delete existing relationships and re-insert
      if (recipe.ingredients != null) {
        await txn.delete(
          DatabaseHelper.tableRecipeIngredients,
          where: 'recipe_id = ?',
          whereArgs: [recipe.id],
        );

        for (var ingredient in recipe.ingredients!) {
          if (ingredient.id != null) {
            await txn.insert(DatabaseHelper.tableRecipeIngredients, {
              'recipe_id': recipe.id,
              'ingredient_id': ingredient.id,
            });
          }
        }
      }
    });

    return rowsAffected;
  }

  /// Delete a recipe
  Future<int> deleteRecipe(int id) async {
    final db = await DatabaseHelper.instance.database;

    // Delete the image file associated with the recipe to avoid orphans
    final recipe = await getRecipeById(id);
    if (recipe != null && recipe.imagePath != null) {
      File imageFile = File(recipe.imagePath!);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }

    // Because of ON DELETE CASCADE on the foreign key in recipe_ingredients,
    // deleting the recipe will automatically delete the related rows in recipe_ingredients.
    return await db.delete(
      DatabaseHelper.tableRecipes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Helper method to copy image to app docs dir and return unique filename
  Future<String> _saveImageLocally(String originalPath) async {
    File originalFile = File(originalPath);
    Directory docsDir = await getApplicationDocumentsDirectory();

    // If the image is already in the documents directory, just return the basename
    if (originalPath.startsWith(docsDir.path)) {
      return basename(originalPath);
    }

    if (!await originalFile.exists()) {
      return basename(originalPath);
    }

    String fileName = basename(originalPath);
    String uniqueFilename =
        '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    String newPath = join(docsDir.path, uniqueFilename);

    await originalFile.copy(newPath);
    return uniqueFilename;
  }

  /// Find recipes where all required ingredients are present in the provided list
  Future<List<Recipe>> getRecommendations(
    List<int> availableIngredientIds,
  ) async {
    if (availableIngredientIds.isEmpty) return [];

    final db = await DatabaseHelper.instance.database;
    final placeholders = List.filled(
      availableIngredientIds.length,
      '?',
    ).join(',');

    final String query =
        '''
      SELECT r.* 
      FROM ${DatabaseHelper.tableRecipes} r
      JOIN ${DatabaseHelper.tableRecipeIngredients} ri ON r.id = ri.recipe_id
      WHERE ri.ingredient_id IN ($placeholders)
      GROUP BY r.id
      HAVING COUNT(DISTINCT ri.ingredient_id) = (
        SELECT COUNT(*) 
        FROM ${DatabaseHelper.tableRecipeIngredients} ri2 
        WHERE ri2.recipe_id = r.id
      )
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      query,
      availableIngredientIds,
    );

    Directory docsDir = await getApplicationDocumentsDirectory();
    List<Recipe> recipes = [];

    for (var map in maps) {
      var editableMap = Map<String, dynamic>.from(map);
      if (editableMap['image_path'] != null) {
        editableMap['image_path'] = join(
          docsDir.path,
          editableMap['image_path'],
        );
      }

      // Fetch associated ingredients
      int recipeId = editableMap['id'];
      List<Ingredient> ingredients = await _getIngredientsForRecipe(
        db,
        recipeId,
        docsDir.path,
      );

      recipes.add(
        Recipe(
          id: recipeId,
          name: editableMap['name'],
          imagePath: editableMap['image_path'],
          ingredients: ingredients,
        ),
      );
    }

    return recipes;
  }
}
