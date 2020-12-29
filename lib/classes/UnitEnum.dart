@deprecated
enum Unit {
  gram,
  kilogram,
  ounce,
  pound
}

@deprecated
extension UnitExtension on Unit{
  String toShortString(){
    return this.toString().split(".").last;
  }
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

  static Unit fromString (String input){
    String lowercaseInput = input.toLowerCase();
    switch (lowercaseInput){
      case "gram":
        return Unit.gram;
        break;
      case "kilogram":
        return Unit.kilogram;
        break;
      case "ounce":
        return Unit.ounce;
        break;
      case "pound":
        return Unit.pound;
        break;
      default:
        return null;
        break;
    }
  }
}
