import 'package:flutter/material.dart';
import 'package:food_app/classes/Item.dart';
import 'package:food_app/tabs/ShoppingListWidget.dart';
import 'package:food_app/tabs/favouriteListWidget.dart';
import 'package:food_app/tabs/pantryWidget.dart';
import 'package:food_app/tabs/recipeListWidget.dart';
import 'package:food_app/globalVariables.dart' as globals;

import 'classes/CustomDialog.dart';
import 'tabs/ShoppingListWidget.dart';

class TabNavigation extends StatefulWidget {
  final List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.kitchen)),
    Tab(icon: Icon(Icons.fastfood_outlined)),
    Tab(icon: Icon(Icons.food_bank_outlined)),
    Tab(icon: Icon(Icons.star)),
  ];

  final tController = new TextEditingController();

  final _recipeList = new RecipeListWidget();

  final List<Item> currentPantry = new List();

  final Map<String, bool> checkBoxHandling = new Map();

  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation>
    with SingleTickerProviderStateMixin {
  var _secondTabActive = false;
  @override
  void initState() {
    super.initState();
  }

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
                //globals.search = false;
                if (tabController.index == 1) {
                  setState(() {
                    _secondTabActive = true;
                  });
                } else {
                  setState(
                    () {
                      _secondTabActive = false;
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
                widget._recipeList,
                ShoppingListWidget(),
                FavouriteListWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

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

  _searchRecipe(TabController tabController) {
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
              onPressed: () {
                _search();
                tabController.animateTo(1);
              },
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
      globals.searchString = widget.tController.text;
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
