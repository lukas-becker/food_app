import 'UnitEnum.dart';

class GroceryItem{
  final String name;
  final double quantity;
  final String unit;

  GroceryItem(this.name, this.quantity, this.unit);

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'quantity': quantity,
        'unit' : unit,
      };

  GroceryItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        quantity = json['quantity'],
        unit = json['unit'];
}

