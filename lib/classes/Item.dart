class Item {
  final String id;
  final String name;
  final double amount;
  final String unit;

  Item({this.id, this.name, this.amount, this.unit});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }

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
