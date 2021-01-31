import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snack_hunter/classes/DatabaseUtil.dart';
import 'package:snack_hunter/classes/Favorite.dart';
import 'package:snack_hunter/classes/Recipe.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;
import 'package:snack_hunter/globalVariables.dart' as globals;


class FilteredRecipesWidget extends StatelessWidget {
  // List of recipes which are displayed
  final List<Recipe> filteredRecipes;

  FilteredRecipesWidget({Key key, @required this.filteredRecipes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Snack Hunter", style: globals.mainTextStyle),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: FilteredRecipes(filteredRecipes: filteredRecipes),
        ),
      ),
    );
  }
}

class FilteredRecipes extends StatefulWidget {
  final List<Recipe> filteredRecipes;
  FilteredRecipes({Key key, this.filteredRecipes}) : super(key: key);

  @override
  _FilteredRecipesState createState() => _FilteredRecipesState();
}

class _FilteredRecipesState extends State<FilteredRecipes> {
  List<Favorite> favorites = new List();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _showRecipes(context),
    );
  }

  @override
  void initState() {
    super.initState();
    //Favorites
    DatabaseUtil.getFavorites().then((value) => favoritesFetchComplete(value));
  }

  void favoritesFetchComplete(List<Favorite> loadedList) {
    loadedList.forEach((element) {
      favorites.add(element);
    });
    if (this.mounted) {
      setState(() {
        this.favorites = favorites;
      });
    }
  }

  // Builds widget
  List<Widget> _showRecipes(BuildContext context) {
    List<Widget> displayedList = new List();

    for (int i = 0; i < widget.filteredRecipes.length; i++) {
      // Between every recipe is a spacer
      displayedList.add(
        SizedBox(
          width: 8,
          height: 15,
        ),
      );

      bool isSaved = false;
      int favIndex;
      //Check if current recipe is favorite
      favorites.forEach((element) {
        if (element.recipe == widget.filteredRecipes[i]) {
          isSaved = true;
          favIndex = favorites.indexOf(element);
        }
      });

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
                  leading: Image.network(widget.filteredRecipes[i].thumbnail),
                  trailing: IconButton(
                    color: isSaved ? Colors.red : null,
                    onPressed: () {
                      //Add or remove Favorite
                      if (isSaved) {
                        DatabaseUtil.deleteFavorite(favorites[favIndex]);
                        favorites.removeAt(favIndex);
                        setState(() {
                          this.favorites = favorites;
                        });
                        print(
                            "[${DateTime.now().toIso8601String()}] INFO: Removed ${widget.filteredRecipes[i].title} from favorites");
                      } else {
                        DatabaseUtil.getNextFavoriteID().then((value) => {
                              setState(() {
                                favorites.add(Favorite(
                                    id: value,
                                    recipe: widget.filteredRecipes[i]));
                              }),
                              DatabaseUtil.insertFavorite(Favorite(
                                  id: value, recipe: widget.filteredRecipes[i]))
                            });
                        print(
                            "[${DateTime.now().toIso8601String()}] INFO: Marked ${widget.filteredRecipes[i].title} as favorite");
                      }
                    },
                    icon:
                        Icon(isSaved ? Icons.favorite : Icons.favorite_border),
                  ),
                  title: Text(widget.filteredRecipes[i].title, style: globals.mainTextStyle),
                  subtitle: Text(
                      "Ingredients: " + widget.filteredRecipes[i].ingredients, style: globals.smallTextStyle),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('CHECK IT OUT', style: globals.smallTextStyle),
                      onPressed: () {
                        _launchURL(context, widget.filteredRecipes[i].href);
                        print(
                            "[${DateTime.now().toIso8601String()}] INFO: Launched URL from recipe ${widget.filteredRecipes[i].title}");
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
        Text("You're filter has no results", style: globals.mainTextStyle),
      );
      displayedList.add(
        Text("Try to change your settings!", style: globals.mainTextStyle),
      );
      displayedList.add(
        // Option for going back
        RaisedButton(
          color: Colors.green,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Change it!", style: globals.mainTextStyle),
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
            animation: new custom.CustomTabsAnimation.slideIn()),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
}
