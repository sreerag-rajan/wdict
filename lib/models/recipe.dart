import 'ingredient.dart';

class Recipe {
  final int? id;
  final String name;
  final String? imagePath;
  final List<Ingredient>? ingredients;

  Recipe({this.id, required this.name, this.imagePath, this.ingredients});

  // Convert a Map into a Recipe. The keys must correspond to the names of the
  // columns in the database.
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      name: map['name'] as String,
      imagePath: map['image_path'] as String?,
      // Note: Ingredients are not directly stored in the Recipe table,
      // they are retrieved separately via the recipe_ingredients join table.
      // So this fromMap does not handle mapping 'ingredients' from the database map.
    );
  }

  // Convert a Recipe into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (imagePath != null) 'image_path': imagePath,
    };
  }

  @override
  String toString() {
    return 'Recipe{id: $id, name: $name, imagePath: $imagePath, ingredients: $ingredients}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imagePath == other.imagePath;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ imagePath.hashCode;
}
