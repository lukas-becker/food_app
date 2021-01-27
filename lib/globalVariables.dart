// A file which enables using global variables
library snack_hunter.globals;

// Boolean which describes if only recipes with the ingredients in the pantry are displayed 
bool exact = false;

// Variables used for search
bool search = false;
String searchString = '';

// List of all possible ingredients 
final List<String> entries = <String>['Salt','Pepper','Olive oil','Vegetable oil','Flour','Chicken stock','Chicken broth','Beef stock',
  'Beef broth','Tomato sauce','Tomato paste','Tuna','Pasta','Rice','Lentils','Onions','Garlic','Vinegar','Soy sauce','Basil','Cayenne pepper',
  'Chili powder','Cumin','Cinnamon','Garlic powder','Oregano','Paprika','Eggs','Milk','Butter','Margarine','Ketchup','Mayonnaise','Cheese','Corn',
  'Spinach','Peas','Chicken breast','Capers','Horseradish','Almond','Cornstarch','Sugar','Honey','Mustard'];

// List of all possible units
final List<String> units = <String>["piece", "gram", "kilogram", "ounce", "pound", "liter", "gallon"];

// Translate double to String
String prettyFormatDouble(double value){
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}