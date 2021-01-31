import 'package:flutter/material.dart';
import 'package:snack_hunter/classes/Item.dart';
import 'package:snack_hunter/globalVariables.dart' as globals;
import 'package:uuid/uuid.dart';

class EditItem extends StatefulWidget {
  final Item item;
  final bool isSoppingList;

  const EditItem(this.item, this.isSoppingList);

  @override
  createState() => new _EditState(this.item, this.isSoppingList);
}

class _EditState extends State<EditItem> {
  final Item item;
  final bool calledFromShoppingList;

  final double editContainerWidth = 200;
  final double fontSize = 18;

  var nameController = new TextEditingController();
  var amountController = new TextEditingController();
  String unitDropdown;
  String nameDropdown;
  bool once = true;
  bool amountError = false;
  FocusScopeNode node;

  _EditState(this.item, this.calledFromShoppingList) {
    if (item != null && once) {
      nameController.text = item.name;
      amountController.text = "${item.amount}";
      unitDropdown = item.unit.contains("s") ? item.unit.replaceAll("s", "") : item.unit;
      nameDropdown = item.name;
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
          _getNameInputWidget(),
          Container(
            width: editContainerWidth,
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
              width: editContainerWidth,
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
                    child: Align(alignment: Alignment.centerLeft, child: Text(value)),
                  );
                }).toList(),
              ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_sendBackToCaller()},
        child: Icon(Icons.add),
      ),
    );
  }

  /// get the needed Widget for
  /// Widget for name is dependent on where the EditTab is called from
  /// pantry has only a selected number of items, the name must be chosen from predefined list
  /// shopping list items are not restricted, so it can be a normal TextField
  Widget _getNameInputWidget() {
    Widget nameWidget;
    if (this.calledFromShoppingList) {
      nameWidget = Container(
        width: editContainerWidth,
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
          width: editContainerWidth,
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
    return nameWidget;
  }

  ///  Close the Edit Window and send the item to the sender.
  void _sendBackToCaller() {
    double amount = _validateAmount();
    if (amount != null) {
      String unit = _checkUnitForPlural(amount);
      String UUIDString = Uuid().v1();

      print(UUIDString);
      if (this.calledFromShoppingList) {
        Item sendItem = new Item(id: UUIDString, name: nameController.text.trim(), amount: amount, unit: unit);
        print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Send Item ${sendItem.toMap().toString()} back to shopping list."); //LOGGING
        Navigator.pop(context, sendItem);
      } else {
        Item sendItem = new Item(id: UUIDString, name: nameDropdown.trim(), amount: amount, unit: unit);
        print("[${DateTime.now().toIso8601String()}] INFO: In Class: ${this} Send Item ${sendItem.toMap().toString()} back to pantry."); //LOGGING
        Navigator.pop(context, sendItem);
      }
    }
  }

  /// Display the user, that there input was faulty
  void _showError() {
    Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Please enter a number as the amount!")));
    print("[${DateTime.now().toIso8601String()}] INFO: User got notified after the parsing has failed."); //LOGGING
  }

  /// Add an s to the unit if the amount is bigger then 1
  String _checkUnitForPlural(double amount) {
    String unit = unitDropdown;
    return (amount > 1) ? unit += "s" : unit;
  }

  /// Parse the Input amount, show error when parsing failed
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
      print("[${DateTime.now().toIso8601String()}] INFO: Parsing ${amountController.text} has failed."); //LOGGING
      amountError = true;
      _showError();
      return null;
    }
  }
}
