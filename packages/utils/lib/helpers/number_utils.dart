import 'package:get/get.dart';

extension NumberUtils on num {
  double getPercentage(double percentage, {bool deductPercentageFromOriginalPrice = true}) {
    if (deductPercentageFromOriginalPrice) {
      return (this - (this * (percentage / 100))).toPrecision(2);
    }
    return (this * (percentage / 100)).toPrecision(2);
  }

  double getPresision(int precision, {bool roundUp = false}) {
    if (roundUp) {
      return double.parse(ceilToDouble().toStringAsFixed(precision));
    }
    return double.parse(roundToDouble().toStringAsFixed(precision));
  }

  String getPresisionString({int precision = 2}) {
    String valueStr = this.toString();
    if (valueStr.endsWith('.0')) {
      valueStr = valueStr.substring(0, valueStr.length - 2); // Remove '.0'
    } else if (valueStr.endsWith('.00')) {
      valueStr = valueStr.substring(0, valueStr.length - 3); // Remove '.00'
    }

    return valueStr;
  }

  double getPercentageOff(List<double> percentages, {bool deductPercentageFromOriginalPrice = true}) {
    var total = this;
    for (final percentage in percentages) {
      total = total.getPercentage(percentage, deductPercentageFromOriginalPrice: deductPercentageFromOriginalPrice);
    }
    return total.getPresision(2);
  }
}
