import 'package:flutter/material.dart';
import 'package:snack_hunter/classes/Recipe.dart';
import 'package:snack_hunter/tabs/filteredRecipesWidget.dart';
import 'package:snack_hunter/tabs/recipeListWidget.dart';

import 'DatabaseUtil.dart';
import 'Item.dart';
import 'package:snack_hunter/globalVariables.dart' as globals;

/*
  This widget is used when the user tries to filter his recipes.
  The dialog displayed in the app is represented by this widget. 
*/

class CustomDialog extends StatefulWidget {
  final TabController tabController;

  CustomDialog({Key key, this.tabController}) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
// Map is used for handling the values of the selected ingredients
  Map<String, bool> checkBoxHandling = new Map();

// Those lists represent the ingredients which are / are not in the pantry
  List<Item> currentPantry = new List();
  List<String> notInPantry = globals
      .entries; // At the beginning all ingredients are listed in 'notInPantry'

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < notInPantry.length; i++) {
      checkBoxHandling.addAll({notInPantry[i].toString(): false});
    }

    // Look in database which ingredients are listed in pantry
    DatabaseUtil.getDatabase();
    DatabaseUtil.getIngredients().then((value) => {
          // create map-entries for every ingredient with value false and divide ingredients
          for (int i = 0; i < currentPantry.length; i++)
            {
              notInPantry.remove(currentPantry[i].toString()),
            },
          _loadIngredientsFinished(value)
        });
  }

  @override
  Widget build(BuildContext context) {
    // At the beginning of the build all widgets displayed in the dialog are gathered
    List<Widget> checkboxes = new List();

    // First, gather all ingredients in the pantry
    checkboxes.add(
      Text("Those ingredients are currently in your pantry:"),
    );
    for (int i = 0; i < currentPantry.length; i++) {
      checkboxes.add(
        CheckboxListTile(
          tristate: false,
          title: Text(currentPantry[i].toString()),
          value: checkBoxHandling[currentPantry[i].name],
          onChanged: (bool value) {
            setState(() {
              checkBoxHandling[currentPantry[i].name] = value;
              print(value
                  ? "[${DateTime.now().toIso8601String()}] INFO: ${currentPantry[i].name} was checked"
                  : "[${DateTime.now().toIso8601String()}] INFO: ${currentPantry[i].name} was unchecked");
            });
          },
        ),
      );
    }
    // Second, list the ingredients left
    checkboxes.add(
      Text("Other ingredients to filter:"),
    );
    for (int i = 0; i < notInPantry.length; i++) {
      checkboxes.add(
        CheckboxListTile(
          tristate: false,
          title: Text(notInPantry[i]),
          value: checkBoxHandling[this.notInPantry[i]],
          onChanged: (bool value) {
            setState(() {
              checkBoxHandling[notInPantry[i]] = value;
              print(value
                  ? "[${DateTime.now().toIso8601String()}] INFO: ${notInPantry[i]} was checked"
                  : "[${DateTime.now().toIso8601String()}] INFO: ${notInPantry[i]} was unchecked");
            });
          },
        ),
      );
    }
    // Display an AlertDialog which enables filtering for the user
    return AlertDialog(
      title: Text("Filter Recipes"),
      content: SingleChildScrollView(
        child: Column(
          children: checkboxes,
        ),
      ),
      actions:
          // Use filter or quit filtering
          <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
            print(
                "[${DateTime.now().toIso8601String()}] INFO: Filter cancelled");
          },
        ),
        TextButton(
          child: Text("Filter"),
          onPressed: () {
            widget.tabController.animateTo(0);
            _filter(context);
            print("[${DateTime.now().toIso8601String()}] INFO: Filter used");
          },
        ),
      ],
    );
  }

  // Creates a list with the filtered recipes and displays them in a separate MaterialPage
  void _filter(BuildContext context) {
    // closes Alertdialog
    Navigator.pop(context);
    List<Recipe> representedRecipes = new List();
    representedRecipes.addAll(
      // get all recipes that are displayed currently
      Recipes.getRecipes(),
    );

    // used for selection of filtered recipes
    List<String> selectedIngredients = new List();
    List<Recipe> filteredRecipes = new List();

    // save all chosen ingredients
    for (String ingredient in checkBoxHandling.keys) {
      if (checkBoxHandling[ingredient]) {
        selectedIngredients.add(ingredient.toLowerCase());
      }
    }
    Set selectedIngredientsSet = selectedIngredients.toSet();

    // check all ingredients from every displayed recipe
    for (Recipe current in representedRecipes) {
      List<String> currentIngredients = current.ingredients.split(',');
      for (String currentString in currentIngredients) {
        currentIngredients.add(currentString.toLowerCase().trim());
        currentIngredients.remove(currentString);
      }
      Set currentIngredientsSet = currentIngredients.toSet();

      // check if intersected set of selectedIngredientsSet and currentIngredientsSet equals set of selected ingredients
      if (selectedIngredientsSet.intersection(currentIngredientsSet).length ==
          selectedIngredientsSet.length) {
        filteredRecipes.add(current);
      }
    }

    // display all filtered recipes in a separate page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredRecipesWidget(
          filteredRecipes: filteredRecipes,
        ),
      ),
    );
  }

  // After loading ingredients from database save those values in a local variable
  void _loadIngredientsFinished(List<Item> ingr) {
    setState(() {
      currentPantry = ingr;
    });
  }
}
