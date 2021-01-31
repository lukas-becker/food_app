import 'package:flutter/material.dart';
import 'package:food_app/AboutPage.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/globalVariables.dart' as globals;
import 'package:food_app/tabs/ShoppingListWidget.dart';
import 'package:food_app/tabs/favouriteListWidget.dart';
import 'package:food_app/tabs/pantryWidget.dart';
import 'package:food_app/tabs/recipeListWidget.dart';
import 'package:share/share.dart';

import 'classes/CustomDialog.dart';
import 'classes/Item.dart';
import 'tabs/ShoppingListWidget.dart';

class TabNavigation extends StatefulWidget {
  // Icons from the TabController
  final List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.kitchen)),
    Tab(icon: Icon(Icons.fastfood_outlined)),
    Tab(icon: Icon(Icons.shopping_bag_outlined)),
    Tab(icon: Icon(Icons.favorite)),
  ];

  final tController = new TextEditingController();

  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation>
    with SingleTickerProviderStateMixin {

  int previousTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.myTabs.length,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(
            () {
              if (tabController.index != previousTabIndex) {
                if (tabController.index == 1) {
                  setState(() {
                  });
                } else {
                  setState(
                    () {
                      globals.search = false;
                      globals.searchString = '';
                    },
                  );
                }

                previousTabIndex = tabController.index;
              }
            },
          );
          return Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: widget.myTabs,
              ),
              title: Text("Snack Hunter"),
              actions: _compileAppBarOptions(tabController)
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

  List<Widget> _compileAppBarOptions(TabController tabController){
    List<Widget> result;
    // If bool is true a different AppBar is displayed
    switch (tabController.index){
      case 1:
        result = [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(tabController);
            },
          ),
          IconButton(
            icon: Icon(Icons.search_outlined),
            onPressed: () => {
              _searchRecipe(tabController),
              tabController.animateTo(0),
            },
          ),
          IconButton(
            icon: Icon(Icons.all_inclusive),
            onPressed: () {
              tabController.animateTo(0);
              _exactRecipes(tabController);
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfo();
            },
          ),
        ];
        break;
      case 2:
        result = [
          IconButton(
            icon: Icon(Icons.share_outlined),
            onPressed: () {
              _shareShoppingList();
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfo();
            },
          ),
        ];
        break;
      default:
        result = [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfo();
            },
          ),
        ];
        break;

    }

    return result;

  }



  // Creates Dialog which asks user if he wants to display just recipes which he can cook with his ingredients in the pantry
  _exactRecipes(TabController tabController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Fitting your pantry",
            style: globals.mainTextStyle,
          ),
          content: Text(globals.exact
              ? "Do you want to remove this setting?"
              : "Do you want that all displayed recipes fit to your pantry?",
            style: globals.mainTextStyle,
          ),
          actions: <TextButton>[
            TextButton(
              child: Text("Yes", style: globals.mainTextStyle),
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
              child: Text("No", style: globals.mainTextStyle),
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
          title: Text("Search for Recipe", style: globals.mainTextStyle),
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
              child: Text("Cancel", style: globals.mainTextStyle),
            ),
            TextButton(
              onPressed: () {
                _search();
                tabController.animateTo(1);
                print(
                    "[${DateTime.now().toIso8601String()}] INFO: Searched for ${widget.tController.text}");
              },
              child: Text("Search", style: globals.mainTextStyle),
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

  _showInfo(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutPage()),
    );
  }

  _shareShoppingList() async{
    print(
        "[${DateTime.now().toIso8601String()}] INFO: Providing Grocery List to plattform share method");

    //Get grocery list
    List<Item> entries = await DatabaseUtil.getGroceries();
    StringBuffer result = new StringBuffer();
    result.write("Shopping List: \n");

    //Iterate over results and add them to the String
    for(Item i in entries){
      result.write(i.name + " : " + i.amount.toString() + " " + i.unit + "\n");
    }

    //Share
    Share.share(result.toString());
    
    
  }
}
