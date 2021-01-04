import 'package:flutter/material.dart';
import 'TabNavigation.dart';

void main() {
  runApp(SnackHunter());
}

class SnackHunter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TabNavigation(),
    );
  }
}

//Tab Navigation
