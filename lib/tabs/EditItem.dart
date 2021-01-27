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

  final double editWidth = 200;
  final double fontSize = 18;

  var nameController = new TextEditingController();
  var amountController = new TextEditingController();
  String unitDropdown;
  String nameDropdown;
  bool once = true;
  bool amountError = false;
  FocusScopeNode node;

  _EditState(this.item, this.index, this.isCalledFromShoppingList) {
    if (item != null && once) {
      nameController.text = item.name;
      amountController.text = "${item.amount}";
      unitDropdown =
          item.unit.contains("s") ? item.unit.replaceAll("s", "") : item.unit;
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
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildEditFields()),
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
        width: editWidth,
        margin: EdgeInsets.all(16),
        child: TextField(
          controller: nameController,
          style: TextStyle(color: Colors.black, fontSize: fontSize),
          decoration: InputDecoration(labelText: "Enter name"),
          onEditingComplete: () => node.nextFocus(),
        ),
      );
    } else {
      nameWidget = Container(
          width: editWidth,
          margin: EdgeInsets.all(16),
          child: DropdownButton(
            value: nameDropdown,
            isExpanded: true,
            icon: Icon(Icons.arrow_downward),
            iconSize: 20,
            elevation: 16,
            style: TextStyle(color: Colors.black, fontSize: fontSize),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            onChanged: (String newValue) => {
              setState(() {
                nameDropdown = newValue;
              }),
            },
            items:
                globals.entries.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child:
                    Align(alignment: Alignment.centerLeft, child: Text(value)),
              );
            }).toList(),
          ));
    }

    return [
      nameWidget,
      Container(
        width: editWidth,
        margin: EdgeInsets.all(16),
        child: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Enter amount"),
          style: TextStyle(color: Colors.black, fontSize: fontSize),
          onEditingComplete: () => _validateAmount(),
        ),
      ),
      Container(
          width: editWidth,
          margin: EdgeInsets.all(16),
          child: DropdownButton<String>(
            value: unitDropdown,
            isExpanded: true,
            icon: Icon(Icons.arrow_downward),
            iconSize: 20,
            elevation: 16,
            style: TextStyle(color: Colors.black, fontSize: fontSize),
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
                child:
                    Align(alignment: Alignment.centerLeft, child: Text(value)),
              );
            }).toList(),
          ))
    ];
  }

  void _sendBackToCaller() {
    double amount = _validateAmount();
    if (!amountError) {
      if (this.isCalledFromShoppingList) {
        Item sendItem = new Item(
            id: index,
            name: nameController.text,
            amount: amount,
            unit: _checkUnitForPlural(amount));
        print(
            "[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Send Item ${sendItem.toMap().toString()} back to shopping list.");
        Navigator.pop(context, sendItem);
      } else {
        Item sendItem = new Item(
            id: index,
            name: nameDropdown,
            amount: amount,
            unit: _checkUnitForPlural(amount));
        print(
            "[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Send Item ${sendItem.toMap().toString()} back to pantry.");
        Navigator.pop(context, sendItem);
      }
    }
  }

  void _showError() {
    Scaffold.of(context).showSnackBar(
        new SnackBar(content: Text("Please enter a number as the amouont!")));
  }

  String _checkUnitForPlural(double amount) {
    String unit = unitDropdown;
    return (amount > 1) ? unit += "s" : unit;
  }

  double _validateAmount() {
    try {
      if (amountController.text.contains(",")) {
        amountController.text = amountController.text.replaceAll(",", ".");
      }
      double amount = double.parse(amountController.text);
      if (node != null) node.nextFocus();
      amountError = false;
      return amount;
    } catch (e) {
      print("Amount Input was not an Integer");
      amountError = true;
      _showError();
      return null;
    }
  }
}
