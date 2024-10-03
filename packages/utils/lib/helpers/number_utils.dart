import 'package:get/get.dart';

extension NumberUtils on num {
  double getPercentage(double percentage, {bool deductPercentageFromOriginalPrice = true}) {
    if (deductPercentageFromOriginalPrice) {
      return (this - (this * (percentage / 100))).toPrecision(2);
    }
    return (this * (percentage / 100)).toPrecision(2);
  }

  double getPresision(int precision) {
    return double.parse(toStringAsFixed(precision));
  }
}
