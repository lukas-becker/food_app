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
      DatabaseUtil.getDatabase();
      DatabaseUtil.getGroceries().then((value) => setState((){items = value;}));
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
              title: Text(item.name, style: TextStyle(fontSize: fontSize)),
              subtitle: Text("Quantity: ${globals.prettyFormatDouble(item.amount)} ${item.unit}", style: TextStyle(fontSize: fontSize-2),),
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
  /// insert new Item to the list items
  void addNewGroceryItem(Item item, int index) {
    int indexWithSameName;
    for (int i = 0; i < items.length; i++) {
      if (item.name == items[i].name) {
        indexWithSameName = i;
      }
    }

    if (indexWithSameName != null) {
      //there already is an item with the same name
      setState(() {
        items[indexWithSameName] = Item(id: items[indexWithSameName].id, name: item.name, amount: item.amount, unit: item.unit);
      });
    } else {
      setState(() {
        items.insert(index, item);
      });
    }
  }

  /// remove the Item at index from database and the list items
  void removeGroceryItem(int index) {
    DatabaseUtil.deleteGrocery(items[index].id);
    setState(() {
      items.removeAt(index);
    });
  }

  /// insert all items in the database. insert function can overwrite elements in the db
  void _saveGroceries() {
    for (int i = 0; i < items.length; i++) {
      var grocery = items[i];
      DatabaseUtil.insertGrocery(grocery);
    }
  }

  void _awaitResultFromEditScreen(BuildContext context, int index) async {
    Item result;
    if (index > items.length - 1) {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(null, index, true)));
      if (result != null) {
        addNewGroceryItem(result, index);
      }
    } else {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(items[index], index, true)));
      if (result != null)
        setState(() {
          items[index] = result;
        });
    }
    _saveGroceries();
  }

}
