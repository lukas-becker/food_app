import 'package:flutter/material.dart';
import 'package:food_app/classes/GroceryItem.dart';

class EditGroceryWidget extends StatelessWidget {
  final GroceryItem item;

  EditGroceryWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: EditGrocery(this.item));
  }
}

class EditGrocery extends StatefulWidget {
  final GroceryItem item;

  const EditGrocery(this.item);

  @override
  createState() => new _EditState(this.item);
}

class _EditState extends State<EditGrocery> {
  final GroceryItem item;

  _EditState(this.item);

  @override
  void initState() {
    super.initState();
  }

  var nameController = new TextEditingController();
  var quantityController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (item != null) {
      nameController.text = item.name;
      quantityController.text = "${item.quantity}";
    }
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              margin: EdgeInsets.all(16),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: "Enter name"),
              ),
            ),
            Container(
              width: 200,
              margin: EdgeInsets.all(16),
              child: TextField(
                controller: quantityController,
                decoration: InputDecoration(hintText: "Enter quantity"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, new GroceryItem(nameController.text, int.parse(quantityController.text)));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
