import 'package:flutter/material.dart';
import 'package:food_app/classes/FavouriteStorage.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Ingredient.dart';
import 'package:http/http.dart' as http;
import 'package:powerset/powerset.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_app/globalVariables.dart' as globals;

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
          title: 'Get your first recipe', favStorage: FavouriteStorage()),
    );
  }
}

class Recipes extends StatefulWidget {
  final FavouriteStorage favStorage;
  Recipes({Key key, this.title, @required this.favStorage}) : super(key: key);

  final String title;

  @override
  _RecipesState createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  //Recipe Storage
  var futureRecipes = [];
  List<Recipe> recipes = new List();

  var favouriteRecipes = [];

  //int count = 0;

  List<Ingredient> ingredients;

  //Speed Dial
  bool _dialVisible = true;

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
      return res;
    }
  }

  Future<List<Recipe>> searchRecipe(String recipeName) async {
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
    return res;
  }

  @override
  void initState() {
    super.initState();
    //Favourites
    print("Before init:" + favouriteRecipes.toString());
    widget.favStorage
        .readFavourites()
        .then((value) => favouritesFinished(value));

    //Ingredients from "Pantry"
    DatabaseUtil.getDatabase();
    DatabaseUtil.getIngredients()
        .then((value) => ingredientsFetchComplete(value));
  }

  List<String> favouritesFinished(List<String> fav) {
    setState(() {
      favouriteRecipes = fav;
      print("Fav from asynchron loading:" + fav.toString());
      print("After init:" + favouriteRecipes.toString());
    });
    return fav;
  }

  void ingredientsFetchComplete(List<Ingredient> ingr) {
    ingr.forEach((element) {
      allIngredients.add(element.name.toUpperCase());
    });
    powerset(ingr).forEach((element) {
      if (element.toString() != "[]") {
        print("Checking api for: " + element.toString());
        fetchJson(element.toString()).then((value) => addToRecipeList(value));
      }
    });
  }

  void addToRecipeList(List<Recipe> newRecipes) {
    newRecipes.forEach((element) {
      recipes.add(element);
    });
    setState(() {
      this.recipes = recipes;
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

  List<Widget> _compileRecipes() {
    List<Widget> result = new List();

    //Iterate over each recipe
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

      bool isSaved = favouriteRecipes.contains(recipes[i].toString());

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
                    icon:
                        Icon(isSaved ? Icons.favorite : Icons.favorite_border),
                    color: isSaved ? Colors.red : null,
                    onPressed: () {
                      setState(() {
                        if (isSaved) {
                          print("Before removing favourite:" +
                              favouriteRecipes.toString());
                          favouriteRecipes.remove(recipes[i].toString());
                          print("After removing favourite:" +
                              favouriteRecipes.toString());
                        } else {
                          print("Before adding favourite:" +
                              favouriteRecipes.toString());
                          favouriteRecipes.add(recipes[i].toString());
                          print("After adding favourite:" +
                              favouriteRecipes.toString());
                        }
                        _saveFavourites();
                      });
                    },
                  ),
                  title: Text(recipes[i].title),
                  subtitle: Text("Ingredients: " + recipes[i].ingredients)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('CHECK IT OUT'),
                    onPressed: () {
                      _launchURL(recipes[i].href);
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

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _saveFavourites() {
    String favourites = "";
    for (String current in favouriteRecipes) {
      if (current != "") favourites = favourites + current + ";";
    }
    print("Before saving" + favourites);
    widget.favStorage.writeFavourite(favourites);
  }
}
//End of Recipe list
