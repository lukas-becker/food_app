import 'package:flutter/material.dart';
import 'tabs/favouriteListWidget.dart';
import 'tabs/pantryWidget.dart';
import 'tabs/recipeListWidget.dart';
import 'globalVariables.dart' as globals;

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

  var _secondTabActive = false;

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
          child: Builder(
            builder: (BuildContext context) {
              final TabController tabController =
                  DefaultTabController.of(context);
              tabController.addListener(() {
                if (tabController.indexIsChanging) {
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
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.search_outlined,
                            ),
                            onPressed: null,
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
                body: TabBarView(
                  children: [
                    PantryWidget(),
                    RecipeListWidget(),
                    Icon(Icons.directions_bike),
                    FavouriteListWidget(),
                  ],
                ),
              );
            },
          )
          // Scaffold(
          //   appBar: AppBar(
          //     bottom: TabBar(
          //       tabs: myTabs,
          //     ),
          //     title: Text("Snack Hunter"),
          //   ),
          //   body: TabBarView(children: [
          //     PantryWidget(),
          //     RecipeListWidget(),
          //     Icon(Icons.directions_bike),
          //     FavouriteListWidget(),
          //   ]),
          // ),
          ),
    );
  }
}
