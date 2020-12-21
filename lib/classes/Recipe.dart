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

  @override
  String toString() {
    return title + "_SEPERATOR_" + href + "_SEPERATOR_" + ingredients + "_SEPERATOR_" + thumbnail ; 
  }
}