import 'package:flutter/material.dart';

import 'tabs/pantryWidget.dart';
import 'tabs/recipeListWidget.dart';

void main() {
  runApp(TabNavigation());
}

//Tab Navigation
class TabNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.kitchen)),
                Tab(icon: Icon(Icons.fastfood_outlined)),
                Tab(icon: Icon(Icons.food_bank_outlined)),
              ],
            ),
            title: Text('Food App '),
          ),
          body: TabBarView(
            children: [
              PantryWidget(),
              RecipeListWidget(),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}