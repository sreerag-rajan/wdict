import 'package:flutter/foundation.dart';
import '../models/ingredient.dart';
import '../repositories/ingredient_repository.dart';

class IngredientProvider extends ChangeNotifier {
  final IngredientRepository _repository;

  IngredientProvider(this._repository);

  List<Ingredient> _ingredients = [];
  bool _isLoading = false;
  String? _error;

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIngredients() async {
    _setLoading(true);
    try {
      _ingredients = await _repository.getAllIngredients();
      _error = null;
    } catch (e) {
      _error = "Failed to load ingredients: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    _setLoading(true);
    try {
      final newIngredient = await _repository.insertIngredient(ingredient);
      _ingredients.add(newIngredient);
      _error = null;
    } catch (e) {
      _error = "Failed to add ingredient: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    _setLoading(true);
    try {
      final rowsUpdated = await _repository.updateIngredient(ingredient);
      if (rowsUpdated > 0) {
        final index = _ingredients.indexWhere((i) => i.id == ingredient.id);
        if (index != -1) {
          _ingredients[index] = ingredient;
        }
      }
      _error = null;
    } catch (e) {
      _error = "Failed to update ingredient: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteIngredient(int id) async {
    _setLoading(true);
    try {
      final rowsDeleted = await _repository.deleteIngredient(id);
      if (rowsDeleted > 0) {
        _ingredients.removeWhere((i) => i.id == id);
      }
      _error = null;
    } catch (e) {
      _error = "Failed to delete ingredient: $e";
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
