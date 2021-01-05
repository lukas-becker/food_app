import 'package:flutter/material.dart';
import 'package:food_app/classes/DatabaseUtil.dart';
import 'package:food_app/classes/Favorite.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classes/Recipe.dart';

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

  @override
  void initState() {
    super.initState();
    DatabaseUtil.getDatabase();
    DatabaseUtil.getFavorites().then((value) => setState((){favorites = value;}));
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
    int i;
    for (i = 0; i < favorites.length; i++) {
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
                    setState(() {
                      setState(() {
                        DatabaseUtil.deleteFavorite(favorites[i].id).then((value) => setState((){favorites.remove(Favorite(id: favorites[i].id, recipe: favorites[i].recipe));}));
                      });
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

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
