import 'package:flutter/material.dart';
import 'package:food_app/tabs/GroceryList.dart';
import 'package:food_app/TabbarController.dart';
import 'package:food_app/tabs/pantryWidget.dart';
import 'package:food_app/tabs/recipeListWidget.dart';
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
      home: TabBarControllerWidget(),
    );
  }
}