import 'package:food_app/tabs/recipeListWidget.dart';

import 'Recipe.dart';
class Favorite extends Recipe {
  final int id;
  final Recipe recipe;

  Favorite(
      {this.id, this.recipe});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': recipe.title,
      'href': recipe.href,
      'ingredients' : recipe.ingredients,
      'thumbnail' : recipe.thumbnail,
    };
  }

  @override
  String toString() {
    return title +
        "_SEPERATOR_" +
        href +
        "_SEPERATOR_" +
        ingredients +
        "_SEPERATOR_" +
        thumbnail;
  }
}
