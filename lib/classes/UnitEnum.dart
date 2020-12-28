enum Unit {
  gram,
  kilogram,
  ounce,
  pound
}

extension UnitExtension on Unit{
  String get abbreviation {
    switch (this){
      case Unit.gram:
        return "g";
        break;
      case Unit.kilogram:
        return "kg";
        break;
      case Unit.ounce:
        return "oz";
        break;
      case Unit.pound:
        return "lb";
        break;
      default:
        return null;
        break;
    }
  }
  String get name {
    switch (this){
      case Unit.gram:
        return "gram";
        break;
      case Unit.kilogram:
        return "kilogram";
        break;
      case Unit.ounce:
        return "ounce";
        break;
      case Unit.pound:
        return "pound";
        break;
      default:
        return null;
        break;
    }
  }
}