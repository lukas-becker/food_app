import 'package:food_app/classes/Favorite.dart';
import 'package:food_app/classes/GroceryItem.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Ingredient.dart';
import 'Recipe.dart';

class DatabaseUtil {
  static Future<Database> database;
  static final DatabaseReference firebaseReference = FirebaseDatabase.instance.reference();

  static Future<Database> getDatabase() {
    if (database == null) {
      database = getDatabasesPath().then(
            (String path) {
          return openDatabase(
            Path.join(path, 'food_app_database.db'),
            onCreate: (db, version) {
              db.execute(
                "CREATE TABLE favorite(id INTEGER PRIMARY KEY, title TEXT, href TEXT, ingredients TEXT, thumbnail TEXT);",
              );
              db.execute(
                "CREATE TABLE groceries(id INTEGER PRIMARY KEY, name TEXT, quantity DOUBLE, unit TEXT);",
              );
              return db.execute(
                "CREATE TABLE ingredient(id INTEGER PRIMARY KEY, name TEXT, amount INTEGER);",
              );
            },
            version: 1,
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
    return maps == null || maps.length > 0 ;
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
    await db.execute("UPDATE ingredient SET amount = " + amount.toString() +
        " WHERE name = '" + name + "';");
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


  static Future<int> getNextIngredientID() async {
    final db = await database;
    List<String> queryList = new List(1);
    queryList[0] = "MAX(id)";
    final List<Map<String, dynamic>> maps = await db.query(
        "ingredient", columns: queryList);
    return maps.first["MAX(id)"] != null ? maps.first["MAX(id)"] + 1 : 1;
  }

  static Future<List<Favorite>> getFavorites() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
    await db.query('favorite');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Favorite(
        id: maps[i]['id'],
        recipe : Recipe(
        title: maps[i]['title'],
        href: maps[i]['href'],
        ingredients: maps[i]['ingredients'],
        thumbnail: maps[i]['thumbnail'],)
      );
    });
  }

  static Future<void> insertFavorite(Favorite fav) async {
    // Get a reference to the database.
    final Database db = await database;

    await db.insert(
      'favorite',
      fav.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );


    if(!(await checkFirebaseForFavorite(fav))){
      insertIntoFirebase(fav);
    } else {
      countUpInFirebase(fav);
    }

  }

  static Future<void> deleteFavorite(Favorite fav) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Favorite from the Database.
    await db.delete(
      'favorite',
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [fav.id],
    );

    if(await checkFirebaseForFavorite(fav)){
      if(await getCountInFirebase(fav) == 1) {
        deleteFromFirebase(fav);
      } else {
        countDownInFirebase(fav);
      }


    }
  }


  static Future<int> getNextFavoriteID() async {
    final db = await database;
    List<String> queryList = new List(1);
    queryList[0] = "MAX(id)";
    final List<Map<String, dynamic>> maps = await db.query(
        "favorite", columns: queryList);
    return maps.first["MAX(id)"] != null ? maps.first["MAX(id)"] + 1 : 1;
  }

  static Future<List<Favorite>> getFavoritesFromFirebase() async {
    List<Favorite> res = List();
    DatabaseReference id = firebaseReference.child("favorites/");
    var dbEntry = await id.once();
    Map<dynamic,dynamic> map = dbEntry.value;
    if(map == null)
      return List();
    for(dynamic element in map.values){
      res.add(Favorite.fromJson(element));
    }
    return res;
  }

  static Future<Favorite> getTopFavoriteFromFirebase() async {
    List<Favorite> all = await getFavoritesFromFirebase();

    if (all.length == 0)
      return null;

    all.sort((a,b) => (b.count).compareTo((a.count)));
    return all.first;
  }

  static Future<bool> checkFirebaseForFavorite(Favorite fav) async {
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    var dbEntry = await id.once();
    return dbEntry.value != null;
  }

  static Future<int> getCountInFirebase(Favorite fav) async {
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    var dbEntry = await id.once();
    Map<dynamic, dynamic> map = dbEntry.value;
    Favorite dbFav = Favorite.fromJson(map);
    return dbFav.count;
  }

  static void insertIntoFirebase(Favorite fav){
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    id.set(fav.toJson()).whenComplete(() => print("inserted new value into firebase"));
  }

  static void deleteFromFirebase(Favorite fav){
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    id.remove();
  }

  static void countUpInFirebase(Favorite fav) async {
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    DataSnapshot dbEntry = await id.once();
    Map<dynamic, dynamic> map = dbEntry.value;
    Favorite dbFav = Favorite.fromJson(map);
    dbFav.count += 1;
    print(dbFav);
    id.set(dbFav.toJson());
  }

  static void countDownInFirebase(Favorite fav) async {
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    DataSnapshot dbEntry = await id.once();
    Map<dynamic, dynamic> map = dbEntry.value;
    Favorite dbFav = Favorite.fromJson(map);
    dbFav.count -= 1;
    print(dbFav);
    id.set(dbFav.toJson());
  }


  static Future<List<GroceryItem>> getGroceries() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('groceries');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return GroceryItem.fromJson(maps[i]);
    });
  }

  static Future<void> insertGrocery(GroceryItem item) async {
    // Get a reference to the database.
    final Database db = await database;

    await db.insert(
      'groceries',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteGrocery(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Favorite from the Database.
    await db.delete(
      'groceries',
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

}

