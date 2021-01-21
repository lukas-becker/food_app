import 'package:flutter/material.dart';
import 'package:food_app/classes/GroceryItem.dart';

class EditGroceryWidget extends StatelessWidget {
  final GroceryItem item;
  int index;

  EditGroceryWidget(this.item, this.index);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: EditGrocery(this.item, index));
  }
}

class EditGrocery extends StatefulWidget {
  final GroceryItem item;
  final int index;

  const EditGrocery(this.item, this.index);

  @override
  createState() => new _EditState(this.item, this.index);
}

class _EditState extends State<EditGrocery> {
  var nameController = new TextEditingController();
  var quantityController = new TextEditingController();
  String unitDropdown;
  bool once = true;
  final GroceryItem item;
  bool quantityError = false;
  final int index;

  FocusScopeNode node;

  List<String> units = ["piece", "gram", "kilogram", "ounce", "pound", "liter", "gallon"];

  _EditState(this.item, this.index) {
    if (item != null && once) {
      nameController.text = item.name;
      quantityController.text = "${item.quantity}";
      if (item.unit.contains("s")) item.unit.replaceAll("s", "");
      unitDropdown = item.unit;
      once = false;
    } else {
      unitDropdown = units[0];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String checkForPlural(double quantity) {
    String unit = unitDropdown;
    return quantity > 1 ? unit += "s" : unit;
  }

  double validateQuantity() {
    try {
      if (quantityController.text.contains(",")) {
        quantityController.text = quantityController.text.replaceAll(",", ".");
      }
      double quantity = double.parse(quantityController.text);
      if (node != null) node.nextFocus();
      quantityError = false;
      return quantity;

    } catch (e) {
      print("Quantity Input was not an Integer");
      quantityError = true;
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    this.node = FocusScope.of(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
                decoration: InputDecoration(labelText: "Enter name"),
                onEditingComplete: () => node.nextFocus(),
              ),
            ),
            Container(
              width: 200,
              margin: EdgeInsets.all(16),
              child: TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Enter quantity"),
                onEditingComplete: () => validateQuantity(),
              ),
            ),
            Container(
                width: 200,
                margin: EdgeInsets.all(16),
                child: DropdownButton<String>(
                  value: unitDropdown,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 20,
                  elevation: 16,
                  style: TextStyle(color: Colors.black),
                  underline: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      unitDropdown = newValue;
                    });
                  },
                  items: units.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Align(alignment: Alignment.center, child: Text(value)),
                    );
                  }).toList(),
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {sendToGroceryList()},
        child: Icon(Icons.add),
      ),
    );
  }

  sendToGroceryList() {
    double quantity = validateQuantity();
    if (!quantityError) {
      Navigator.pop(
          context,
          new GroceryItem(
              index, nameController.text, quantity, checkForPlural(quantity)));
    }
  }

  void _showError() {
    Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Please enter a number as the quantity!")));
  }
}
