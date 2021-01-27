// A file which enables using global variables
library snack_hunter.globals;

// Boolean which describes if only recipes with the ingredients in the pantry are displayed 
bool exact = false;

// Variables used for search
bool search = false;
String searchString = '';

// List of all possible ingredients 
final List<String> entries = <String>['Almond', 'Basil', 'Beef broth', 'Beef stock', 'Butter', 'Capers', 'Cayenne pepper', 'Cheese', 'Chicken breast', 'Chicken broth', 'Chicken stock', 'Chili powder', 'Cinnamon', 'Corn', 'Cornstarch', 'Cumin', 'Eggs', 'Flour', 'Garlic', 'Garlic powder', 'Honey', 'Horseradish', 'Ketchup', 'Lentils', 'Margarine', 'Mayonnaise', 'Milk', 'Mustard', 'Olive oil', 'Onions', 'Oregano', 'Paprika', 'Pasta', 'Peas', 'Pepper', 'Rice', 'Salt', 'Soy sauce', 'Spinach', 'Sugar', 'Tomato paste', 'Tomato sauce', 'Tuna', 'Vegetable oil', 'Vinegar'];

// List of all possible units
final List<String> units = <String>["piece", "gram", "kilogram", "ounce", "pound", "liter", "gallon"];

// Translate double to String
String prettyFormatDouble(double value){
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}