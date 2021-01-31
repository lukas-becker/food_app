import 'Recipe.dart';

///Class to store Favorites
class Favorite {
  //Unique id
  final int id;
  //Recipe
  final Recipe recipe;
  //Times favorited
  int count;

  //Constructor
  Favorite(
      {this.id, this.recipe});

  //Alternate Constructor
  Favorite.withCount(
      {this.id, this.recipe, this.count});

  //Used for local DB Storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': recipe.title,
      'href': recipe.href,
      'ingredients' : recipe.ingredients,
      'thumbnail' : recipe.thumbnail,
    };
  }

  //Used for FireBase
  Map<String, dynamic> toJson() {
    return {
      'id': recipe.hashCode, //PrimaryKey
      'title': recipe.title,
      'href': recipe.href,
      'ingredients' : recipe.ingredients,
      'thumbnail' : recipe.thumbnail,
      'count' : (count == null ? 1 : count), //only for new entries, will be counted up later on
    };
  }

  //Used fpr Firebase
  factory Favorite.fromJson(Map<dynamic, dynamic> json) {
    return Favorite.withCount(
      id: json['id'],
      recipe: Recipe(
        title: json['title'],
        ingredients: json['ingredients'],
        thumbnail: json['thumbnail'],
        href: json['href']
      ),
      count: json['count'],
    );
  }
}
