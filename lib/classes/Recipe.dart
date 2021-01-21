class Recipe {
  String title;
  String href;
  String ingredients;
  String thumbnail;

  Recipe({this.title, this.href, this.ingredients, this.thumbnail});

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          href == other.href &&
          ingredients == other.ingredients &&
          thumbnail == other.thumbnail;

  @override
  int get hashCode =>
      title.hashCode ^
      href.hashCode ^
      ingredients.hashCode ^
      thumbnail.hashCode;
}
