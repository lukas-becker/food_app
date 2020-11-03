import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(APITest());
}

class APITest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple API demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FirstRecipes(title: 'Get your first recipe'),
    );
  }
}

class FirstRecipes extends StatefulWidget {
  FirstRecipes({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FirstRecipesState createState() => _FirstRecipesState();
}

class _FirstRecipesState extends State<FirstRecipes> {
  var futureRecipes = [];
  Future<dynamic> futureJson;
  int count = 0;

  Future<dynamic> fetchJson() async {
    final response = await http.get('http://www.recipepuppy.com/api/?i=pork');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      dynamic json = jsonDecode(response.body)['results'];
      return json;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load recipe');
    }
  }

  Future<Recipe> fetchRecipe(int resNumber) async {
    final response = await http.get('http://www.recipepuppy.com/api/?i=pork');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Recipe.fromJson(jsonDecode(response.body)['results'][resNumber]);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load recipe');
    }
  }

  @override
  void initState() {
    super.initState();
    futureJson = fetchJson().then((value) => complete(value));

  }

  void complete(dynamic json){
    List jsonInner = json;
    jsonInner.forEach((element) {
      futureRecipes.add(fetchRecipe(count));
      count++;
    });

    setState(() {
      this.futureRecipes = futureRecipes;
      this.count = count;
    });

  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: SingleChildScrollView(
          child: Column(children: _printRecipes()),
        )
      )
    );
  }

  List<Widget> _printRecipes(){
    List<Widget> children = new List();
    children.add(Text(
      'Fresh Recipes:',
      style: Theme.of(context).textTheme.headline2,
    ));
    int i;
    for(i = 0; i < count; i++){

      children.add(FutureBuilder<Recipe>(
        future: futureRecipes[i],
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            return Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  print('Card tapped.');
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    ListTile(
                      leading: Image.network(
                          snapshot.data.thumbnail),
                      title: Text(snapshot.data.title),
                      subtitle: Text("Ingredients: " + snapshot.data.ingredients),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('CHECK IT OUT'),
                          onPressed: () {
                            _launchURL(snapshot.data.href);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            );

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  snapshot.data.title,
                  style: Theme.of(context).textTheme.headline4,
                ),
                Text(snapshot.data.ingredients),
                Text(snapshot.data.href)
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}" " Test");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ));
      children.add(SizedBox(height: 10,));
    }

    if(count == 0){
      children.add(Text("No elements yet"));
    }

    return children;

  }

  _launchURL(String url) async {
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

  class Recipe {
    final String title;
    final String href;
    final String ingredients;
    final String thumbnail;

    Recipe({this.title, this.href, this.ingredients, this.thumbnail});

    factory Recipe.fromJson(Map<String, dynamic> json) {
      return Recipe(
        title: json['title'],
        href: json['href'],
        ingredients: json['ingredients'],
        thumbnail: json['thumbnail'],
      );
    }
  }



