import 'package:flutter/material.dart';
import 'package:food_app/tabs/GroceryList.dart';
import 'package:food_app/TabbarController.dart';
import './TabbarController.dart';

void main() {
  runApp(TabNavigation());
}

//Tab Navigation
class TabNavigation extends StatefulWidget {
  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
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
              GroceryListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}