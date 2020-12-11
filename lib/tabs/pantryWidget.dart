import 'package:flutter/material.dart';

//First Tab - Pantry
class PantryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Pantry(),
    );
  }
}

class Pantry extends StatefulWidget{

  @override
  _PantryState createState() => _PantryState();
}

class _PantryState extends State<Pantry> {
  final List<String> entries = <String>['egg', 'pork', 'cheese'];

  var tController = new TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Center(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: entries.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                tileColor: Colors.amber[100],
                title: Center(
                  child: Text(entries[index])
                  ),
                onLongPress: () => _askForDelete(index),
              );
            },
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addItem(),
          child: Icon(Icons.add),
          backgroundColor: Colors.lime,
        ),
    );
  }

  void _addItem() {

  String newItem;

  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("New List Item"),
          content: Row(
            children: [
              Expanded(child: 
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: tController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Ingredient',
                    ),
                  ),
                )
              ),
              ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close")
            ),
            FlatButton(
            child: Text("Save"),
            onPressed: (){
              newItem = tController.text;
              Navigator.of(context).pop();
            },
            ),

          ],
        );
      }
  ).then((value) => setState(() {
    if(newItem != null)
      entries.insert(entries.length,newItem);
    }));
  }

  void _askForDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete?"),
          content: Text("Do you want to delete \"${entries[index]}?\""),
            actions: <Widget>[
              TextButton(
                onPressed:() => {
                  _deleteItem(index),
                  Navigator.pop(context)
                  },
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () => {
                  Navigator.pop(context)
                },
                child: Text("Cancel"),
                )
            ], 
          
        );
      }
      );
  }

  void _deleteItem(int index){
    setState(() {
      entries.removeAt(index);
    });
  }
}


//End of Pantry