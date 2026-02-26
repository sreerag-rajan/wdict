import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "WdictDatabase.db";
  static const _databaseVersion = 1;

  static const tableIngredients = 'ingredients';
  static const tableRecipes = 'recipes';
  static const tableRecipeIngredients = 'recipe_ingredients';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  // Helper to enable foreign keys
  Future _onConfigure(Database db) async {
    // Add support for cascading deletes
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableIngredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            image_path TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableRecipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            image_path TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableRecipeIngredients (
            recipe_id INTEGER,
            ingredient_id INTEGER,
            PRIMARY KEY (recipe_id, ingredient_id),
            FOREIGN KEY (recipe_id) REFERENCES $tableRecipes (id) ON DELETE CASCADE,
            FOREIGN KEY (ingredient_id) REFERENCES $tableIngredients (id) ON DELETE CASCADE
          )
          ''');
  }
}
