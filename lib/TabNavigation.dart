import 'package:flutter/material.dart';
import 'package:food_app/tabs/ShoppingListWidget.dart';
import 'package:food_app/tabs/favouriteListWidget.dart';
import 'package:food_app/tabs/pantryWidget.dart';
import 'package:food_app/tabs/recipeListWidget.dart';
import 'package:food_app/globalVariables.dart' as globals;

import 'classes/CustomDialog.dart';
import 'tabs/ShoppingListWidget.dart';

class TabNavigation extends StatefulWidget {
  // Icons from the TabController
  final List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.kitchen)),
    Tab(icon: Icon(Icons.fastfood_outlined)),
    Tab(icon: Icon(Icons.food_bank_outlined)),
    Tab(icon: Icon(Icons.star)),
  ];

  final tController = new TextEditingController();

  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation>
    with SingleTickerProviderStateMixin {
  // Boolean used for showing Icons in AppBar
  bool _secondTabActive = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.myTabs.length,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(
            () {
              if (tabController.indexIsChanging) {
                if (tabController.index == 1) {
                  setState(() {
                    _secondTabActive = true;
                  });
                } else {
                  setState(
                    () {
                      _secondTabActive = false;
                      globals.search = false;
                      globals.searchString = '';
                    },
                  );
                }
              }
            },
          );
          return Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: widget.myTabs,
              ),
              title: Text("Snack Hunter"),
              actions:
                  // If bool is true a different AppBar is displayed
                  (_secondTabActive)
                      ? <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.filter_list,
                            ),
                            onPressed: () {
                              _showFilterDialog(tabController);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.search_outlined,
                            ),
                            onPressed: () => {
                              _searchRecipe(tabController),
                              tabController.animateTo(0),
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.all_inclusive,
                            ),
                            onPressed: () {
                              tabController.animateTo(0);
                              _exactRecipes(tabController);
                            },
                          ),
                        ]
                      : null,
            ),
            body: TabBarView(
              controller: tabController,
              children: [
                PantryWidget(),
                RecipeListWidget(),
                ShoppingListWidget(),
                FavouriteListWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Creates Dialog which asks user if he wants to display just recipes which he can cook with his ingredients in the pantry
  _exactRecipes(TabController tabController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fitting your pantry"),
          content: Text(globals.exact
              ? "Do you want to remove this setting?"
              : "Do you want that all displayed recipes fit to your pantry?"),
          actions: <TextButton>[
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                setState(() {
                  // using global variables for changing displayed recipes
                  globals.exact = globals.exact ^ true;
                });
                tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("No"),
              onPressed: () {
                tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Opens dialog which enables searching for recipe names (independent from ingredients)
  void _searchRecipe(TabController tabController) {
    widget.tController.text = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Search for Recipe"),
          content: TextField(
            controller: widget.tController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Recipe',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => {
                print(
                    "[${DateTime.now().toIso8601String()}] INFO: Search cancelled"),
                tabController.animateTo(1),
                Navigator.pop(context),
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _search();
                tabController.animateTo(1);
                print(
                    "[${DateTime.now().toIso8601String()}] INFO: Searched for ${widget.tController.text}");
              },
              child: Text("Search"),
            ),
          ],
        );
      },
    );
  }

  // Sets global variables for search
  void _search() {
    setState(() {
      globals.search = true;
      globals.searchString = widget.tController.text;
    });
    Navigator.pop(context);
  }

  // Shows new FilterDialog
  _showFilterDialog(TabController tabController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(tabController: tabController,);
      },
    );
  }
}
