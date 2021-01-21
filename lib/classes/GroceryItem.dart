import 'UnitEnum.dart';

class GroceryItem{
  final int id;
  final String name;
  final double quantity;
  final String unit;

  GroceryItem(this.id, this.name, this.quantity, this.unit);

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit' : unit,
      };

  GroceryItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        quantity = json['quantity'],
        unit = json['unit'];
}

