class Ingredient {
  final int id;
  final String name;
  int amount;

  Ingredient({this.id, this.name, this.amount});

  void updateAmount(int newAmount){
    amount = newAmount;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    //return super.toString();
    return name;
  }
}