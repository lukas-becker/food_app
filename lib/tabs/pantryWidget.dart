//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Item.dart';
import 'package:food_app/globalVariables.dart' as globals;

import 'EditItem.dart';

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
  List<Item> ingredients = new List();
  final double fontSize = 16;

  @override
  void initState() {
    super.initState();
    DatabaseUtil.getDatabase();
    DatabaseUtil.getIngredients().then((value) => {
          setState(() {
            ingredients = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _awaitResultFromEditScreen(context, ingredients.length),
        child: Icon(Icons.add),
        backgroundColor: Colors.lime,
      ),
    );
  }
  /// determine if the ingredients list is empty
  ///   yes - return widget with hint for user on how to add new ingredients
  ///   no - return the ListView of ingredients
  Widget _buildWidget(){
    if (ingredients.isEmpty){
      return Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("You have no ingredients in your pantry!",
                  style: TextStyle(fontSize: fontSize)
              ),
              Text("Add new ingredients by pressing the button",
                  style: TextStyle(fontSize: fontSize)
              ),
              Text("in the bottom right corner!",
                  style: TextStyle(fontSize: fontSize)
              ),
            ]
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: ingredients.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => _decreaseAmount(index),
                ),
                Text(
                  "${ingredients[index].name} : ${globals.prettyFormatDouble(ingredients[index].amount)} ${ingredients[index].unit}",
                  style: TextStyle(fontSize: fontSize),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                  ),
                  onPressed: () => _increaseAmount(index),
                ),
              ],
            ),
            actions: <Widget>[
              IconSlideAction(
                caption: "Edit",
                color: Colors.blue,
                icon: Icons.edit,
                onTap: () => _awaitResultFromEditScreen(context, index),
              ),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: "Delete",
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _removeIngredient(index),
              ),
            ],
          );
        },
      );
    }
  }


  /// increase the items amount and save it
  void _increaseAmount(int index) {
    Item oldItem = ingredients[index];
    Item newItem = Item(id: oldItem.id, name: oldItem.name, amount: oldItem.amount + 1, unit: oldItem.unit);
    _addOrUpdateIngredient(newItem, index);
    DatabaseUtil.insertIngredient(newItem);
  }

  /// decrease the items amount and save it
  /// when the decreased amount is less or equal to 0 the item gets removed
  void _decreaseAmount(int index) {
    Item oldItem = ingredients[index];
    if (oldItem.amount - 1 <= 0) {
      _removeIngredient(index);
    } else {
      Item newItem = Item(id: oldItem.id, name: oldItem.name, amount: oldItem.amount - 1, unit: oldItem.unit);
      _addOrUpdateIngredient(newItem, index);
      DatabaseUtil.insertIngredient(newItem);
    }
  }

  /// check if there is an item with the same name in the list items
  /// if so overwrite the item
  /// else insert new Item to the list items
  void _addOrUpdateIngredient(Item newItem, int index) {
    int indexWithSameName;
    for (int i = 0; i < ingredients.length; i++) {
      if (newItem.name == ingredients[i].name) {
        indexWithSameName = i;
      }
    }
    if (indexWithSameName != null) {
      //there already is an ingredient with the same name
      setState(() {
        ingredients[indexWithSameName] = Item(id: ingredients[indexWithSameName].id, name: newItem.name, amount: newItem.amount, unit: newItem.unit);
      });
      print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Overwrite ingredient at position $indexWithSameName in the list with: ${newItem.toMap().toString()}."); //LOGGING
    } else {
      setState(() {
        ingredients.insert(index, newItem);
      });
      print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Added new ingredient: ${newItem.toMap().toString()} to the list."); //LOGGING
    }
  }

  /// remove the Item at index from database and the list items
  void _removeIngredient(int index) {
    DatabaseUtil.deleteIngredient(ingredients[index].id);
    setState(() {
      ingredients.removeAt(index);
    });
  }

  /// insert all items in the database. insert function can overwrite elements in the db
  void _saveIngredients() {
    print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Start saving ingredients..."); //LOGGING
    for (int i = 0; i < ingredients.length; i++) {
      var ingredient = ingredients[i];
      DatabaseUtil.insertIngredient(ingredient);
    }
    print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Ingredients saved."); //LOGGING
  }

  /// this function can be called from two positions:
  ///   1. FloatingActionButton
  ///   2. Edit Button from the ListTile
  ///
  /// if called from:
  ///   1 - index is equal to ingredients.length, no item has to be sent to the EditItem widget
  ///   2 - index is equivalent to the items index at the list, this item will be sent to the EditItem widget
  ///
  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    Item result;
    if (index > ingredients.length - 1) {
      print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Open EditItem Widget with no item."); //LOGGING
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(null, false))); // open EditWidget and wait until it's closed
      if (result != null) {
        print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Received item ${result.toMap().toString()}."); //LOGGING
        _addOrUpdateIngredient(result, index);
      }
    } else {
      print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Open EditItem Widget with item: ${ingredients[index].toMap().toString()}."); //LOGGING
      result = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => EditItem(ingredients[index], false))); // open EditWidget and wait until it's closed
      if (result != null) {
        print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Received item ${result.toMap().toString()}."); //LOGGING
        setState(() {
          ingredients[index] = result;
        });
      }
    }
    _saveIngredients();
  }
}
