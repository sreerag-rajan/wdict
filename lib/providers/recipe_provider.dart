import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository;

  RecipeProvider(this._repository);

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecipes() async {
    _setLoading(true);
    try {
      _recipes = await _repository.getAllRecipes();
      _error = null;
    } catch (e) {
      _error = "Failed to load recipes: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    _setLoading(true);
    try {
      final newRecipe = await _repository.insertRecipe(recipe);
      _recipes.add(newRecipe);
      _error = null;
    } catch (e) {
      _error = "Failed to add recipe: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    _setLoading(true);
    try {
      final rowsUpdated = await _repository.updateRecipe(recipe);
      if (rowsUpdated > 0) {
        final index = _recipes.indexWhere((r) => r.id == recipe.id);
        if (index != -1) {
          _recipes[index] = recipe;
        }
      }
      _error = null;
    } catch (e) {
      _error = "Failed to update recipe: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteRecipe(int id) async {
    _setLoading(true);
    try {
      final rowsDeleted = await _repository.deleteRecipe(id);
      if (rowsDeleted > 0) {
        _recipes.removeWhere((r) => r.id == id);
      }
      _error = null;
    } catch (e) {
      _error = "Failed to delete recipe: $e";
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
