import 'package:flutter/material.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Favorite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_app/classes/FavouriteStorage.dart';
import '../classes/Recipe.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;

class FavouriteListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FavouriteList(),
    );
  }


}

class FavouriteList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return FavouriteListState();
  }
}

class FavouriteListState extends State<FavouriteList> {
  List<Favorite> favorites = new List();
  Favorite communityFav;

  @override
  void initState() {
    super.initState();
    DatabaseUtil.getDatabase();
    DatabaseUtil.getFavorites().then((value) => setState((){favorites = value;}));

    DatabaseUtil.getTopFavoriteFromFirebase().then((value) => setState(() {this.communityFav = value;}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: _printFavorites(),
          ),
        ),
      ),
    );
  }

  List<Widget> _printFavorites() {
    List<Widget> printedFavorites = new List();

    if(communityFav != null){
      printedFavorites.add(SizedBox(height: 5,));
      printedFavorites.add(Text("Best dish according to other app users"));
      printedFavorites.add(Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Image.network(communityFav.recipe.thumbnail),
                title: Text(communityFav.recipe.title),
                subtitle: Text("Ingredients: " + communityFav.recipe.ingredients),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('CHECK IT OUT'),
                    onPressed: () {
                      _launchURL(communityFav.recipe.href);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ));
      printedFavorites.add(
        SizedBox(
          height: 20,
        ),
      );
    }

    int favIndex;

    for (int i = 0; i < favorites.length; i++) {
      favorites.forEach((element) {if(element.recipe == favorites[i].recipe) {favIndex = favorites.indexOf(element);}} );

      printedFavorites.add(Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Image.network(favorites[i].recipe.thumbnail),
                trailing: IconButton(
                  icon: Icon(Icons.favorite),
                  color: Colors.red,
                  onPressed: () {
                    DatabaseUtil.deleteFavorite(favorites[favIndex]); //.then((value) => setState((){favorites.remove(favIndex);}));
                    favorites.removeAt(favIndex);
                    setState(() {
                      this.favorites = favorites;
                    });

                  },
                ),
                title: Text(favorites[i].recipe.title),
                subtitle: Text("Ingredients: " + favorites[i].recipe.ingredients),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('CHECK IT OUT'),
                    onPressed: () {
                      _launchURL(favorites[i].recipe.href);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ));
      printedFavorites.add(
        SizedBox(
          height: 10,
        ),
      );
    }

    if (printedFavorites.length == 0) {
      printedFavorites.add(Text("No favorites selected"));
    }

    return printedFavorites;
  }

  _saveFavourites() {
    String currentfavourites = "";
    for (Recipe current in favourites) {
      if (current != null)
        currentfavourites = currentfavourites + current.toString() + ";";
    }
    print("Before saving" + currentfavourites);
    widget.storage.writeFavourite(currentfavourites);
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
            animation: new custom.CustomTabsAnimation.slideIn()
            ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
}
