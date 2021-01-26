import 'package:food_app/classes/Favorite.dart';
import 'package:food_app/classes/GroceryItem.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Item.dart';
import 'Recipe.dart';

/**
 * This Class handles all interactions with the local database and firebase
 * It handles set-up, writes and saves
 */
class DatabaseUtil {
  //Variables to store Databse references
  static Future<Database> database;
  static final DatabaseReference firebaseReference = FirebaseDatabase.instance.reference();

  /// Creates and returns reference to the local database
  static Future<Database> getDatabase() {
    //If Database reference is not yet set
    if (database == null) {
      //get (and create if neccesary) Database
      database = getDatabasesPath().then(
            (String path) {
          return openDatabase(
            Path.join(path, 'food_app_database.db'),
            onCreate: (db, version) {
              //SQL Creation
              db.execute(
                "CREATE TABLE favorite(id INTEGER PRIMARY KEY, title TEXT, href TEXT, ingredients TEXT, thumbnail TEXT);",
              );
              db.execute(
                "CREATE TABLE groceries(id INTEGER PRIMARY KEY, name TEXT, amount DOUBLE, unit TEXT);",
              );
              return db.execute(
                "CREATE TABLE ingredient(id INTEGER PRIMARY KEY, name TEXT, amount DOUBLE, unit TEXT);",
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

  ///Returns all ingredients from the database
  static Future<List<Item>> getIngredients() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all the Ingredients.
    final List<Map<String, dynamic>> maps =
    await db.query('ingredient', where: 'amount > 0');

    // Convert the List<Map<String, dynamic> into a List<Ingredient>.
    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'],
        name: maps[i]['name'],
        amount: maps[i]['amount'],
      );
    });
  }

  ///Check wether Ingredient already exists in DB
  static Future<bool> checkDBForIngredient(String key) async {
    final Database db = await database;
    //Query db and store results in list
    final List<Map<String, dynamic>> maps =
    await db.query('ingredient', where: 'name = ?', whereArgs: [key]);

    //false if entries in list
    return maps == null || maps.length > 0 ;
  }

  ///Insert new Ingredient into DB
  static Future<void> insertIngredient(Item ingredient) async {
    // Get a reference to the database.
    final Database db = await database;

    //Insert into ingredient
    await db.insert(
      'ingredient',
      ingredient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///Update already stored ingredient
  static Future<void> updateIngredient(Item ingredient) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Ingredient.
    await db.update(
      'ingredient',
      ingredient.toMap(),
      // Ensure that the Ingredient has a matching id.
      where: "id = ?",
      // Pass the Ingredient's id
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

    // Remove the Ingredient from the Database.
    await db.delete(
      'ingredient',
      // Use a `where` clause to delete a specific Ingredient.
      where: "id = ?",
      // Pass the Ingredient's id as a whereArg
      whereArgs: [id],
    );
  }

  ///Get next unused ID
  static Future<int> getNextIngredientID() async {
    // Get a reference to the database.
    final db = await database;

    //Variable to store Query
    List<String> queryList = new List(1);
    queryList[0] = "MAX(id)";

    //Run query
    final List<Map<String, dynamic>> maps = await db.query(
        "ingredient", columns: queryList);

    //Return result
    return maps.first["MAX(id)"] != null ? maps.first["MAX(id)"] + 1 : 1;
  }

  ///Get all Favorites from local DB
  static Future<List<Favorite>> getFavorites() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all the Recipes.
    final List<Map<String, dynamic>> maps =
    await db.query('favorite');

    // Convert the List<Map<String, dynamic> into a List<Favorite>.
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

  ///Insert new Favorite into the DB
  static Future<void> insertFavorite(Favorite fav) async {
    // Get a reference to the database.
    final Database db = await database;


    //Insert into favorite
    await db.insert(
      'favorite',
      fav.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );



    ///Insert or Update Firebase afterwards
    if(!(await checkFirebaseForFavorite(fav))){
      insertIntoFirebase(fav);
    } else {
      countUpInFirebase(fav);
    }

  }

  ///Delete existing Favorite
  static Future<void> deleteFavorite(Favorite fav) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Favorite from the Database.
    await db.delete(
      'favorite',
      where: "id = ?",
      // Pass the Favorites's id as a whereArg
      whereArgs: [fav.id],
    );


    //Delete or update Firebase afterwards
    if(await checkFirebaseForFavorite(fav)){
      if(await getCountInFirebase(fav) == 1) {
        deleteFromFirebase(fav);
      } else {
        countDownInFirebase(fav);
      }


    }
  }

  ///Get next unused ID
  static Future<int> getNextFavoriteID() async {
    final db = await database;

    //Variable for query
    List<String> queryList = new List(1);
    queryList[0] = "MAX(id)";

    //Check DB
    final List<Map<String, dynamic>> maps = await db.query(
        "favorite", columns: queryList);

    //Return Result
    return maps.first["MAX(id)"] != null ? maps.first["MAX(id)"] + 1 : 1;
  }


  ///Returns all Favorites stored in Firebase
  static Future<List<Favorite>> getFavoritesFromFirebase() async {
    List<Favorite> res = List();

    //Reference to everything stored under favorites
    DatabaseReference id = firebaseReference.child("favorites/");

    //Get result and return
    var dbEntry = await id.once();
    Map<dynamic,dynamic> map = dbEntry.value;
    if(map == null)
      return List();
    for(dynamic element in map.values){
      res.add(Favorite.fromJson(element));
    }
    return res;
  }

  ///Returns the top result from Firebase
  static Future<Favorite> getTopFavoriteFromFirebase() async {
    //Get all Favorites from Firebase
    List<Favorite> all = await getFavoritesFromFirebase();

    if (all.length == 0)
      return null;

    //Sort by times favorited
    all.sort((a,b) => (b.count).compareTo((a.count)));
    return all.first;
  }

  ///Check wether Favorite is already in Firebase
  static Future<bool> checkFirebaseForFavorite(Favorite fav) async {
    //Check for fav
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());

    //Get result
    var dbEntry = await id.once();

    return dbEntry.value != null;
  }

  ///Check times favorited for Favorite in Firebase
  static Future<int> getCountInFirebase(Favorite fav) async {
    //Get fav
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    var dbEntry = await id.once();

    //Parse to object
    Map<dynamic, dynamic> map = dbEntry.value;
    Favorite dbFav = Favorite.fromJson(map);

    //Return count
    return dbFav.count;
  }

  ///Insert Favorite into Firebase
  static void insertIntoFirebase(Favorite fav){
    //Get location
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    //Write to location
    id.set(fav.toJson()).whenComplete(() => print("inserted new value into firebase"));
  }

  ///Delete favorite from Firebase
  static void deleteFromFirebase(Favorite fav){
    //Get location
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    //Remove
    id.remove();
  }

  ///Increment times favorited in Firebase
  static void countUpInFirebase(Favorite fav) async {
    //Get location
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    //Get Value
    DataSnapshot dbEntry = await id.once();
    //Parse to object
    Map<dynamic, dynamic> map = dbEntry.value;
    Favorite dbFav = Favorite.fromJson(map);
    //Adjust count
    dbFav.count += 1;
    //Store adjusted Favorite
    id.set(dbFav.toJson());
  }

  ///Decrement times favorited in Firebase
  static void countDownInFirebase(Favorite fav) async {
    //Get location
    DatabaseReference id = firebaseReference.child("favorites/").child(fav.recipe.hashCode.toString());
    //Get Value
    DataSnapshot dbEntry = await id.once();
    Map<dynamic, dynamic> map = dbEntry.value;
    //Parse to object
    Favorite dbFav = Favorite.fromJson(map);
    //Adjust count
    dbFav.count -= 1;
    //Save
    id.set(dbFav.toJson());
  }

  ///Get groceries from local DB
  static Future<List<Item>> getGroceries() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Groceries.
    final List<Map<String, dynamic>> maps = await db.query('groceries');

    // Convert the List<Map<String, dynamic> into a List<Item>.
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  ///Insert Groceries into localDB
  static Future<void> insertGrocery(Item item) async {
    // Get a reference to the database.
    final Database db = await database;

    //Insert into groceries
    await db.insert(
      'groceries',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///Delete Groceries from local DB
  static Future<void> deleteGrocery(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Item from the Database.
    await db.delete(
      'groceries',
      where: "id = ?",
      // Pass the Dog's id as a whereArg
      whereArgs: [id],
    );
  }

}

