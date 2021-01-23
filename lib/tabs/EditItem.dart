import 'package:flutter/material.dart';
import 'package:food_app/classes/Item.dart';
import 'package:food_app/globalVariables.dart' as globals;

class EditItem extends StatefulWidget {
  final Item item;
  final int index;
  final bool isSoppingList;

  const EditItem(this.item, this.index, this.isSoppingList);

  @override
  createState() => new _EditState(this.item, this.index, this.isSoppingList);
}

class _EditState extends State<EditItem> {
  final Item item;
  final int index;
  final bool isCalledFromShoppingList;

  var nameController = new TextEditingController();
  var quantityController = new TextEditingController();
  String unitDropdown;
  String nameDropdown;
  bool once = true;
  bool quantityError = false;
  FocusScopeNode node;

  _EditState(this.item, this.index, this.isCalledFromShoppingList) {
    if (item != null && once) {
      nameController.text = item.name;
      quantityController.text = "${item.amount}";
      unitDropdown = item.unit.contains("s") ? item.unit.replaceAll("s", "") : item.unit;
      once = false;
    } else {
      unitDropdown = globals.units[0];
      nameDropdown = globals.entries[0];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.node = FocusScope.of(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: _buildEditFields()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_sendBackToCaller()},
        child: Icon(Icons.add),
      ),
    );
  }

  /// build all needed Edit Fields.
  /// 1. Widget for name is dependent on where the EditTab is called from (pantry has only a selected number of items, shopping list is not restricted)
  /// 2. Amount
  /// 3. Unit of measurement
  List<Widget> _buildEditFields() {
    Widget nameWidget;

    if (this.isCalledFromShoppingList) {
      nameWidget = Container(
        width: 200,
        margin: EdgeInsets.all(16),
        child: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "Enter name"),
          onEditingComplete: () => node.nextFocus(),
        ),
      );
    } else {
      nameWidget = Container(
          width: 200,
          margin: EdgeInsets.all(16),
          child: DropdownButton(
            value: nameDropdown,
            isExpanded: true,
            icon: Icon(Icons.arrow_downward),
            iconSize: 20,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String newValue) => {
              setState(() {
                nameDropdown = newValue;
              })
            },
            items: globals.entries.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Align(alignment: Alignment.center, child: Text(value)),
              );
            }).toList(),
          ));
    }

    return [
      nameWidget,
      Container(
        width: 200,
        margin: EdgeInsets.all(16),
        child: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Enter quantity"),
          onEditingComplete: () => _validateAmount(),
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
            items: globals.units.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Align(alignment: Alignment.center, child: Text(value)),
              );
            }).toList(),
          ))
    ];
  }

  void _sendBackToCaller() {
    double quantity = _validateAmount();
    if (!quantityError) {
      if (this.isCalledFromShoppingList) {
        Navigator.pop(context, new Item(id: index, name: nameController.text, amount: quantity, unit: _checkUnitForPlural(quantity)));
      } else {
        Navigator.pop(context, new Item(id: index, name: nameDropdown, amount: quantity, unit: _checkUnitForPlural(quantity)));
      }
    }
  }

  void _showError() {
    Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Please enter a number as the quantity!")));
  }

  String _checkUnitForPlural(double amount) {
    String unit = unitDropdown;
    return amount > 1 ? unit += "s" : unit;
  }

  double _validateAmount() {
    try {
      if (quantityController.text.contains(",")) {
        quantityController.text = quantityController.text.replaceAll(",", ".");
      }
      double amount = double.parse(quantityController.text);
      if (node != null) node.nextFocus();
      quantityError = false;
      return amount;
    } catch (e) {
      print("Amount Input was not an Integer");
      quantityError = true;
      _showError();
      return null;
    }
  }
}
