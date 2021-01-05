//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Ingredient.dart';

//First Tab - Pantry
class PantryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

class Pantry extends StatefulWidget {
  @override
  _PantryState createState() => _PantryState();
}

class _PantryState extends State<Pantry> {
  bool refreshDB = true;
  List<Ingredient> ingredients = new List();

  final List<String> entries = <String>['Salt','Pepper','Olive oil','Vegetable oil','Flour','Chicken stock','Chicken broth','Beef stock',
    'Beef broth','Tomato sauce','Tomato paste','Tuna','Pasta','Rice','Lentils','Onions','Garlic','Vinegar','Soy sauce','Basil','Cayenne pepper',
    'Chili powder','Cumin','Cinnamon','Garlic powder','Oregano','Paprika','Eggs','Milk','Butter','Margarine','Ketchup','Mayonnaise','Cheese','Corn',
    'Spinach','Peas','Chicken breast','Capers','Horseradish','Almond','Cornstarch','Sugar','Honey','Mustard'];

  var tController = new TextEditingController();

  @override
  void initState() {
    if (refreshDB) {
      DatabaseUtil.getDatabase();
      DatabaseUtil.getIngredients().then((value) => ingredientsFinished(value));
      refreshDB = false;
    }
    super.initState();
  }

  void ingredientsFinished(List<Ingredient> ingr) {
    setState(() {
      ingredients = ingr;
    });
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
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        refreshDB = true;
                        ingredients[index].amount -= 1;
                        DatabaseUtil.updateIngredient(ingredients[index]);
                        if (ingredients[index].amount == 0)
                          DatabaseUtil.deleteIngredient(ingredients[index].id)
                              .whenComplete(() => initState());
                      });
                    },
                  ),
                  Text(ingredients[index].name +
                      " : " +
                      ingredients[index].amount.toString()),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        refreshDB = true;
                        ingredients[index].amount += 1;
                        DatabaseUtil.updateIngredient(ingredients[index]);
                      });
                    },
                  ),
                ],
              ),
              onLongPress: () => _askForDelete(index),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(),
        child: Icon(Icons.add),
        backgroundColor: Colors.lime,
      ),
    );
  }

  String dropdownValue;
  bool savePopUp = false;

  void _addItem() {
    String newAmount;
    int amount;

    dropdownValue == null ? dropdownValue = entries[0] : dropdownValue = dropdownValue;

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
                            onChanged: (value) => {setState(() {dropdownValue = value; Navigator.of(context).pop(); _addItem();})}, //Close the Dropdown and reopen it immediately to reflect value change
                        ),
                        TextField(
                        controller: tController,
                        keyboardType: TextInputType.number,
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
                savePopUp = true;
              },
              ),

            ],
          );
        }
    ).then((value)  => getIdThenInsertFromDropdown(dropdownValue, amount));
    }

    Future<void> getIdThenInsertFromDropdown(String name, int amount) async{
      refreshDB = true;

      DatabaseUtil.getNextIngredientID().then((value) => insertFromDropdown(value, name, amount));
    }

    Future<void> insertFromDropdown(int id, String name, int amount) async{
      refreshDB = true;
      DatabaseUtil.getNextIngredientID().then((value) => id = value);

      if(savePopUp && amount != null) {
        savePopUp = false;
        final ing = Ingredient(id: id, name: name, amount: amount);
        DatabaseUtil.checkDBForIngredient(name).then((value) => {value ? DatabaseUtil.updateAmount(name, amount).whenComplete(() => initState()) : DatabaseUtil.insertIngredient(ing).whenComplete(() => initState())});

      }
  }

  // Not working --> Discuss if we want to fix it
  void _askForDelete(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete?"),
            content: Text("Do you want to delete \"${entries[index]}?\""),
            actions: <Widget>[
              TextButton(
                onPressed: () => {_deleteItem(index), Navigator.pop(context)},
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () => {Navigator.pop(context)},
                child: Text("Cancel"),
              )
            ],
          );
        });
  }

  void _deleteItem(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }
}

//End of Pantry
