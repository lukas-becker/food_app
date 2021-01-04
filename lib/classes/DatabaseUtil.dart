import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

import 'Ingredient.dart';

class DatabaseUtil {
  static Future<Database> database;

  static Future<Database> getDatabase() {
    if (database == null) {
      database = getDatabasesPath().then(
        (String path) {
          return openDatabase(
            Path.join(path, 'food_app_database.db'),
            onCreate: (db, version) {
              return db.execute(
                "CREATE TABLE ingredient(id INTEGER PRIMARY KEY, name TEXT, amount INTEGER);",
              );
            },
            version: 3,
          );
        },
      );

      return database;
    } else {
      return database;
    }
  }

  static Future<List<Ingredient>> getIngredients() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await db.query('ingredient', where: 'amount > 0');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Ingredient(
        id: maps[i]['id'],
        name: maps[i]['name'],
        amount: maps[i]['amount'],
      );
    });
  }

  static Future<bool> checkDBForIngredient(String key) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('ingredient', where: 'name = ?', whereArgs: [key]);
    print(maps);
    return maps.length > 0;
  }

  static Future<void> insertIngredient(Ingredient ingredient) async {
    // Get a reference to the database.
    final Database db = await database;

    await db.insert(
      'ingredient',
      ingredient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateIngredient(Ingredient ingredient) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'ingredient',
      ingredient.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [ingredient.id],
    );
  }

  static Future<void> updateAmount(String name, int amount) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Ingredient.
    await db.execute("UPDATE ingredient SET amount = " + amount.toString() + " WHERE name = '" + name + "';");
  }

  static Future<void> deleteIngredient(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the Database.
    await db.delete(
      'ingredient',
      // Use a `where` clause to delete a specific dog.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}

  static Future<int> getNextIngredientID() async {
    final db = await database;
    List<String> queryList = new List(1);
    queryList[0] = "MAX(id)";
    final List<Map<String, dynamic>> maps = await db.query("ingredient", columns: queryList);
    return maps.first["MAX(id)"] + 1;

  }

}