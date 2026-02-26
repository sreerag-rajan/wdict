import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wdict/database/database_helper.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Initialize FFI and test bindings
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    // Change the default factory for sqflite to use FFI
    databaseFactory = databaseFactoryFfi;

    // Create a temporary directory for the mock documents directory
    tempDir = await Directory.systemTemp.createTemp('wdict_test');

    // Mock path_provider method channel
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
  });

  tearDownAll(() async {
    // Clean up
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Database is initialized completely with correct schema', () async {
    // 1. Get database instance
    Database db = await DatabaseHelper.instance.database;

    // 2. Verify database is open
    expect(db.isOpen, isTrue);

    // 3. Check created tables
    var tables = await db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );

    List<String> tableNames = tables.map((e) => e['name'] as String).toList();

    expect(tableNames.contains('ingredients'), isTrue);
    expect(tableNames.contains('recipes'), isTrue);
    expect(tableNames.contains('recipe_ingredients'), isTrue);

    // 4. Test foreign keys are turned ON
    var pragmaInfo = await db.rawQuery('PRAGMA foreign_keys');
    expect(pragmaInfo.first['foreign_keys'], 1);

    // 5. Briefly insert and delete to ensure constraints work
    await db.insert('recipes', {'name': 'Test Recipe'});
    await db.insert('ingredients', {'name': 'Test Gen'});
    // Since id is AUTOINCREMENT, it will be 1 for both if empty

    await db.insert('recipe_ingredients', {'recipe_id': 1, 'ingredient_id': 1});

    var joinCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM recipe_ingredients'),
    );
    expect(joinCount, 1);

    // Act: delete the recipe
    await db.delete('recipes', where: 'id = ?', whereArgs: [1]);

    // Assert: cascading delete should have removed the join record
    var afterDeleteJoinCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM recipe_ingredients'),
    );
    expect(afterDeleteJoinCount, 0);

    // Cleanup
    await db.close();
  });
}
