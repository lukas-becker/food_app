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

  @override
  void initState() {
    super.initState();
    DatabaseUtil.getDatabase();
    DatabaseUtil.getIngredients().then((value) => setState(() {
          ingredients = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
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
                  Text(ingredients[index].name + " : " + globals.prettyFormatDouble(ingredients[index].amount)),
                  IconButton(
                    icon: Icon(Icons.add),
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
                  onTap: () => _removeItem(index),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _awaitResultFromEditScreen(context, ingredients.length),
        child: Icon(Icons.add),
        backgroundColor: Colors.lime,
      ),
    );
  }

  void _increaseAmount(int index) {
    Item oldItem = ingredients[index];
    Item newItem = Item(id: oldItem.id, name: oldItem.name, amount: oldItem.amount + 1, unit: oldItem.unit);
    setState(() {
      ingredients[index] = newItem;
    });
  }

  void _decreaseAmount(int index) {
    Item oldItem = ingredients[index];
    if (oldItem.amount - 1 <= 0) {
      _removeItem(index);
      return;
    }
    Item newItem = Item(id: oldItem.id, name: oldItem.name, amount: oldItem.amount - 1, unit: oldItem.unit);
    setState(() {
      ingredients[index] = newItem;
    });
  }

  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    Item result;
    if (index > ingredients.length - 1) {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(null, index, false)));
      if (result != null) {
        if (_checkForSameName(result)) {
          setState(() {
            ingredients[index - 1] = Item(id: index - 1, name: result.name, amount: result.amount, unit: result.unit);
          });
        } else {
          _addItem(result, index);
        }
      }
    } else {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(ingredients[index], index, false)));
      if (result != null)
        setState(() {
          ingredients[index] = result;
        });
    }
    _saveGrocery();
  }

  void _addItem(Item item, int index) {
    DatabaseUtil.insertIngredient(item);
    setState(() {
      ingredients.insert(index, item);
    });
    print("Added new Grocery Item");
  }

  void _removeItem(int index) {
    DatabaseUtil.deleteIngredient(ingredients[index].id);
    setState(() {
      ingredients.removeAt(index);
    });
    print("Removed Grocery Item");
  }

  void _saveGrocery() {
    for (int i = 0; i < ingredients.length; i++) {
      var ingredient = ingredients[i];
      DatabaseUtil.insertIngredient(ingredient);
    }
  }

  bool _checkForSameName(Item toAddItem) {
    for (Item ingredient in ingredients) {
      if (toAddItem.name == ingredient.name) return true;
    }
    return false;
  }
}

//End of Pantry
