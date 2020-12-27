import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_app/classes/GroceryItem.dart';
import 'package:food_app/tabs/EditGrocery.dart';

class GroceryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: GroceryList());
  }
}

class GroceryList extends StatefulWidget {
  @override
  createState() => new _GroceryState();
}

class _GroceryState extends State<GroceryList> {
  List<GroceryItem> items = [];

  @override
  void initState() {
    super.initState();
  }

  void addNewGroceryItem(GroceryItem item) {
    setState(() {
      items.add(item);
    });
    print("Added new Grocery Item");
  }

  void removeGroceryItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    print("Removed Grocery Item");
  }

  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    GroceryItem result;
    if (index > items.length - 1) {
      result = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => EditGrocery(null)));
      if (result != null)
        setState(() {
          items.insert(index, result);
        });
    } else {
      result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => EditGrocery(items[index])));
      setState(() {
        items[index] = result;
      });
    }
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
            child: ListTile(title: Text(item.name)),
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
      ),
    );
  }
}
