import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classes/Recipe.dart';

class FavoriteListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FavoriteList(),
    );
  }
}

class FavoriteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FavoriteListState();
  }
}

class FavoriteListState extends State<FavoriteList> {
  final List<Recipe> favorites = <Recipe>[Recipe(title: "Ich" , thumbnail: "http:\/\/img.recipepuppy.com\/1021.jpg",href: "http:\/\/google.com", ingredients: "Apple")];

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
                leading: Image.network(favorites[i].thumbnail),
                title: Text(favorites[i].title),
                subtitle: Text("Ingredients: " + favorites[i].ingredients),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('CHECK IT OUT'),
                    onPressed: () {
                      // TODO: URL Launch has to work
                      _launchURL(favorites[i].href);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ));
      printedFavorites.add(SizedBox(
        height: 10,
      ));
    }

    if (printedFavorites.length == 0){
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
