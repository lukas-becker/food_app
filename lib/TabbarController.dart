import 'package:flutter/material.dart';

import 'tabs/favouriteListWidget.dart';
import 'tabs/pantryWidget.dart';
import 'tabs/recipeListWidget.dart';

class TabBarControllerWidget extends StatefulWidget {
  const TabBarControllerWidget({Key key}) : super(key: key);
  @override
  _TabBarControllerWidgetState createState() => _TabBarControllerWidgetState();

}

class _TabBarControllerWidgetState extends State<TabBarControllerWidget>
    with SingleTickerProviderStateMixin {
  var favoriteRecipes = [];

  final List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.kitchen)),
    Tab(icon: Icon(Icons.fastfood_outlined)),
    Tab(icon: Icon(Icons.food_bank_outlined)),
    Tab(icon: Icon(Icons.star)),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
        title: Text("Food App"),
      ),
      body: TabBarView(controller: _tabController, children: [
        PantryWidget(),
        RecipeListWidget(),
        Icon(Icons.directions_bike),
        FavouriteListWidget(),
      ]),
    );
  }

  List getFavorites(){
    return favoriteRecipes;
  }

  addFavorite(AsyncSnapshot added){
    this.favoriteRecipes.add(added);
  }

  removeFavorite(AsyncSnapshot toRemove){
    this.favoriteRecipes.remove(toRemove);
  }
}
