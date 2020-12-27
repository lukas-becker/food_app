import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FavouriteStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/favourites.txt');
  }

  Future<File> writeFavourite(String favourite) async {
    final file = await _localFile;
    return file.writeAsString(favourite);
  }

  Future<List<String>> readFavourites() async {
    try {
      final file = await _localFile;

      String contents = file.readAsStringSync();

      List<String> favourites = contents.split(";");

      return favourites;
    } catch (e) {
      print("Error");
      return [];
    }
  }
}