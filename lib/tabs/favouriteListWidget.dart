import 'package:flutter/material.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Favorite.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;
import 'package:food_app/globalVariables.dart' as globals;


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
  //Storage variables
  List<Favorite> favorites = new List();
  Favorite communityFav;

  @override
  void initState() {
    super.initState();
    //Init db
    DatabaseUtil.getDatabase();
    //Get local Favorites
    DatabaseUtil.getFavorites().then((value) => {
          setState(() {
            favorites = value;
          })
        });
    //Get global Favorite
    DatabaseUtil.getTopFavoriteFromFirebase().then((value) => {
          setState(() {
            this.communityFav = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _printFavorites(),
          ),
        ),
    );
  }

  List<Widget> _printFavorites() {
    List<Widget> printedFavorites = new List();

    printedFavorites.add(SizedBox(
      width: 8,
      height: 15,
    ));

    //Print global Favorite if existing
    if (communityFav != null) {
      printedFavorites.add(SizedBox(
        height: 5,
      ));
      printedFavorites.add(Text("Best dish according to other app users", style: globals.mainTextStyle,));
      printedFavorites.add(Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Image.network(communityFav.recipe.thumbnail),
                title: Text(communityFav.recipe.title, style: globals.mainTextStyle,),
                subtitle:
                    Text("Ingredients: " + communityFav.recipe.ingredients, style: globals.smallTextStyle,),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('CHECK IT OUT', style: TextStyle(fontSize: globals.mainFontSize, color: Colors.red),),
                    onPressed: () {
                      _launchURL(context, communityFav.recipe.href);
                      print(
                          "[${DateTime.now().toIso8601String()}] INFO: Launched URL from recipe ${communityFav.recipe.title}");
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ));
      //Margin
      printedFavorites.add(
        SizedBox(
          height: 20,
        ),
      );
    }

    printedFavorites.add(SizedBox(
      height: 5,
    ));
    printedFavorites.add(Text("Your Favorites", style: globals.mainTextStyle));

    int favIndex;

    //Loop over favorites
    for (int i = 0; i < favorites.length; i++) {
      favorites.forEach((element) {
        if (element.recipe == favorites[i].recipe) {
          favIndex = favorites.indexOf(element);
        }
      });

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
                    //Remove from list
                    DatabaseUtil.deleteFavorite(favorites[favIndex]);
                    favorites.removeAt(favIndex);
                    setState(() {
                      this.favorites = favorites;
                    });
                    print(
                        "[${DateTime.now().toIso8601String()}] INFO: Removed ${favorites[i].recipe.title} from favorites");
                  },
                ),
                title: Text(favorites[i].recipe.title, style: globals.mainTextStyle),
                subtitle:
                    Text("Ingredients: " + favorites[i].recipe.ingredients, style: globals.smallTextStyle,),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('CHECK IT OUT', style: globals.mainTextStyle,),
                    onPressed: () {
                      _launchURL(context, favorites[i].recipe.href);
                      print(
                          "[${DateTime.now().toIso8601String()}] INFO: Launched URL from recipe ${favorites[i].recipe.title}");
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ));
      //Margin
      printedFavorites.add(
        SizedBox(
          height: 10,
        ),
      );
    }

    if (printedFavorites.length == 0) {
      printedFavorites.add(Text("No favorites selected", style: globals.mainTextStyle,));
    }

    return printedFavorites;
  }

  ///Open URL in chrome custom Tab
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
}
