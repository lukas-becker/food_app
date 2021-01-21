import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/GroceryItem.dart';
import 'package:food_app/classes/GroceryStorage.dart';
import 'package:food_app/tabs/EditGrocery.dart';

class GroceryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lime,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: GroceryList(GroceryStorage()));
  }
}

class GroceryList extends StatefulWidget {
  final GroceryStorage storage;

  GroceryList(this.storage);

  @override
  createState() => new _GroceryState();
}

class _GroceryState extends State<GroceryList> {
  List<GroceryItem> items = [];

  @override
  void initState() {
    super.initState();
    DatabaseUtil.getDatabase();
    DatabaseUtil.getGroceries().then((value) => setState((){items = value;}));
  }

  void addNewGroceryItem(GroceryItem item, int index) {
    DatabaseUtil.insertGrocery(item);
    setState(() {
      items.insert(index, item);
    });
    print("Added new Grocery Item");
  }

  void removeGroceryItem(int index) {
    DatabaseUtil.deleteGrocery(items[index].id);
    setState(() {
      items.removeAt(index);
    });
    print("Removed Grocery Item");
  }

  void _saveGrocery() {
    for (int i = 0; i < items.length; i++) {
      var grocery = items[i];
      DatabaseUtil.insertGrocery(grocery);
    }
  }

  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    GroceryItem result;
    if (index > items.length - 1) {
      result = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => EditGrocery(null, index)));
      if (result != null)
        addNewGroceryItem(result, index);
    } else {
      result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => EditGrocery(items[index], index)));
      if (result != null)
        setState(() {
          items[index] = result;
        });
    }
    _saveGrocery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ListTile(
              title: Text(item.name),
              subtitle: Text("Quantity: ${formatDouble(item.quantity)} ${item.unit}"),
            ),
            actions: <Widget>[
              IconSlideAction(
                  caption: "Edit",
                  color: Colors.blue,
                  icon: Icons.edit,
                  onTap: () => {_awaitResultFromEditScreen(context, index)}),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: "Delete",
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => removeGroceryItem(index),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_awaitResultFromEditScreen(context, items.length)},
        child: Icon(Icons.add),
        backgroundColor: Colors.lime,
      ),
    );
  }


  String formatDouble(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
