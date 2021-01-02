import 'dart:convert';

import 'package:food_app/classes/GroceryItem.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GroceryStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/groceries.txt');
  }

  Future<File> writeGroceries(String output) async {
    final file = await _localFile;
    return file.writeAsString(output);
  }

  Future<List<GroceryItem>> readGroceriesFromFile() async {
    List<GroceryItem> groceryItems = [];
    try {
      final file = await _localFile;
      String contents = file.readAsStringSync();
      List<String> groceries = contents.split(";");
      for (int i = 0; i < groceries.length; i++){
        Map groceryMap = jsonDecode(groceries[i]);
        groceryItems.add(GroceryItem.fromJson(groceryMap));
      }
      return groceryItems;

    } catch (e) {
      print("Error");
      return [];
    }
  }
}