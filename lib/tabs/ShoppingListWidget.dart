import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Item.dart';
import 'package:food_app/tabs/EditItem.dart';
import 'package:food_app/globalVariables.dart' as globals;


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


  @override
  void initState() {
    super.initState();
    DatabaseUtil.getDatabase();
    if (!mounted) DatabaseUtil.getGroceries().then((value) => setState((){items = value;}));
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
              subtitle: Text("Quantity: ${globals.prettyFormatDouble(item.amount)} ${item.unit}"),
            ),
            actions: <Widget>[
              IconSlideAction(
                  caption: "Edit",
                  color: Colors.blue,
                  icon: Icons.edit,
                  onTap: () => _awaitResultFromEditScreen(context, index)
              ),
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

  void addNewGroceryItem(Item item, int index) {
    DatabaseUtil.insertGrocery(item);
    setState(() {
      items.insert(index, item);
    });
  }

  void removeGroceryItem(int index) {
    DatabaseUtil.deleteGrocery(items[index].id);
    setState(() {
      items.removeAt(index);
    });
  }

  void _saveGrocery() {
    for (int i = 0; i < items.length; i++) {
      var grocery = items[i];
      DatabaseUtil.insertGrocery(grocery);
    }
  }

  bool _checkForSameName(Item toAddItem) {
    for (Item item in items) {
      if (toAddItem.name == item.name) return true;
    }
    return false;
  }

  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    Item result;
    if (index > items.length - 1) {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(null, index, true)));
      if (result != null) {
        if (_checkForSameName(result)) {
          setState(() {
            items[index - 1] = Item(id: index - 1, name: result.name, amount: result.amount, unit: result.unit);
          });
        } else {
          addNewGroceryItem(result, index);
        }
      }
    } else {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(items[index], index, true)));
      if (result != null)
        setState(() {
          items[index] = result;
        });
    }
    _saveGrocery();
  }

}
