import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wdict/database/database_helper.dart';
import 'package:wdict/models/ingredient.dart';
import 'package:wdict/repositories/ingredient_repository.dart';

void main() {
  late Directory tempDir;
  late IngredientRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    tempDir = await Directory.systemTemp.createTemp('wdict_test_repo');

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

    repository = IngredientRepository();
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

  test('CRUD operations work correctly without images', () async {
    // 1. Insert
    final newIngredient = Ingredient(name: 'Tomato');
    final inserted = await repository.insertIngredient(newIngredient);

    expect(inserted.id, isNotNull);
    expect(inserted.name, 'Tomato');
    expect(inserted.imagePath, isNull);

    // 2. Retrieve All
    var all = await repository.getAllIngredients();
    expect(all.length, 1);
    expect(all.first.name, 'Tomato');

    // 3. Retrieve By Id
    var fetched = await repository.getIngredientById(inserted.id!);
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Tomato');

    // 4. Update
    final updatedIngredient = Ingredient(
      id: inserted.id,
      name: 'Cherry Tomato',
    );
    await repository.updateIngredient(updatedIngredient);

    var afterUpdate = await repository.getIngredientById(inserted.id!);
    expect(afterUpdate!.name, 'Cherry Tomato');

    // 5. Delete
    await repository.deleteIngredient(inserted.id!);
    all = await repository.getAllIngredients();
    expect(all.isEmpty, isTrue);
  });

  test(
    'Inserting ingredient with image copies file and saves logic correctly',
    () async {
      // Create a dummy image file outside documents directory
      final dummyImageDir = await Directory.systemTemp.createTemp(
        'dummy_images',
      );
      final originalFile = File(join(dummyImageDir.path, 'source_image.jpg'));
      await originalFile.writeAsString('fake image data');

      final ingredientWithImage = Ingredient(
        name: 'Onion',
        imagePath: originalFile.path,
      );

      // Insert
      final inserted = await repository.insertIngredient(ingredientWithImage);

      // The returned ingredient should have its imagePath updated to the copied path in docs dir
      expect(inserted.imagePath, isNotNull);
      expect(inserted.imagePath!.startsWith(tempDir.path), isTrue);
      expect(basename(inserted.imagePath!), contains('source_image.jpg'));

      // The DB should only hold the filename
      final db = await DatabaseHelper.instance.database;
      final row = await db.query(
        DatabaseHelper.tableIngredients,
        where: 'id = ?',
        whereArgs: [inserted.id],
      );
      expect(
        row.first['image_path'] as String,
        equals(basename(inserted.imagePath!)),
      );

      // Retrieve updates path to absolute
      final fetched = await repository.getIngredientById(inserted.id!);
      expect(fetched!.imagePath, equals(inserted.imagePath));

      // Cleanup
      dummyImageDir.deleteSync(recursive: true);
    },
  );

  test(
    'Updating ingredient updates image correctly without duplicating if same dir',
    () async {
      final inserted = await repository.insertIngredient(
        Ingredient(name: 'Garlic'),
      );

      final dummyImageDir = await Directory.systemTemp.createTemp(
        'dummy_images_update',
      );
      final freshImage = File(join(dummyImageDir.path, 'new_image.png'));
      await freshImage.writeAsString('fake data 2');

      final update1 = Ingredient(
        id: inserted.id,
        name: 'Garlic',
        imagePath: freshImage.path,
      );

      await repository.updateIngredient(update1);
      final fetched1 = await repository.getIngredientById(inserted.id!);

      expect(fetched1!.imagePath, contains('new_image.png'));
      expect(fetched1.imagePath!.startsWith(tempDir.path), isTrue);

      // Update again with the *same* absolute path (already in docs dir)
      await repository.updateIngredient(fetched1);

      final fetched2 = await repository.getIngredientById(inserted.id!);
      expect(fetched2!.imagePath, equals(fetched1.imagePath));

      // Ensure only one image file exists in the temp docs dir for this ingredient (no duplicate copies)
      int pngCount = tempDir
          .listSync()
          .where((e) => e.path.endsWith('new_image.png'))
          .length;
      expect(pngCount, 1);

      dummyImageDir.deleteSync(recursive: true);
    },
  );
}
