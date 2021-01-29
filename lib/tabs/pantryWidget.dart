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
    DatabaseUtil.getIngredients().then((value) => setState(() {
          ingredients = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
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
                    icon: Icon(Icons.add,),
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
    _addItem(newItem, index);
  }

  void _decreaseAmount(int index) {
    Item oldItem = ingredients[index];
    if (oldItem.amount - 1 <= 0) {
      _removeItem(index);
    } else {
      Item newItem = Item(id: oldItem.id, name: oldItem.name, amount: oldItem.amount - 1, unit: oldItem.unit);
      _addItem(newItem, index);
    }
  }

  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    Item result;
    if (index > ingredients.length - 1) {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(null, index, false)));
      if (result != null) {
        _addItem(result, index);
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
    int indexWithSameName;
    for (int i = 0; i < ingredients.length; i++) {
      if (item.name == ingredients[i].name) {
        indexWithSameName = i;
      }
    }

    if (indexWithSameName != null) {
      //there already is an ingredient with the same name
      setState(() {
        ingredients[indexWithSameName] = Item(id: ingredients[indexWithSameName].id, name: item.name, amount: item.amount, unit: item.unit);
      });
    } else {
      setState(() {
        ingredients.insert(index, item);
      });
    }
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
}
