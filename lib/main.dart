import 'package:flutter/material.dart';
import 'tabs/favouriteListWidget.dart';
import 'tabs/pantryWidget.dart';
import 'tabs/recipeListWidget.dart';

void main() {
  runApp(TabNavigation());
}

//Tab Navigation
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
          length: myTabs.length,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: myTabs,
              ),
              title: Text("Snack Hunter"),
            ),
            body: TabBarView(children: [
              PantryWidget(),
              RecipeListWidget(),
              Icon(Icons.directions_bike),
              FavouriteListWidget(),
            ]),
          )),
    );
  }
}
