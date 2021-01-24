//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;
import 'package:food_app/classes/Favorite.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Item.dart';
import 'package:http/http.dart' as http;
import 'package:powerset/powerset.dart';
import 'dart:convert';
import 'package:food_app/globalVariables.dart' as globals;
import 'package:carousel_slider/carousel_slider.dart';

import '../classes/Recipe.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

//Center Tab Recipe List
class RecipeListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Recipes(
          title: 'Get your first recipe'));
  }

  static List<Recipe> getRecipes() {
    return Recipes.getRecipes();
  }
}

class Recipes extends StatefulWidget {
  Recipes({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RecipesState createState() => _RecipesState();

  static List<Recipe> getRecipes() {
    return _RecipesState.getRecipes();
  }
}

class _RecipesState extends State<Recipes> {
  List<Widget> displayedRecipes = new List();

  //Recipe Storage
  var futureRecipes = [];
  static List<Recipe> recipes = new List();
  List<Favorite> favorites = new List();

  var favouriteRecipes = [];

  //int count = 0;

  List<Item> ingredients;

  //filtering
  List<String> allIngredients = new List();

  //for Textboxes
  final tController = new TextEditingController();

  //Load json from Api, ingredient as parameter
  Future<List<Recipe>> fetchJson(String ingr) async {
    ingr = ingr.substring(1, ingr.length - 1);
    ingr = ingr.replaceAll(" ", "");
    print('Downloading: http://www.recipepuppy.com/api/?i=' + ingr);
    final response =
        await http.get('http://www.recipepuppy.com/api/?i=' + ingr);
    if (response.statusCode == 200) {
      print("Got response");
      List list = jsonDecode(response.body)['results'];
      List<Recipe> res = List.generate(
          list.length,
          (index) =>
              Recipe.fromJson(jsonDecode(response.body)['results'][index]));


      //To prevent results appearing multiple times
      for(Recipe r in res){
        for (Recipe ri in recipes){
          if (r == ri){
            res.remove(r);
          }
        }
      }

      return res;
    }
  }

  Future<List<Recipe>> _searchRecipeApi(String recipeName) async {
    print("Downloading: http://www.recipepuppy.com/api/?q=" + recipeName);
    List<Recipe> res = [];
    final response =
        await http.get("http://www.recipepuppy.com/api/?q=" + recipeName);
    if (response.statusCode == 200) {
      print("got Response");
      List list = jsonDecode(response.body)['results'];
      res = List.generate(
          list.length,
          (index) =>
              Recipe.fromJson(jsonDecode(response.body)['results'][index]));
    }
    res.forEach((element) {
      print(element.toString());
    });
    return res;
  }

  @override
  void initState() {
    super.initState();
    //Favourites
    print("Before init:" + favouriteRecipes.toString());
    if (!globals.search) {
      //Ingredients from "Pantry"
      DatabaseUtil.getDatabase();
      DatabaseUtil.getIngredients()
          .then((value) => ingredientsFetchComplete(value));
    } else {
      _searchRecipeApi(globals.searchString)
          .then((value) => setRecipeList(value));
    }
    DatabaseUtil.getFavorites().then((value) => favoritesFetchComplete(value));
  }

  List<String> favouritesFinished(List<String> fav) {
    setState(() {
      favouriteRecipes = fav;
      print("Fav from asynchron loading:" + fav.toString());
      print("After init:" + favouriteRecipes.toString());
    });
    return fav;
  }

  void ingredientsFetchComplete(List<Item> ingr) {
    ingr.forEach((element) {
      allIngredients.add(element.name.toUpperCase());
    });
    powerset(ingr).forEach((element) {
      if (element.toString() != "[]") {
        print("Checking api for: " + element.toString());
        fetchJson(element.toString()).then(
          (value) => {
            addToRecipeList(value),
          },
        );
      }
    });
  }

  // void _reformatList(List<Recipe> recipes) {
  //   print("_reformatList called");
  //   for (int i; i < recipes.length; i++) {
  //     print(recipes[i]);
  //   }
  // }

  void addToRecipeList(List<Recipe> newRecipes) {
    newRecipes.forEach((element) {
      element = _reformatElement(element);
      recipes.add(element);
    });
    setState(() {
      _RecipesState.recipes = recipes;
    });
  }

  Recipe _reformatElement(Recipe element) {
    element.href = element.href.trim();
    element.ingredients = element.ingredients.trim();
    element.thumbnail = element.thumbnail.trim();
    element.title = element.title.trim();
    return element;
  }

  void favoritesFetchComplete(List<Favorite> fav) {
    fav.forEach((element) {
      favorites.add(element);
    });

    setState(() {
      this.favorites = favorites;
    });
  }

  void setRecipeList(List<Recipe> searchedRecipes) {
    recipes = [];
    searchedRecipes.forEach((element) {
      recipes.add(element);
    });
    setState(() {
      _RecipesState.recipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: _compileRecipes()),
        ),
      ),
    );
  }

  List<Widget> result = new List();

