// A file which enables using global variables
library snack_hunter.globals;

// Boolean which describes if only recipes with the ingredients in the pantry are displayed 
bool exact = false;

// Variables used for search
bool search = false;
String searchString = '';

// List of all possible ingredients 
final List<String> entries = <String>['Almond', 'Apple', 'Applesauce', 'Bacon', 'Baking Soda', 'Banana', 'Basil', 'Beans', 'Beef', 'Beef broth', 'Beef stock', 'Bread', 'Butter', 'Cabbage', 'Carrot', 'Capers', 'Cayenne pepper', 'Cheese', 'Chicken breast', 'Chicken broth', 'Chicken stock', 'Chili powder', 'Chocolate', 'Cinnamon', 'Corn', 'Cornstarch', 'Cranberry', 'Cream Cheese', 'Cucumber', 'Cumin', 'Egg', 'Eggplant', 'Flour', 'Garlic', 'Garlic powder', 'Gelatin', 'Ground Meat', 'Ham', 'Hazelnut', 'Heavy Cream', 'Honey', 'Horseradish', 'Ketchup', 'Lemon', 'Lentils', 'Lime', 'Maple Syrup', 'Margarine', 'Mayonnaise', 'Milk', 'Mushroom', 'Mustard', 'Oil', 'Olives', 'Olive oil', 'Onion', 'Oregano', 'Paprika', 'Pasta', 'Peas', 'Pepper', 'Pickles', 'Pork', 'Potato', 'Raspberry', 'Rice', 'Salad', 'Salt', 'Sausage', 'Soy sauce', 'Spinach', 'Strawberry', 'Sugar', 'Tomato', 'Tomato paste', 'Tomato sauce', 'Tuna', 'Turkey', 'Vanilla Extract', 'Vegetable oil', 'Vinegar', 'Wine'];

// List of all possible units
final List<String> units = <String>["piece", "gram", "kilogram", "ounce", "pound", "liter", "gallon"];

// Translate double to String
String prettyFormatDouble(double value){
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}