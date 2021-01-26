///Class to store general Items (Ingredients and Grocery items)
class Item {
  //characteristics
  final int id;
  final String name;
  final double amount;
  final String unit;

  //Constructor
  Item({this.id, this.name, this.amount, this.unit});

  //For local DB usage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }

  //For local DB usage
  Item.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        amount = map['amount'],
        unit = map['unit'];

  @override
  String toString() {
    return name;
  }
}