  List<Widget> _compileRecipes() {
    setState(() {
      result = [];
    });
    result.add(SizedBox(
      width: 8,
      height: 15,
    ));
    //Iterate over each recipe
    //100 to prevent loop from running
    for (int i = 0; i < recipes.length; i++) {
      //Replace with default thumbnail
      if (recipes[i].thumbnail == null)
        recipes[i].thumbnail =
            "https://upload.wikimedia.org/wikipedia/commons/e/ea/No_image_preview.png";




      bool _continue = false;
      //If only "makeable" recipes should be shown
      if (globals.exact) {
        //Ingredients of current recipe
        String _ingredients = recipes[i].ingredients;
        //One ingredient of possible list
        String _ingredient;
        //count how many ingredients there are
        int countIngredients = _ingredients.split(",").length;
        print("Ingredients for recipe (" +
            countIngredients.toString() +
            "): " +
            _ingredients);
        //Loop variables
        int index = 0;
        int nextIndex;
        for (int j = 0; j < countIngredients; j++) {
          nextIndex = _ingredients.indexOf(",", index);

          if (nextIndex == -1) {
            print("Checking range from " + index.toString());
            _ingredient = _ingredients.substring(index).toUpperCase();
          } else {
            print("Checking range between " +
                index.toString() +
                " and " +
                nextIndex.toString());
            _ingredient =
                _ingredients.substring(index, nextIndex).toUpperCase();
          }

          if (_ingredient.startsWith(" "))
            _ingredient = _ingredient.replaceFirst(" ", "");

          print("checking: " + _ingredient);
          if (_ingredient.contains(" ")) {
            int spaceIndex = 0;
            int nextSpaceIndex;
            int loopCondition = _ingredient.split(" ").length;

            bool multiWordContinueTemp = false;
            for (int k = 0; k < loopCondition; k++) {
              String toCheck;

              nextSpaceIndex = _ingredient.indexOf(" ", spaceIndex);

              print("spaceIndex: " + spaceIndex.toString());

              if (nextSpaceIndex == -1)
                toCheck = _ingredient.substring(spaceIndex);
              else
                toCheck = _ingredient.substring(
                    spaceIndex, _ingredient.indexOf(" ", spaceIndex));

              if (toCheck.startsWith(" "))
                toCheck = toCheck.replaceFirst(" ", "");

              print("Checking: " +
                  toCheck +
                  " (" +
                  (k + 1).toString() +
                  "/" +
                  (loopCondition).toString() +
                  ")");

              if (!(allIngredients.contains(toCheck))) {
                multiWordContinueTemp = true;
                print(toCheck + " is not in the List");
              } else {
                multiWordContinueTemp = false;
                print(toCheck + " is in the List");
                break;
              }

              spaceIndex = nextSpaceIndex + 1;
            }

            if (multiWordContinueTemp) _continue = true;
          } else {
            if (!(allIngredients.contains(_ingredient.toUpperCase()))) {
              print(_ingredient + " is not in the List");
              _continue = true;
            }
          }

          index = nextIndex + 1;
        }
      }

      if (_continue) continue;

      bool isSaved = false;
      int favID;
      int favIndex;

      favorites.forEach((element) {
        if (element.recipe == recipes[i]) {
          isSaved = true;
          favIndex = favorites.indexOf(element);
        }
      });



      result.add(SizedBox(
        width: 8,
        height: 15,
      ));
      result.add(Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            print('Card tapped.');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  leading: Image.network(recipes[i].thumbnail),
                  trailing: IconButton(
                    color: isSaved ? Colors.red : null,
                    onPressed: () {
                      if (isSaved) {
                        DatabaseUtil.deleteFavorite(favorites[
                            favIndex]); //.then((value) => setState((){favorites.remove(favIndex);}));
                        favorites.removeAt(favIndex);
                        setState(() {
                          this.favorites = favorites;
                        });
                      } else {
                        DatabaseUtil.getNextFavoriteID().then((value) => {
                              setState(() {
                                favorites.add(
                                    Favorite(id: value, recipe: recipes[i]));
                              }),
                              DatabaseUtil.insertFavorite(
                                  Favorite(id: value, recipe: recipes[i]))
                            });
                      }
                    },
                    icon:
                        Icon(isSaved ? Icons.favorite : Icons.favorite_border),
                  ),
                  title: Text(recipes[i].title),
                  subtitle: Text("Ingredients: " + recipes[i].ingredients)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('CHECK IT OUT'),
                    onPressed: () {
                      _launchURL(context, recipes[i].href);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ));
    }

    if (recipes.length == 0) {
      result.add(SizedBox(
        width: 8,
        height: 15,
      ));
      result.add(Text("You have nothing in your Pantry!"));
      result.add(Text("Add some food, to see what you could cook!"));
      result.add(RaisedButton(
          color: Colors.green,
          onPressed: () {
            TabController tc = DefaultTabController.of(context);
            tc.animateTo(tc.index - 1);
          },
          child: Text("Take me there")));
    }
    print(result.length);
    if (result.length == 0) {
      result.add(SizedBox(
        width: 8,
        height: 15,
      ));
      result.add(Text("Your Filter fit no results!"));
      result.add(Text("Add some food, or adjust it!"));
      result.add(RaisedButton(
          color: Colors.green,
          onPressed: () {
            TabController tc = DefaultTabController.of(context);
            tc.animateTo(tc.index - 1);
          },
          child: Text("Take me to the Pantry")));
    }

    return result;
  }

  _launchURL(BuildContext context, String url) async {
    try {
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

  static List<Recipe> getRecipes() {
    return recipes;
  }
}
