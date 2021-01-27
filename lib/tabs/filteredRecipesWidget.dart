import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_app/classes/Recipe.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;

class FilteredRecipesWidget extends StatelessWidget {
  // List of recipes which are displayed
  final List<Recipe> filteredRecipes;

  FilteredRecipesWidget({Key key, @required this.filteredRecipes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Snack Hunter"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: _showRecipes(context)),
        ),
      ),
    );
  }

  // Builds widget
  List<Widget> _showRecipes(BuildContext context) {
    List<Widget> displayedList = new List();
    for (int i = 0; i < filteredRecipes.length; i++) {
      // Between every recipe is a spacer
      displayedList.add(
        SizedBox(
          width: 8,
          height: 15,
        ),
      );

      // Every recipe is displayed with an image (if available) and its ingredients
      // Also a button which enables visitting the primary website
      displayedList.add(
        Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Image.network(filteredRecipes[i].thumbnail),
                  title: Text(filteredRecipes[i].title),
                  subtitle:
                      Text("Ingredients: " + filteredRecipes[i].ingredients),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('CHECK IT OUT'),
                      onPressed: () {
                        _launchURL(context, filteredRecipes[i].href);
                        print("[${DateTime.now().toIso8601String()}] INFO: Launched URL from recipe ${filteredRecipes[i].title}");
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    // If no recipe fits to the filter a short dialog is displayed
    if (displayedList.length == 0) {
      displayedList.add(
        SizedBox(
          width: 8,
          height: 15,
        ),
      );
      displayedList.add(
        Text("You're filter has no results"),
      );
      displayedList.add(
        Text("Try to change your settings!"),
      );
      displayedList.add(
        // Option for going back
        RaisedButton(
          color: Colors.green,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Change it!"),
        ),
      );
    }

    return displayedList;
  }

  // Launches the website which offers the recipe 
  _launchURL(BuildContext context, String url) async {
    try {
      // Use of Chrome CustomTab
      await custom.launch(
        url,
        option: new custom.CustomTabsOption(
            toolbarColor: Theme.of(context).primaryColor,
            enableDefaultShare: true,
            enableUrlBarHiding: true,
            showPageTitle: true,
            animation: new custom.CustomTabsAnimation.slideIn()
            ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
}
