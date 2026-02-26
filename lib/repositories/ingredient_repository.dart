import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import '../models/ingredient.dart';

class IngredientRepository {
  /// Retrieve all ingredients
  Future<List<Ingredient>> getAllIngredients() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableIngredients,
    );

    Directory docsDir = await getApplicationDocumentsDirectory();
    return List.generate(maps.length, (i) {
      var map = Map<String, dynamic>.from(maps[i]);
      if (map['image_path'] != null) {
        map['image_path'] = join(docsDir.path, map['image_path']);
      }
      return Ingredient.fromMap(map);
    });
  }

  /// Retrieve a single ingredient by id
  Future<Ingredient?> getIngredientById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableIngredients,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      var map = Map<String, dynamic>.from(maps.first);
      if (map['image_path'] != null) {
        Directory docsDir = await getApplicationDocumentsDirectory();
        map['image_path'] = join(docsDir.path, map['image_path']);
      }
      return Ingredient.fromMap(map);
    }
    return null;
  }

  /// Add a new ingredient
  Future<Ingredient> insertIngredient(Ingredient ingredient) async {
    final db = await DatabaseHelper.instance.database;

    String? localFilename;
    if (ingredient.imagePath != null) {
      localFilename = await _saveImageLocally(ingredient.imagePath!);
    }

    Map<String, dynamic> ingredientMap = ingredient.toMap();
    if (localFilename != null) {
      ingredientMap['image_path'] = localFilename;
    }

    int id = await db.insert(DatabaseHelper.tableIngredients, ingredientMap);

    // Return updated ingredient with local filename resolved to full path
    String? fullPath;
    if (localFilename != null) {
      Directory docsDir = await getApplicationDocumentsDirectory();
      fullPath = join(docsDir.path, localFilename);
    }

    return Ingredient(id: id, name: ingredient.name, imagePath: fullPath);
  }

  /// Update an existing ingredient
  Future<int> updateIngredient(Ingredient ingredient) async {
    if (ingredient.id == null) return 0;

    final db = await DatabaseHelper.instance.database;

    String? localFilename;
    if (ingredient.imagePath != null) {
      localFilename = await _saveImageLocally(ingredient.imagePath!);
    }

    Map<String, dynamic> ingredientMap = ingredient.toMap();
    if (localFilename != null) {
      ingredientMap['image_path'] = localFilename;
    }

    return await db.update(
      DatabaseHelper.tableIngredients,
      ingredientMap,
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  /// Delete an ingredient
  Future<int> deleteIngredient(int id) async {
    final db = await DatabaseHelper.instance.database;

    // Delete the image file associated with the ingredient to avoid orphans
    final ingredient = await getIngredientById(id);
    if (ingredient != null && ingredient.imagePath != null) {
      File imageFile = File(ingredient.imagePath!);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }

    return await db.delete(
      DatabaseHelper.tableIngredients,
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
}
