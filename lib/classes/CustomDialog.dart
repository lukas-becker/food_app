import 'package:flutter/material.dart';
import 'package:food_app/classes/Recipe.dart';
import 'package:food_app/tabs/filteredRecipesWidget.dart';
import 'package:food_app/tabs/recipeListWidget.dart';

import 'DatabaseUtil.dart';
import 'Ingredient.dart';
import 'package:food_app/globalVariables.dart' as globals;

class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  Map<String, bool> checkBoxHandling = new Map();

  List<Ingredient> currentPantry = new List();

  List<String> notInPantry = globals.entries;

  @override
  void initState() {
    super.initState();
    DatabaseUtil.getDatabase();
    DatabaseUtil.getIngredients().then((value) => {
          _loadIngredientsFinished(value),
          for (int i = 0; i < currentPantry.length; i++)
            {
              checkBoxHandling.addAll({currentPantry[i].toString(): false}),
              notInPantry.remove(currentPantry[i].toString()),
            },
          for (int i = 0; i < notInPantry.length; i++)
            {
              checkBoxHandling.addAll({notInPantry[i]: false}),
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    print("called");
    List<Widget> checkboxes = new List();
    checkboxes.add(
      Text("Those ingredients are currently in your pantry:"),
    );
    for (int i = 0; i < currentPantry.length; i++) {
      print(checkBoxHandling.toString());
      checkboxes.add(
        CheckboxListTile(
          title: Text(currentPantry[i].toString()),
          value: checkBoxHandling[currentPantry[i].toString()],
          onChanged: (bool value) {
            setState(() {
              print(currentPantry[i].toString() + " $value");
              checkBoxHandling[currentPantry[i].toString()] = value;
            });
          },
        ),
      );
    }
    checkboxes.add(
      Text("Other ingredients to filter:"),
    );
    print("Ingredients");
    for (int i = 0; i < notInPantry.length; i++) {
      print("$i" + notInPantry[i]);
      print("$i" + checkBoxHandling[notInPantry[i]].toString());
      checkboxes.add(
        CheckboxListTile(
          title: Text(notInPantry[i]),
          value: checkBoxHandling[notInPantry[i]],
          onChanged: (bool value) {
            setState(() {
              print(notInPantry[i] + " $value");
              checkBoxHandling[notInPantry[i]] = value;
            });
          },
        ),
      );
    }
    return AlertDialog(
      title: Text("Filter Recipes"),
      content: SingleChildScrollView(
        child: Column(
          children: checkboxes,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Filter"),
          onPressed: () {
            _filter(context);
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  _filter(BuildContext context) {
    Navigator.pop(context);
    List<Recipe> representedRecipes = new List();
    representedRecipes.addAll(
      Recipes.getRecipes(),
    );

    List<String> selectedIngredients = new List();
    List<Recipe> filteredRecipes = new List();

    for (String ingredient in checkBoxHandling.keys) {
      if (checkBoxHandling[ingredient]) {
        selectedIngredients.add(ingredient);
        for (Recipe current in representedRecipes) {
          List<String> currentIngredients = current.ingredients.split(',');
          String help = current.title;
          if (currentIngredients.contains(ingredient.toLowerCase())) {
            print("$help enthält $current");
            filteredRecipes.add(current);
          }
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredRecipesWidget(
          filteredRecipes: filteredRecipes,
        ),
      ),
    );
  }

  _loadIngredientsFinished(List<Ingredient> ingr) {
    setState(() {
      currentPantry = ingr;
    });
  }
}
