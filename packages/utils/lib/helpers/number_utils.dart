import 'package:get/get.dart';

extension NumberUtils on num {
  double getPercentage(double percentage) {
    return (this - (this * (percentage / 100))).toPrecision(2);
  }
}
