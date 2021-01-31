import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Item.dart';
import 'package:food_app/globalVariables.dart' as globals;
import 'package:food_app/tabs/EditItem.dart';

class ShoppingListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lime,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ShoppingList());
  }
}

class ShoppingList extends StatefulWidget {
  @override
  createState() => new _ShoppingState();
}

class _ShoppingState extends State<ShoppingList> {
  List<Item> items = [];
  final double fontSize = 16;

  @override
  void initState() {
    super.initState();
    //init db access
    DatabaseUtil.getDatabase();
    DatabaseUtil.getGroceries().then((value) => {
          if (this.mounted)
            {
              setState(() {
                items = value;
              })
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_awaitResultFromEditScreen(context, items.length)},
        child: Icon(Icons.add),
        backgroundColor: Colors.lime,
      ),
    );
  }

  /// determine if the items list is empty
  ///   yes - return widget with hint for user on how to add new items
  ///   no - return the ListView of items
  Widget _displayWidget() {
    if (items.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "You have no items in your shopping list!",
            style: globals.mainTextStyle,
          ),
          Text(
            "Add new items by pressing the button",
            style: globals.mainTextStyle,
          ),
          Text(
            "in the bottom right corner!",
            style: globals.mainTextStyle,
          ),
        ]),
      );
    } else {
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ListTile(
              title: Text(item.name, style: globals.mainTextStyle),
              subtitle: Text(
                "Quantity: ${globals.prettyFormatDouble(item.amount)} ${item.unit}",
                style: globals.smallTextStyle,
              ),
            ),
            actions: <Widget>[
              IconSlideAction(caption: "Edit", color: Colors.blue, icon: Icons.edit, onTap: () => _awaitResultFromEditScreen(context, index)),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: "Delete",
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _removeGroceryItem(index),
              ),
            ],
          );
        },
      );
    }
  }

  /// check if there is an item with the same name in the list items
  /// if so overwrite the item
  /// else insert new Item to the list items
  void _addOrUpdateGroceryItem(Item newItem, int index) {
    int indexWithSameName;
    for (int i = 0; i < items.length; i++) {
      if (newItem.name == items[i].name) {
        indexWithSameName = i;
      }
    }
    if (indexWithSameName != null) {
      //there already is an item with the same name
      setState(() {
        items[indexWithSameName] = Item(id: items[indexWithSameName].id, name: newItem.name, amount: newItem.amount, unit: newItem.unit);
      });
      print(
          "[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Overwrite item at position $indexWithSameName in the list with: ${newItem.toMap().toString()}."); //LOGGING
    } else {
      setState(() {
        items.insert(index, newItem);
      });
      print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Added new item: ${newItem.toMap().toString()} to the list."); //LOGGING
    }
  }

  /// remove the Item at index from database and the list items
  void _removeGroceryItem(int index) {
    DatabaseUtil.deleteGrocery(items[index].id);
    setState(() {
      items.removeAt(index);
    });
  }

  /// insert all items in the database. insert function can overwrite elements in the db
  void _saveGroceries() {
    print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Start saving items..."); //LOGGING
    for (int i = 0; i < items.length; i++) {
      var grocery = items[i];
      DatabaseUtil.insertGrocery(grocery);
    }
    print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Items saved."); //LOGGING
  }

  /// this function can be called from two positions:
  ///   1. FloatingActionButton
  ///   2. Edit Button from the ListTile
  ///
  /// if called from:
  ///   1 - index is equal to items.length, no item has to be sent to the EditItem widget
  ///   2 - index is equivalent to the items index at the list, this item will be sent to the EditItem widget
  ///
  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    Item result;
    if (index > items.length - 1) {
      print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Open EditItem Widget with no item."); //LOGGING
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(null, true))); // open EditWidget and wait until it's closed
      if (result != null) {
        print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Received item ${result.toMap().toString()}."); //LOGGING
        _addOrUpdateGroceryItem(result, index);
      }
    } else {
      print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Open EditItem Widget with item: ${items[index].toMap().toString()}."); //LOGGING
      result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(items[index], true))); // open EditWidget and wait until it's closed
      if (result != null) {
        print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Received item ${result.toMap().toString()}."); //LOGGING
        setState(() {
          items[index] = result;
        });
      }
    }
    _saveGroceries();
  }
}
