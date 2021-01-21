import 'package:flutter/material.dart';
import 'package:food_app/classes/Ingredient.dart';
import 'package:food_app/tabs/GroceryListWidget.dart';
import 'package:food_app/tabs/favouriteListWidget.dart';
import 'package:food_app/tabs/pantryWidget.dart';
import 'package:food_app/tabs/recipeListWidget.dart';
import 'package:food_app/globalVariables.dart' as globals;

import 'classes/CustomDialog.dart';

class TabNavigation extends StatefulWidget {
  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  final List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.kitchen)),
    Tab(icon: Icon(Icons.fastfood_outlined)),
    Tab(icon: Icon(Icons.food_bank_outlined)),
    Tab(icon: Icon(Icons.star)),
  ];

  var _secondTabActive = false;

  var tController = new TextEditingController();

  var _recipeList = new RecipeListWidget();

  List<Ingredient> currentPantry = new List();

  Map<String, bool> checkBoxHandling = new Map();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (tabController.indexIsChanging) {
            //globals.search = false;
            if (tabController.index == 1) {
              setState(() {
                _secondTabActive = true;
              });
            } else {
              setState(() {
                _secondTabActive = false;
              });
            }
          }
        });
        return Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: myTabs,
            ),
            title: Text("Snack Hunter"),
            actions: (_secondTabActive)
                ? <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                      ),
                      onPressed: () {
                        _showFilterDialog();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search_outlined,
                      ),
                      onPressed: () {
                        _searchRecipe();
                      },
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.all_inclusive,
                        ),
                        onPressed: () {
                          setState(() {
                            globals.exact = globals.exact ^ true;
                          });
                        }),
                  ]
                : null,
          ),
          body: TabBarView(children: [
            PantryWidget(),
            RecipeListWidget(),
            GroceryListWidget(),
            _recipeList,
            FavouriteListWidget(),
          ]),
        );
      }),
    );
  }

  _searchRecipe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Search for Recipe"),
          content: TextField(
            controller: tController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Recipe',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _search,
              child: Text("Search"),
            ),
            TextButton(
              onPressed: () => {
                Navigator.pop(context),
              },
              child: Text("Cancel"),
            )
          ],
        );
      },
    );
  }

  _search() {
    setState(() {
      globals.search = true;
      globals.searchString = tController.text;
      _recipeList.build(context);
    });
    Navigator.pop(context);
  }

  _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog();
      },
    );
  }
}
