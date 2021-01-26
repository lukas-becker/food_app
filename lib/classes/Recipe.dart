///Class to store recipe information as object
class Recipe {
  //Information API provides
  final String title;
  final String href;
  final String ingredients;
  String thumbnail;

  //Constructor
  Recipe({this.title, this.href, this.ingredients, this.thumbnail});

  //For DB usage
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      href: json['href'],
      ingredients: json['ingredients'],
      thumbnail: json['thumbnail'],
    );
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

  //For comparison if objects are equeal
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          href == other.href &&
          ingredients == other.ingredients &&
          thumbnail == other.thumbnail;

  //Used as Unique key
  @override
  int get hashCode =>
      title.hashCode ^
      href.hashCode ^
      ingredients.hashCode ^
      thumbnail.hashCode;
}
