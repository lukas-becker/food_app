import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_app/classes/Recipe.dart';
import 'package:url_launcher/url_launcher.dart';

class FilteredRecipesWidget extends StatelessWidget {
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

  List<Widget> _showRecipes(BuildContext context) {
    List<Widget> displayedList = new List();
    for (int i = 0; i < filteredRecipes.length; i++) {
      displayedList.add(
        SizedBox(
          width: 8,
          height: 15,
        ),
      );

      displayedList.add(
        Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              print('Card tapped.');
            },
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
                        _launchURL(filteredRecipes[i].href);
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

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
