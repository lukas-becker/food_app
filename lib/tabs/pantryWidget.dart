import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

//First Tab - Pantry
class PantryWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    WidgetsFlutterBinding.ensureInitialized();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Pantry(),
    );
  }
}

class Pantry extends StatefulWidget{

  @override
  _PantryState createState() => _PantryState();
}

class _PantryState extends State<Pantry> {
  List<Ingredient> ingredients = new List();

  Future<Database> database = getDatabasesPath().then((String path) {
    return openDatabase(
      Path.join(path, 'food_app_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE ingredient(id INTEGER PRIMARY KEY, name TEXT, amount INTEGER); INSERT INTO ingredient VALUES(1,'Salt',5); INSERT INTO ingredient VALUES(2,'Pepper',5);",
        );
      },
      version: 3,
    );
  });

  //final Map<String, int> ingredients = {'Salt':1, 'Pepper':1,'Milk':5};
  final List<String> entries = <String>['Salt','Pepper','Olive oil','Vegetable oil','flour','Chicken stock','Chicken broth','Beef stock',
    'Beef broth','Tomato sauce','Tomato paste','Tuna','Pasta','Rice','Lentils','Onions','Garlic','Vinegar','Soy sauce','basil','Cayenne pepper',
    'Chili powder','Cumin','Cinnamon','Garlic powder','Oregano','Paprika','Eggs','Milk','Butter','margarine','Ketchup','Mayonnaise','cheese','corn',
    'spinach','peas','Chicken breast','Capers','horseradish','Almond','Cornstarch','sugar','Honey','mustard'];

  var tController = new TextEditingController();

  @override
  void initState() {
    getIngredients().then((value) => ingredientsFinished(value));
    super.initState();

  }

  List<Ingredient> ingredientsFinished(List<Ingredient> ingr){
    setState(() {
      ingredients = ingr;
    });
    return ingr;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Center(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: ingredients.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                tileColor: Colors.amber[100],
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: Icon(Icons.remove), onPressed: (){setState(() {ingredients[index].amount -= 1; updateIngredient(ingredients[index]); if(ingredients[index].amount == 0) ingredients.remove(ingredients[index]); });}),
                    Text(ingredients[index].name + " : " + ingredients[index].amount.toString()),
                    IconButton(icon: Icon(Icons.add), onPressed: (){/*setState(() {ingredients.update(keys[index], (value) => value += 1);});*/}),
                  ]
                  ),
                onLongPress: () => _askForDelete(index),
              );
            },
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addItem(),
          child: Icon(Icons.add),
          backgroundColor: Colors.lime,
        ),
    );
  }

  Future<List<Ingredient>> getIngredients() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('ingredient', where: 'amount > 0');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Ingredient(
        id: maps[i]['id'],
        name: maps[i]['name'],
        amount: maps[i]['amount'],
      );
    });
  }

  Future<void> insertIngredient(Ingredient ingredient) async {
    // Get a reference to the database.
    final Database db = await database;

    await db.insert(
      'ingredient',
      ingredient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
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

  void _addItem() {

  String newAmount;
  int amount;
  String dropdownValue = entries[0];

  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("New List Item"),
          content: Row(
            children: [
              Expanded(child: 
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      DropdownButton(
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          items: entries.map<DropdownMenuItem<String>>((String value) {return DropdownMenuItem<String>(value: value,child: Text(value),);}).toList(),
                          onChanged: (String newValue) {setState(() {dropdownValue = newValue;});},
                      ),
                      TextField(
                      controller: tController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amount',
                      ),
                    ),]
                  )
                )
              ),
              ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close")
            ),
            FlatButton(
            child: Text("Save"),
            onPressed: (){
              amount = null;
              newAmount = tController.text;
              amount = int.tryParse(newAmount);
              Navigator.of(context).pop();
            },
            ),

          ],
        );
      }
  ).then((value)  => insertFromDropdown(ingredients.length + 1, dropdownValue, amount));
  }
  
  Future<void> insertFromDropdown(int id, String name, int amount) async{
    if(amount != Null) {
      final ing = Ingredient(id: id, name: name, amount: amount);
      insertIngredient(ing).whenComplete(() => initState());
    }
  }

  void _askForDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete?"),
          content: Text("Do you want to delete \"${entries[index]}?\""),
            actions: <Widget>[
              TextButton(
                onPressed:() => {
                  _deleteItem(index),
                  Navigator.pop(context)
                  },
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () => {
                  Navigator.pop(context)
                },
                child: Text("Cancel"),
                )
            ], 
          
        );
      }
      );
  }

  void _deleteItem(int index){
    setState(() {
      entries.removeAt(index);
    });
  }
}

class Ingredient {
  final int id;
  final String name;
  int amount;

  Ingredient({this.id, this.name, this.amount});

  void updateAmount(int newAmount){
    amount = newAmount;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
    };
  }
}


//End of Pantry