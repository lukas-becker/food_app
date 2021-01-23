library snack_hunter.globals;

bool exact = false;
bool search = false;
String searchString = '';
final List<String> entries = <String>['Salt','Pepper','Olive oil','Vegetable oil','Flour','Chicken stock','Chicken broth','Beef stock',
  'Beef broth','Tomato sauce','Tomato paste','Tuna','Pasta','Rice','Lentils','Onions','Garlic','Vinegar','Soy sauce','Basil','Cayenne pepper',
  'Chili powder','Cumin','Cinnamon','Garlic powder','Oregano','Paprika','Eggs','Milk','Butter','Margarine','Ketchup','Mayonnaise','Cheese','Corn',
  'Spinach','Peas','Chicken breast','Capers','Horseradish','Almond','Cornstarch','Sugar','Honey','Mustard'];

final List<String> units = <String>["piece", "gram", "kilogram", "ounce", "pound", "liter", "gallon"];


String prettyFormatDouble(double value){
  print(value.truncateToDouble());
return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}