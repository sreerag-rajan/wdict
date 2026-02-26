class Ingredient {
  final int? id;
  final String name;
  final String? imagePath;

  Ingredient({this.id, required this.name, this.imagePath});

  // Convert a Map into an Ingredient. The keys must correspond to the names of the
  // columns in the database.
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as int?,
      name: map['name'] as String,
      imagePath: map['image_path'] as String?,
    );
  }

  // Convert an Ingredient into a Map. The keys must correspond to the names of the
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
    return 'Ingredient{id: $id, name: $name, imagePath: $imagePath}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imagePath == other.imagePath;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ imagePath.hashCode;
}
